#!/bin/bash
set -eu

echo "Logging into registry: $DOCKER_REGISTRY_URL"
DOCKER_PASSWORD=$(echo "$DOCKER_REGISTRY_PASSWORD" | base64 -d)


# if $REGISTRY starts with "index.docker.io" or "docker.io"
# then skip mentioning url in docker login, because these do not follow distribution v2
# This is a short term fix till we decouple registry url and login url
_REGISTRY=$(echo "${DOCKER_REGISTRY_URL}" | sed -e 's~http[s]*://~~g')
if [[ $DOCKER_PASSWORD == '' ]]; then
    echo "Registry password is empty, skipping registry login"
    exit 0
elif [[ $_REGISTRY == index.docker.io* ]] || [[ $_REGISTRY == docker.io* ]]; then
    docker login -u "$DOCKER_REGISTRY_USERNAME" -p "${DOCKER_PASSWORD}" 2>&1 || { echo "Error: Docker login failed, make sure your authentication credentials are correct in registry!" >&2; exit 1; }
else
    docker login -u "$DOCKER_REGISTRY_USERNAME" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY_URL}" 2>&1 || { echo "Error: Docker login failed, make sure your authentication credentials are correct in registry!" >&2; exit 1; }
fi