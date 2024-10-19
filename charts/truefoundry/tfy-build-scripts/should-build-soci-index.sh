#!/bin/bash

set -eu -o pipefail

echo "Checking if SOCI index should be built."

REGISTRY=$DOCKER_REGISTRY_URL
REPOSITORY=$DOCKER_REPO
TAG=$DOCKER_TAG
IMAGE=$REGISTRY/$REPOSITORY:$TAG
IMAGE_SIZE_THRESHOLD=$(printf '%.0f' "$(echo "$SIZE_THRESHOLD")")

echo Registry is "$REGISTRY"
if [[ $REGISTRY != *"amazonaws.com"* ]]; then
echo Registry is not from ECR. Skipping SOCI index creation.
echo -n "false" > /tmp/result
exit 0
fi

MANFEST=$(docker manifest inspect --verbose "$IMAGE")
IMAGE_SIZE=$(echo "$MANFEST" | jq '.[] | .OCIManifest.layers | .[] | select(.mediaType | contains("oci.image.layer.v1.tar+gzip")) | .size' | awk '{sum+=$0} END{print sum}')
echo Image Size: "$IMAGE_SIZE"
echo Threshold: "$IMAGE_SIZE_THRESHOLD"

if awk -v size="$IMAGE_SIZE" -v threshold="$IMAGE_SIZE_THRESHOLD" 'BEGIN {exit (size < threshold) ? 0 : 1}'; then
    echo "Image size is less than $IMAGE_SIZE_THRESHOLD. Skipping SOCI index creation."
    echo -n "false" > /tmp/result
    exit 0
fi

echo SOCI index will be built and pushed.
echo -n "true" > /tmp/result