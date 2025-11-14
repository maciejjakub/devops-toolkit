import requests

def get_runs(api_token, organization_name):
    """Fetch runs with 'cost estimated' status."""
    url = f"https://app.terraform.io/api/v2/organizations/{organization_name}/runs?filter[status]=cost_estimated&page[size]=100"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/vnd.api+json"
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json().get("data", [])
    else:
        print(f"Failed to retrieve runs: {response.status_code} - {response.text}")
        return []

def approve_run(api_token, run_id):
    """Approve a specified run."""
    url = f"https://app.terraform.io/api/v2/runs/{run_id}/actions/apply"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/vnd.api+json"
    }
    
    response = requests.post(url, headers=headers)
    if response.status_code == 202:
        print(f"Successfully approved run: {run_id}")
    else:
        print(f"Failed to approve run: {response.status_code} - {response.text}")

def main(api_token, organization_name, prefix):
    """Main function to approve runs prefixed with the given string."""
    runs = get_runs(api_token, organization_name)
    for run in runs:
        run_id = run["id"]
        run_message = run["attributes"]["message"]
        if run_message.startswith(prefix):
            approve_run(api_token, run_id)

if __name__ == "__main__":
    api_token = input("Enter your Terraform Cloud API token: ")
    organization_name = input("Enter your organization name: ")
    prefix = input("Enter the prefix for the runs: ")
    main(api_token, organization_name, prefix)