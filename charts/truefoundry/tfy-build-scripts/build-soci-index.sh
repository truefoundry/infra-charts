#!/bin/bash

set -eu -o pipefail
echo "Building and pushing SOCI index"

PASSWORD=$(echo "$DOCKER_REGISTRY_PASSWORD" | base64 -d)
IMAGE=$DOCKER_REGISTRY_URL/$DOCKER_REPO:$DOCKER_TAG


echo Starting Containerd
containerd > /dev/null 2>&1 &
sleep 3
ctr version > /dev/null

echo Pulling Container Image "$IMAGE"

time ctr content fetch -u "$DOCKER_REGISTRY_USERNAME:$PASSWORD" \
--platform=linux/amd64 \
"$IMAGE" > /dev/null


echo Creating Soci Index

time soci create --platform=linux/amd64 "$IMAGE"

echo Pushing Soci Index
time soci push --platform=linux/amd64 "$IMAGE"

echo Done!