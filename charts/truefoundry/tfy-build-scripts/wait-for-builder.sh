#!/bin/bash
set -eu
echo "waiting for builder"

IFS=':' read -r -a BUILDKIT_SERVICE_URL_PARTS <<< "$BUILDKIT_SERVICE_URL"
BUILDKIT_HOST="${BUILDKIT_SERVICE_URL_PARTS[0]}"
BUILDKIT_PORT="${BUILDKIT_SERVICE_URL_PARTS[1]}"

BUILDKIT_TIMEOUT=${1:-120}

######################################################################################
# Test connectivity using nc (netcat) with a timeout of 2 minutes
end=$((SECONDS+$BUILDKIT_TIMEOUT))
# Loop until the timeout is reached
while [ $SECONDS -lt $end ]; do
    # Check if the port is open
    if nc -z "$BUILDKIT_HOST" "$BUILDKIT_PORT"; then
        # If successful, continue with the script
        echo "Port is open. Continuing build..."
        break
    fi
    # Wait for 1 second before trying again
    sleep 1
done
# port is not open after 120 seconds
if [ $SECONDS -ge $end ]; then
    echo echo "Error: Unable to connect to buildkit service at $BUILDKIT_HOST:$BUILDKIT_PORT"
    exit 1
fi
######################################################################################
