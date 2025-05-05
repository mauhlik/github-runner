#!/bin/bash
set -e

GITHUB_BASE_URL="https://github.com"
GITHUB_API_BASE_URL="https://api.github.com"

if [[ -z "$GITHUB_TOKEN_FILE" ]]; then
    echo "GITHUB_TOKEN_FILE environment variable is not set"
    exit 1
fi
if [ ! -f "$GITHUB_TOKEN_FILE" ]; then
    echo "Token file not found: $GITHUB_TOKEN_FILE"
    exit 1
fi

OWNER=""
ENDPOINT=""

if [[ -n "$GITHUB_ORGANIZATION" ]]; then
    OWNER="$GITHUB_ORGANIZATION"
    ENDPOINT="${GITHUB_API_BASE_URL}/orgs/$GITHUB_ORGANIZATION/actions/runners/registration-token"
elif [[ -n "$GITHUB_REPOSITORY" && -n "$GITHUB_OWNER" ]]; then
    OWNER="$GITHUB_OWNER/$GITHUB_REPOSITORY"
    ENDPOINT="${GITHUB_API_BASE_URL}/repos/$OWNER/actions/runners/registration-token"
fi

GITHUB_API_TOKEN=$(cat "$GITHUB_TOKEN_FILE")

echo "Obtaining registration token from GitHub..."
response=$(curl -s -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_API_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  ${ENDPOINT})

registration_token=$(echo "$response" | jq -r '.token')
if [[ "$registration_token" == "null" || -z "$registration_token" ]]; then
    echo "Failed to obtain registration token"
    echo "Received $response"
    exit 1
fi
### Command Opts
COMMAND_OPTS=("--disableupdate")
if [[ -z "EPHEMERAL_RUNNER" && "$EPHEMERAL_RUNNER" == "true" ]]; then
    COMMAND_OPTS+=("--ephemeral")
fi

echo "Configuring runner..."
./config.sh --url ${GITHUB_BASE_URL}/${OWNER} --token "$registration_token" "${COMMAND_OPTS[@]}"

echo "Starting runner..."
./run.sh
