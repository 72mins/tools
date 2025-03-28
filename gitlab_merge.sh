#!/bin/bash

gitlab_url=""
private_token=""
user_id=""
project_ids=("" "")

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
