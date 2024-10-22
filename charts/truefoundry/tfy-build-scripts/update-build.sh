#!/bin/bash
set -e

# Function to display help message
function display_help {
    echo "Usage: $0 '{\"status\": \"<STATUS>\", \"metadata\": \"<metadata-in-json-format>\"}'"
    echo "E.g. update-status.sh '{\"status\": \"SUCCEEDED\", \"metadata\": \"{\"key\": \"value\"}\"}'"
    echo
    echo "Options:"
    echo "  -h, --help   Display this help message"
    exit 0
}

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "Error: No argument provided. Use -h or --help for usage."
    exit 1
fi

# Check for -h or --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

if ! echo "$1" | jq empty 2>/dev/null; then
    echo "Invalid JSON argument. Please provide a valid JSON payload."
    exit 1
fi

FINAL_PAYLOAD=$(echo "$1" | jq 'del(.tfyBuildMetadata)')
if [[ -n "$TFY_METADATA_TIME_TAKEN_TO_BUILD_IMAGE_SECONDS" ]]; then
    BUILD_TIME_TAKEN_IN_INT=$((TFY_METADATA_TIME_TAKEN_TO_BUILD_IMAGE_SECONDS + 0))
    FINAL_PAYLOAD=$(echo "$FINAL_PAYLOAD" | jq ".tfyBuildMetadata.timeTakenToBuildImageSeconds = $BUILD_TIME_TAKEN_IN_INT")
fi

if [[ -n "$IS_GLOBAL_BUILDER_USED" ]]; then
    IS_GLOBAL_BUILDER_USED_IN_BOOL=false
    if [[ "$IS_GLOBAL_BUILDER_USED" == "true" ]]; then
        IS_GLOBAL_BUILDER_USED_IN_BOOL=true
    fi
    FINAL_PAYLOAD=$(echo "$FINAL_PAYLOAD" | jq ".tfyBuildMetadata.isGlobalBuilderUsed = $IS_GLOBAL_BUILDER_USED_IN_BOOL")
fi

status=$(echo "$1" | jq -r '.status')
if [[ -n "$status" ]]; then
    echo "Updating build status to $status"
fi

curl --no-progress-meter --show-error -X "PATCH" \
    -H "Content-Type: application/json" \
    -d "$FINAL_PAYLOAD" \
    --retry 3 \
    --retry-delay 10 \
    "$CALLBACK_URL" > /dev/null

echo -n "$status" > /opt/truefoundry/output/buildStatus