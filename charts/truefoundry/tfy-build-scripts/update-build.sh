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
# If the build step did not happen due to a pod spec error, the exit handler will be called without resolving {{}} Argo Variables.
# So if a variable value is starting with {{ it means that the value was not set or resolved, and we can ignore it.
if [[ -n "$TFY_METADATA_TIME_TAKEN_TO_BUILD_IMAGE_SECONDS" && "$TFY_METADATA_TIME_TAKEN_TO_BUILD_IMAGE_SECONDS" != \{\{* ]]; then
    BUILD_TIME_TAKEN_IN_INT=$((TFY_METADATA_TIME_TAKEN_TO_BUILD_IMAGE_SECONDS + 0))
    FINAL_PAYLOAD=$(echo "$FINAL_PAYLOAD" | jq ".tfyBuildMetadata.timeTakenToBuildImageSeconds = $BUILD_TIME_TAKEN_IN_INT")
fi

if [[ -n "$TFY_TIME_TAKEN_TO_DOWNLOAD_SOURCE_CODE_SECONDS" && "$TFY_TIME_TAKEN_TO_DOWNLOAD_SOURCE_CODE_SECONDS" != \{\{* ]]; then
    SOURCE_CODE_DOWNLOAD_TIME_TAKEN=$((TFY_TIME_TAKEN_TO_DOWNLOAD_SOURCE_CODE_SECONDS + 0))
    FINAL_PAYLOAD=$(echo "$FINAL_PAYLOAD" | jq ".tfyBuildMetadata.timeTakenToDownloadSourceCodeSeconds = $SOURCE_CODE_DOWNLOAD_TIME_TAKEN")
fi

if [[ -n "$IS_GLOBAL_BUILDER_USED" ]]; then
    IS_GLOBAL_BUILDER_USED_IN_BOOL=false
    if [[ "$IS_GLOBAL_BUILDER_USED" == "true" ]]; then
        IS_GLOBAL_BUILDER_USED_IN_BOOL=true
    fi
    FINAL_PAYLOAD=$(echo "$FINAL_PAYLOAD" | jq ".tfyBuildMetadata.isGlobalBuilderUsed = $IS_GLOBAL_BUILDER_USED_IN_BOOL")
fi

status=$(echo "$1" | jq -r '.status')
if [[ "$status" != "null" ]]; then
    echo "Updating build status to $status"
fi

echo "Final payload: $FINAL_PAYLOAD"

# servicefoundry-server may serve HTTPS and require a client certificate when global.mTLS.enabled.
# The chart mounts the same mTLS secret used by other services (at /etc/tls/truefoundry); present
# it here — otherwise this callback is rejected and the build finishes successfully but never
# reports its status, which looks like a hung build rather than an auth failure.
#
# Detected by checking for the files rather than by an env var, so the script works unchanged whether
# or not mTLS is enabled, and on older charts that mount nothing.
TLS_DIR="${TLS_DIR:-/etc/tls/truefoundry}"
TLS_ARGS=()
if [[ -r "$TLS_DIR/tls.crt" && -r "$TLS_DIR/tls.key" && -r "$TLS_DIR/ca.crt" ]]; then
    echo "Using client certificate from $TLS_DIR for the callback"
    # --cacert, not -k: verifying the server is the point of having our own CA, and skipping it would
    # leave the connection open to interception while still handing over our certificate.
    TLS_ARGS=(--cacert "$TLS_DIR/ca.crt" --cert "$TLS_DIR/tls.crt" --key "$TLS_DIR/tls.key")
    # BUILD_CALLBACK_URL may still be http:// even when servicefoundry-server serves HTTPS under mTLS.
    # Upgrade the scheme so curl uses TLS instead of plain HTTP against an HTTPS listener.
    if [[ "$CALLBACK_URL" == http://* ]]; then
        CALLBACK_URL="https://${CALLBACK_URL#http://}"
        echo "Upgraded CALLBACK_URL to https: $CALLBACK_URL"
    fi
elif [[ "$CALLBACK_URL" == https://* ]]; then
    # Worth surfacing: an https callback with no certificate mounted is the exact configuration that
    # fails silently, so say so before curl does.
    echo "Warning: CALLBACK_URL is https but no client certificate found in $TLS_DIR." >&2
    echo "If servicefoundry-server requires mutual TLS, set global.mTLS.enabled=true." >&2
fi

curl --no-progress-meter --show-error -X "PATCH" \
    -H "Content-Type: application/json" \
    -d "$FINAL_PAYLOAD" \
    --retry 3 \
    --retry-delay 10 \
    "${TLS_ARGS[@]}" \
    "$CALLBACK_URL" > /dev/null

echo -n "$status" > /opt/truefoundry/output/buildStatus