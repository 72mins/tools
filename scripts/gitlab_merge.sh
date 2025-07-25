#!/bin/bash

################################################################################
# Script: GitLab Auto-Merge
#
# Description: This script automatically merges all Gitlab merge requests
# assigned to a specific user across multiple projects.
#
# Configuration:
#  - GITLAB_URL: The URL of your GitLab instance (e.g., "https://gitlab.com").
#       Set as an environment variable.
#  - GITLAB_TOKEN: Your GitLab private token with 'api' scope. Set as an
#       environment variable.
#  - GITLAB_USER_ID: Your GitLab user ID. Set as an environment variable.
#  - GITLAB_PROJECT_IDS: A space-separated list of GitLab project IDs to
#       process. Set as an environment variable.
#
# Dependencies:
#  - curl: For making HTTP requests to the GitLab API.
#  - jq: For parsing JSON responses from the GitLab API.
#
# Version:  1.0.1
################################################################################

gitlab_url="${GITLAB_URL}"
private_token="${GITLAB_TOKEN}"
user_id="${GITLAB_USER_ID}"
project_ids=(${GITLAB_PROJECT_IDS})

if [ -z "$gitlab_url" ] || [ -z "$private_token" ] || [ -z "$user_id" ] || [ -z "$GITLAB_PROJECT_IDS" ]; then
    echo "Error: Missing required environment variables (GITLAB_URL, GITLAB_TOKEN, GITLAB_USER_ID, GITLAB_PROJECT_IDS)."
    exit 1
fi

merge_request() {
    local project_id="$1"
    local merge_request_iid="$2"

    echo "Merging project ${project_id} merge request !${merge_request_iid}..."

    api_url="${gitlab_url}/api/v4/projects/${project_id}/merge_requests/${merge_request_iid}/merge"

    curl --request PUT \
        --header "PRIVATE-TOKEN: ${private_token}" \
        "${api_url}"

    echo "Merge request !${merge_request_iid} in project ${project_id} merged."
}

for project_id in "${project_ids[@]}"; do
    echo "Checking project ${project_id}..."

    api_url="${gitlab_url}/api/v4/projects/${project_id}/merge_requests?scope=all&state=opened&reviewer_id=${user_id}"

    merge_requests=$(curl --header "PRIVATE-TOKEN: ${private_token}" "${api_url}")

    if [[ $(echo "${merge_requests}" | jq -e .) ]]; then
        echo "${merge_requests}" | jq -r '.[] | select(.state == "opened" and any(.reviewers[]; .id == '$user_id')) | .iid' | while read merge_request_iid; do
            if [[ -n "$merge_request_iid" ]]; then
                merge_request "$project_id" "$merge_request_iid"
            fi
        done
    else
        echo "Error: Could not fetch merge requests for project ${project_id}."
        echo "Response: ${merge_requests}"
    fi
done

echo "Finished checking all projects."
