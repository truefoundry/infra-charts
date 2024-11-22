#!/bin/bash
set -e -o pipefail

echo "Downloading source code"
mkdir -p /root/.docker/

if [[ -f /root/.truefoundry/.docker/base_config.json ]]; then
    cp /root/.truefoundry/.docker/base_config.json /root/.docker/config.json 
fi

BUILD_TYPE=$(echo "$BUILD_SOURCE" | jq -r '.type')

rm -f -R "$SOURCE_CODE_DOWNLOAD_PATH"

start_time=$(date +%s)
if [[ $BUILD_TYPE == "remote" ]]; then
    REMOTE_URL=$(echo "$BUILD_SOURCE" | jq -r '.remote_uri')
    printf "\033[36m[Start]\033[0m Downloading source code from remote source\n"
    mkdir -p "$SOURCE_CODE_DOWNLOAD_PATH"
    curl -s -o project-files.tar.gz "$REMOTE_URL"
    tar -xf project-files.tar.gz -C "$SOURCE_CODE_DOWNLOAD_PATH"
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
elif [[ $BUILD_TYPE == "git" || $BUILD_TYPE == "github" ]]; then
    GIT_URL=$(echo "$BUILD_SOURCE" | jq -r '.repo_url')
    GIT_REF=$(echo "$BUILD_SOURCE" | jq -r '.ref')

    git config --global url."https://github.com/".insteadOf git@github.com:
    git config --global url."https://".insteadOf git://

    # Example of GIT_URL="https://x-access-token:<token>@github.com/user_name/repo_name"
    # Example of TRIMMED_URL="https://github.com/user_name/repo_name"

    TOKEN=$(echo "$GIT_URL" | sed -n 's/.*x-access-token:\([^@]*\).*/\1/p')
    TRIMMED_URL=$(echo "$GIT_URL" | sed 's~x-access-token:[^@]*@~~')

    printf "\033[36m[Start]\033[0m Downloading source code from %s\n" "$TRIMMED_URL"
    
    # Set auth token

    git config --system credential.helper store
    echo "https://x-access-token:$TOKEN@github.com" > ~/.git-credentials

    git clone --recursive "$TRIMMED_URL" "$SOURCE_CODE_DOWNLOAD_PATH"
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
    git reset --hard "$GIT_REF"
elif [[ $BUILD_TYPE == "bitbucket" ]]; then
    GIT_URL=$(echo "$BUILD_SOURCE" | jq -r '.repo_url')
    GIT_REF=$(echo "$BUILD_SOURCE" | jq -r '.ref')

    git config --global url."https://bitbucket.org/".insteadOf git@bitbucket.org:
    git config --global url."https://".insteadOf git://

    # Example of GIT_URL="https://x-token-auth:<token>@bitbucket.org/user_name/repo_name"
    # Example of TRIMMED_URL="https://bitbucket.org/user_name/repo_name"

    TOKEN=$(echo "$GIT_URL" | sed -n 's/.*x-token-auth:\([^@]*\).*/\1/p')
    TRIMMED_URL=$(echo "$GIT_URL" | sed 's~x-token-auth:[^@]*@~~')

    printf "\033[36m[Start]\033[0m Downloading source code from %s\n" "$TRIMMED_URL"
    
    # Set auth token

    git config --system credential.helper store
    echo "https://x-token-auth:$TOKEN@bitbucket.org" > ~/.git-credentials

    git clone --recurse-submodules "$TRIMMED_URL" "$SOURCE_CODE_DOWNLOAD_PATH"
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
    git reset --hard "$GIT_REF"
elif [[ $BUILD_TYPE == "gitlab" ]]; then
    GIT_URL=$(echo "$BUILD_SOURCE" | jq -r '.repo_url')
    GIT_REF=$(echo "$BUILD_SOURCE" | jq -r '.ref')

    git config --global url."https://gitlab.com/".insteadOf git@gitlab.com:
    git config --global url."https://".insteadOf git://

    # Example of GIT_URL="https://oauth2:<token>@gitlab.com/user_name/repo_name"
    # Example of TRIMMED_URL="https://gitlab.com/user_name/repo_name"

    TOKEN=$(echo "$GIT_URL" | sed -n 's/.*oauth2:\([^@]*\).*/\1/p')
    TRIMMED_URL=$(echo "$GIT_URL" | sed 's~oauth2:[^@]*@~~')

    printf "\033[36m[Start]\033[0m Downloading source code from %s\n" "$TRIMMED_URL"
    
    # Set auth token

    git config --system credential.helper store
    echo "https://oauth2:$TOKEN@gitlab.com" > ~/.git-credentials

    git clone --recurse-submodules "$TRIMMED_URL" "$SOURCE_CODE_DOWNLOAD_PATH"
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
    git reset --hard "$GIT_REF"
elif [[ $BUILD_TYPE == "azure" ]]; then
    GIT_URL=$(echo "$BUILD_SOURCE" | jq -r '.repo_url')
    GIT_REF=$(echo "$BUILD_SOURCE" | jq -r '.ref')

    git config --global url."https://dev.azure.com/".insteadOf git@ssh.dev.azure.com:v3/
    git config --global url."https://".insteadOf git://

    # Example of GIT_URL="https://x-token-auth:<token>@dev.azure.com/organization/project/_git/repo_name"
    # Example of TRIMMED_URL="https://dev.azure.com/organization/project/_git/repo_name"

    TOKEN=$(echo "$GIT_URL" | sed -n 's/.*x-token-auth:\([^@]*\).*/\1/p')
    TRIMMED_URL=$(echo "$GIT_URL" | sed 's~x-token-auth:[^@]*@~~')

    printf "\033[36m[Start]\033[0m Downloading source code from %s\n" "$TRIMMED_URL"
    
    # Set auth token
    git config --system credential.helper store
    echo "https://x-token-auth:$TOKEN@dev.azure.com" > ~/.git-credentials

    git clone --recurse-submodules "$TRIMMED_URL" "$SOURCE_CODE_DOWNLOAD_PATH"
    cd "$SOURCE_CODE_DOWNLOAD_PATH"
    git reset --hard "$GIT_REF"
elif [[ $BUILD_TYPE == "notebook_build" ]]; then
    :
else
    printf "$FAILED_MARKER Source type '%s' not supported.\n" "$BUILD_TYPE"
    exit 1
fi

end_time=$(date +%s)
source_code_download_time=$((end_time - start_time))
echo "Time taken to download the source code: $source_code_download_time seconds"
echo -n "$source_code_download_time" > /opt/truefoundry/output/tfyTimeTakenToDownloadSourceCodeSeconds
printf "$DONE_MARKER Download code completed\n"