#!/bin/bash

set -eu -o pipefail
echo "Building and pushing SOCI index"

PASSWORD=$(echo "$DOCKER_REGISTRY_PASSWORD" | base64 -d)
IMAGE=$DOCKER_REGISTRY_URL/$DOCKER_REPO:$DOCKER_TAG

echo Starting Containerd
containerd > /dev/null 2>&1 &
sleep 3
ctr version > /dev/null

echo "Logging into registry: ${DOCKER_REGISTRY_URL}"
nerdctl login -u "$DOCKER_REGISTRY_USERNAME" -p "$PASSWORD" "$DOCKER_REGISTRY_URL" 2>&1 || { echo "Error: nerdctl login failed, make sure your authentication credentials are correct in registry!" >&2; exit 1; }
echo "Pulling image ${IMAGE}"
time nerdctl pull --unpack false --quiet --platform linux/amd64 "${IMAGE}"
echo "Staging ${IMAGE} for soci conversion for platform: linux/amd64"
nerdctl tag "${IMAGE}" "${IMAGE}-temp"
nerdctl rmi "${IMAGE}"
echo "Creating soci index for ${IMAGE} for platform: linux/amd64"
time soci convert --platform linux/amd64 "${IMAGE}-temp" "${IMAGE}"
echo "Pushing soci index for ${IMAGE} for platform: linux/amd64"
time nerdctl push --quiet --platform linux/amd64 "${IMAGE}"
echo "Removing soci index for ${IMAGE}"
soci index rm --ref "${IMAGE}"
echo "Removing image for ${IMAGE}"
nerdctl rmi "${IMAGE}-temp" "${IMAGE}"
echo "Rebuilding soci database"
soci rebuild-db

echo Done!
