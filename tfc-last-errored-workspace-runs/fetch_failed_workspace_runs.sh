#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_LIMIT=30
readonly DEFAULT_HOST="app.terraform.io"
readonly CREDENTIALS_FILE="${HOME}/.terraform.d/credentials.tfrc.json"

limit="${DEFAULT_LIMIT}"
organization="${TFC_ORGANIZATION:-}"
host="${TFC_HOST:-${DEFAULT_HOST}}"

usage() {
  cat <<'EOF'
Usage: ./fetch_failed_workspace_runs.sh [limit] [--org ORGANIZATION]

Fetch the most recent failed Terraform Cloud workspace runs.

Arguments:
  limit                 Number of failed runs to fetch. Defaults to 30.

Options:
  -o, --org NAME        Terraform Cloud organization name.
  -h, --help            Show this help message.

Environment:
  TFC_ORGANIZATION      Organization name. Used when --org is not provided.
  TFC_HOST              Terraform Cloud hostname. Defaults to app.terraform.io.
EOF
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
}

api_get() {
  local url="$1"

  curl \
    --globoff \
    --silent \
    --show-error \
    --fail-with-body \
    --header "Authorization: Bearer ${token}" \
    --header "Content-Type: application/vnd.api+json" \
    "$url"
}

discover_organization() {
  local response org_count org_names

  response="$(api_get "https://${host}/api/v2/organizations?page[number]=1&page[size]=100")"
  org_count="$(jq '.data | length' <<<"$response")"

  if [[ "$org_count" -eq 0 ]]; then
    printf 'No Terraform Cloud organizations are accessible with the configured token.\n' >&2
    exit 1
  fi

  if [[ "$org_count" -eq 1 ]]; then
    jq -r '.data[0].attributes.name' <<<"$response"
    return 0
  fi

  org_names="$(jq -r '[.data[].attributes.name] | join(", ")' <<<"$response")"
  printf 'Multiple organizations found: %s\n' "$org_names" >&2
  printf 'Set TFC_ORGANIZATION or pass --org NAME.\n' >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -o|--org)
      if [[ $# -lt 2 ]]; then
        printf 'Missing value for %s\n' "$1" >&2
        exit 1
      fi
      organization="$2"
      shift 2
      ;;
    -* )
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ "$limit" != "$DEFAULT_LIMIT" ]]; then
        printf 'Only one positional argument is supported: [limit]\n' >&2
        usage >&2
        exit 1
      fi
      limit="$1"
      shift
      ;;
  esac
done

if ! [[ "$limit" =~ ^[1-9][0-9]*$ ]]; then
  printf 'Limit must be a positive integer. Received: %s\n' "$limit" >&2
  exit 1
fi

require_command curl
require_command jq
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  printf 'Terraform credentials file not found: %s\n' "$CREDENTIALS_FILE" >&2
  exit 1
fi

token="$(jq -r --arg host "$host" '.credentials[$host].token // empty' "$CREDENTIALS_FILE")"

if [[ -z "$token" ]]; then
  printf 'No token found for host %s in %s\n' "$host" "$CREDENTIALS_FILE" >&2
  exit 1
fi

if [[ -z "$organization" ]]; then
  organization="$(discover_organization)"
fi

page=1
collected=0
page_size="$limit"

if [[ "$page_size" -gt 100 ]]; then
  page_size=100
fi

output_lines=()

while [[ "$collected" -lt "$limit" ]]; do
  response="$(api_get "https://${host}/api/v2/organizations/${organization}/runs?page[number]=${page}&page[size]=${page_size}&filter[status]=errored&include=workspace")"

  mapfile -t page_lines < <(
    jq -r '
      (.included // []
        | map(select(.type == "workspaces") | {key: .id, value: .attributes.name})
        | from_entries) as $workspace_names
      |
      .data[] | [
        .attributes["created-at"],
        .attributes.source,
        ($workspace_names[.relationships.workspace.data.id] // ""),
        ("https://'"${host}"'/api/v2/runs/" + .id)
      ] | @tsv
    ' <<<"$response"
  )

  if [[ "${#page_lines[@]}" -eq 0 ]]; then
    break
  fi

  for line in "${page_lines[@]}"; do
    output_lines+=("$line")
    collected=$((collected + 1))

    if [[ "$collected" -ge "$limit" ]]; then
      break
    fi
  done

  next_page="$(jq -r '.meta.pagination["next-page"] // empty' <<<"$response")"
  if [[ -z "$next_page" || "$next_page" == "null" ]]; then
    break
  fi

  page="$next_page"
done

printf 'organization\tcreated_at\tsource\tworkspace_name\trun_url\n'

for line in "${output_lines[@]}"; do
  printf '%s\t%s\n' "$organization" "$line"
done
