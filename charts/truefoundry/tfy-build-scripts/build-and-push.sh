#!/bin/bash
set -eu

# This script requires the following environment variables to be set:
# - DOCKER_REGISTRY_URL
# - DOCKER_REPO
# - DOCKER_TAG
# - SOURCE_CODE_DOWNLOAD_PATH

printf "\033[36m[Start]\033[0m Building and pushing the docker container. Please find the logs below\n"

IMAGE="$DOCKER_REGISTRY_URL/$DOCKER_REPO"
TAG=$DOCKER_TAG

printf "\033[36m[==== Docker logs start ====]\033[0m\n"

docker buildx create --name remote-kubernetes --driver remote tcp://"$BUILDKIT_SERVICE_URL"

if [ -d "$SOURCE_CODE_DOWNLOAD_PATH" ]; then
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
fi

# Here we are eval-ing because BUILD_CONFIG is already shlex quoted, so by eval-ing first we want to shlex unquote it
# And then when calling tfy build, we pass it in quotes so that bash will take care of correctly quoting it
eval "BUILD_CONFIG_CORRECTED=$(echo $BUILD_CONFIG)"
build_secrets=$(echo "$TFY_BUILD_SECRETS" | jq -r '.[] | "--secret id=" + .id + ",src=/truefoundry-build-secrets/" + .id')

start_time=$(date +%s)
tfy build $build_secrets --build-config="$BUILD_CONFIG_CORRECTED" --name="${IMAGE}:$DOCKER_TAG" --tag="${IMAGE}:$DOCKER_TAG" --tag="${IMAGE}:latest" --cache-to="type=registry,ref=${IMAGE}:cache-latest,image-manifest=true,mode=max" --cache-from=type=registry,ref="${IMAGE}:cache-latest" --build-context tfy-secrets=/var/run/secrets/ --builder=remote-kubernetes --output=type=image,push=true,compression=gzip,compression-level=0,force-compression=true 
end_time=$(date +%s)
build_time=$((end_time - start_time))
echo "Time taken to build the image: $build_time seconds"
echo -n "$build_time" > /opt/truefoundry/output/tfyTimeTakenToBuildImageSeconds

printf "\033[36m[==== Docker logs end ====]\033[0m\n"
printf "%s Docker image built and pushed\n" "$DONE_MARKER"