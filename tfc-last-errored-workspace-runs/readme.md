# Terraform Cloud Last Errored Workspace Runs

This directory contains `fetch_failed_workspace_runs.sh`, a Bash script that retrieves the most recent failed Terraform Cloud workspace runs.

## What the script does

- Reads the Terraform Cloud token from `~/.terraform.d/credentials.tfrc.json`
- Expects the token in this JSON structure:

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "<your-token>"
    }
  }
}
```

- Calls the Terraform Cloud API
- Fetches the most recent runs with status `errored`
- Defaults to fetching `30` runs when no argument is provided
- Accepts a custom limit as the first positional argument

## Requirements

- `bash`
- `curl`
- `jq`

## Usage

Run with the default limit of `30`:

```bash
./fetch_failed_workspace_runs.sh
```

Run with a custom limit:

```bash
./fetch_failed_workspace_runs.sh 10
```

Specify the organization explicitly:

```bash
./fetch_failed_workspace_runs.sh 10 --org my-organization
```

Or via environment variable:

```bash
TFC_ORGANIZATION=my-organization ./fetch_failed_workspace_runs.sh 10
```

## Organization auto-discovery

If you do not provide `--org` and `TFC_ORGANIZATION` is not set, the script tries to discover organizations accessible by your token.

Behavior:

- If the token can access exactly one organization, the script uses it automatically.
- If the token can access multiple organizations, the script stops and prints the available organization names. In that case, provide one with `--org` or `TFC_ORGANIZATION`.
- If the token cannot access any organizations, the script exits with an error.

The script discovers organizations by calling:

```text
GET https://app.terraform.io/api/v2/organizations?page[number]=1&page[size]=100
```

## Output

The script prints tab-separated output with these columns:

```text
organization    created_at    source    workspace_name    run_url
```

## Notes

- The default Terraform Cloud host is `app.terraform.io`
- You can override the host with `TFC_HOST`
- Run URLs in the output point to the API endpoint for each run
