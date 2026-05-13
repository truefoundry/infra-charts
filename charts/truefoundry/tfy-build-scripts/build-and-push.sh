#!/bin/bash
set -eu

# This script requires the following environment variables to be set:
# - DOCKER_REGISTRY_URL
# - DOCKER_REPO
# - DOCKER_TAG
# - SOURCE_CODE_DOWNLOAD_PATH
#
# Optional:
# - DOCKER_REGISTRY_INSECURE=true  BuildKit registry.insecure (plain HTTP or TLS verify skip). Use when the
#   registry URL uses https:// but only speaks HTTP, or for self-signed HTTPS.

printf "\033[36m[Start]\033[0m Building and pushing the docker container. Please find the logs below\n"

_REGISTRY=$(echo "${DOCKER_REGISTRY_URL}" | sed -e 's~http[s]*://~~g')
IMAGE="$_REGISTRY/$DOCKER_REPO"

# Image refs omit the scheme; BuildKit defaults to HTTPS. Plain-HTTP registries then fail with:
# "http: server gave HTTP response to HTTPS client". registry.insecure=true enables insecure registry access
# (HTTP or self-signed HTTPS) for image push and registry cache import/export.
REGISTRY_INSECURE_OPTS=""
if [[ "${DOCKER_REGISTRY_URL}" == http://* ]] || [[ "${DOCKER_REGISTRY_INSECURE:-}" == "true" ]]; then
  REGISTRY_INSECURE_OPTS=",registry.insecure=true"
fi
TAG=$DOCKER_TAG
BUILDKIT_CERTS_PATH="/etc/buildkit/certs"

printf "\033[36m[==== Docker logs start ====]\033[0m\n"

BUILDX_CREATE_ARGS="--name remote-kubernetes --driver remote tcp://${BUILDKIT_SERVICE_URL}"

if [[ -d "$BUILDKIT_CERTS_PATH" ]]; then
    BUILDX_CREATE_ARGS="${BUILDX_CREATE_ARGS} --driver-opt key=${BUILDKIT_CERTS_PATH}/key.pem,cert=${BUILDKIT_CERTS_PATH}/cert.pem,cacert=${BUILDKIT_CERTS_PATH}/ca.pem"
fi

docker buildx create ${BUILDX_CREATE_ARGS}

if [ -d "$SOURCE_CODE_DOWNLOAD_PATH" ]; then
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
fi

# Here we are eval-ing because BUILD_CONFIG is already shlex quoted, so by eval-ing first we want to shlex unquote it
# And then when calling tfy build, we pass it in quotes so that bash will take care of correctly quoting it
eval "BUILD_CONFIG_CORRECTED=$(echo $BUILD_CONFIG)"
build_secrets=$(echo "$TFY_BUILD_SECRETS" | jq -r '.[] | "--secret id=" + .id + ",src=/truefoundry-build-secrets/" + .id')

start_time=$(date +%s)
tfy build $build_secrets --build-config="$BUILD_CONFIG_CORRECTED" --name="${IMAGE}:$DOCKER_TAG" --tag="${IMAGE}:$DOCKER_TAG" --tag="${IMAGE}:latest" --cache-to="type=registry,ref=${IMAGE}:cache-latest,image-manifest=true,mode=max${REGISTRY_INSECURE_OPTS}" --cache-from=type=registry,ref="${IMAGE}:cache-latest${REGISTRY_INSECURE_OPTS}" --build-context tfy-secrets=/var/run/secrets/ --builder=remote-kubernetes --output=type=image,push=true,compression=gzip,compression-level=0,force-compression=true${REGISTRY_INSECURE_OPTS}
end_time=$(date +%s)
build_time=$((end_time - start_time))
echo "Time taken to build the image: $build_time seconds"
echo -n "$build_time" > /opt/truefoundry/output/tfyTimeTakenToBuildImageSeconds

# Please don't remove this log line or make any edits since the clients depend on the string matching of this log to disconnect the WebSocket connection.
printf "\033[36m[==== Docker logs end ====]\033[0m\n"
printf "$DONE_MARKER Docker image built and pushed\n"