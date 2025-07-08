#!/bin/bash
set -e

readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
# Colors and Exit codes
readonly SUCCESS=0 INVALID_PROVIDER=2 MISSING_TOOLS=3 VERSION_ERROR=4

# Tool configurations
declare -a COMMON_TOOLS=("terraform" "kubectl" "helm" "jq")

# Auto-confirm installations when true
AUTO_CONFIRM=false

# Display usage information
show_help() {
    cat << EOF
Usage: $0 [PROVIDER] [CONFIG_FILE] [OPTIONS]

PROVIDER:
  aws, gcp, azure   Cloud provider to use (default: aws)

CONFIG_FILE:
  Path to JSON config file (required)

OPTIONS:
  -y, --yes                  Auto-confirm all installation prompts
  -h, --help                 Show this help message

Example:
  $0 aws config.json -y      Install AWS tools without confirmation
  $0 -y aws config.json      Same as above (order doesn't matter)
EOF
}

# Get required version for a tool
get_tool_required_version() {
    case $1 in
        terraform) echo "1.10.1" ;;
        kubectl) echo "1.31.8" ;;
        helm) echo "3.17.3" ;;
        jq) echo "1.7.1" ;;
        aws) echo "2.17.0" ;;
        gcloud) echo "500.0.0" ;;
        az) echo "2.67.0" ;;
        gke-gcloud-auth-plugin) echo "0.0.1" ;;
        *) echo "0.0.0" ;;  # Default case
    esac
}

# System information
declare OS PACKAGE_MANAGER ARCH

# Logging functions
log() {
    if [ -z "$1" ]; then
        echo -e "$2$3${NC}"
    else
        echo -e "$1 $2$3${NC}"
    fi
}
log_info() { log "$BLUE" "$1"; }
log_debug() {
    if  [ "$TF_DEBUG" = true ]; then
        log "$YELLOW" "$1";
    fi
}
log_success() { log "$GREEN" "$1"; }
log_error() { log "$RED" "$1"; }

# Utility functions
tool_exists() { command -v "$1" >/dev/null 2>&1; }

# Function to check if sudo is available and can be used (only when needed)
check_sudo_if_needed() {
    # Skip sudo check on macOS for brew-installed tools
    if [[ "$OS" == "darwin" ]] && [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        return 0
    fi
    
    if tool_exists sudo; then
        # Check if user has sudo privileges by attempting a harmless command
        if sudo -v 2>/dev/null; then
            log_debug "Sudo access is available"
            return 0
        else
            log_debug "Sudo access check failed"
            return 1
        fi
    else
        log_debug "Sudo command not found"
        return 1
    fi
}

# Function to check if a tool is installed via brew on macOS
is_brew_installed() {
    local tool=$1
    if [[ "$OS" == "darwin" ]] && tool_exists brew; then
        brew list "$tool" &>/dev/null
    else
        return 1
    fi
}

# Function to run command with sudo if available and needed
run_with_sudo() {
    # On macOS with brew, don't use sudo
    if [[ "$OS" == "darwin" ]] && [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        "$@"
        return $?
    fi
    
    # Check sudo only when we need it
    if check_sudo_if_needed; then
        sudo "$@"
    else
        log_error "Root/sudo access required for this operation"
        return 1
    fi
}

confirm_installation() {
    if [ "$AUTO_CONFIRM" = true ]; then
        return 0
    fi
    read -r -p "$(echo -e "${YELLOW}$1 is not installed. Would you like to install it? (Y/n)${NC}") " response
    [[ $response =~ ^[nN] ]] && { log_error "Skipping $1 installation"; return 1; } || return 0
}

# Function to compare versions, returns true if the current version is greater than or equal to the required version
version_compare() {
    local v1=${1#v} v2=${2#v}
    log_debug "Comparing versions: $v1 >= $v2"
    local current_version="$(echo "$v1" | awk -F. '{printf "%d%02d", $1, $2}')"
    local required_version="$(echo "$v2" | awk -F. '{printf "%d%02d", $1, $2}')"
    if [ "$current_version" -ge "$required_version" ]; then
        true
    else
        false
    fi
}

get_cloud_tools() {
    case $1 in
        aws) echo "aws" ;;
        gcp) echo "gcloud gke-gcloud-auth-plugin" ;;
        azure) echo "az" ;;
        *) echo "" ;;  # Return empty for invalid provider
    esac
}

get_essential_tools() {
    case $1 in
        apt-get) echo "wget curl unzip git python3"  ;;
        yum|dnf) echo "wget curl unzip git python3" ;;
        apk) echo "wget curl unzip git python3" ;;
        brew) echo "wget curl unzip git python3" ;;
    esac
}

# System detection
detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* ]]; then
        OS="linux"
        for pm in tdnf apt-get yum dnf apk; do
            if tool_exists "$pm"; then
                PACKAGE_MANAGER="$pm"
                break
            fi
        done
        [[ -z $PACKAGE_MANAGER ]] && { log_error "No supported package manager found"; exit 1; }
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        if ! tool_exists brew; then
            log_info "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add homebrew to PATH for current session
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        fi
        PACKAGE_MANAGER="brew"
    else
        log_error "Unsupported OS: $OSTYPE"; exit 1
    fi

    case "$(uname -m)" in
        x86_64*) ARCH="amd64" ;;
        aarch64*|arm64*) ARCH="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    export OS PACKAGE_MANAGER ARCH
    log_info "System: $OS ($ARCH) using $PACKAGE_MANAGER"
}

# Installation functions
install_essential_utilities() {
    local missing_tools=()
    local tools_list
    tools_list=$(get_essential_tools "$PACKAGE_MANAGER")

    for tool in $tools_list; do
        tool_exists "$tool" || missing_tools+=("$tool")
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_info "Missing utilities: ${missing_tools[*]}"
        if [ "$AUTO_CONFIRM" = true ]; then
            log_info "Auto-installing missing utilities..."
        else
            read -r -p "$(echo -e "${YELLOW}Install missing utilities? (Y/n)${NC}") " response
            if [[ ! $response =~ [yY|Yes|yes|YES] ]]; then
                log_error "Installation skipped - some features may not work"
                return 1
            fi
        fi
        
        log_debug "Installing utilities... ${missing_tools[*]}"
        case $PACKAGE_MANAGER in
            apt-get)
                if ! run_with_sudo apt-get update 2>&1; then
                    log_error "Failed to update package lists"
                    return 1
                fi
                if ! run_with_sudo apt-get install -y "${missing_tools[@]}" 2>&1; then
                    log_error "Failed to install utilities"
                    return 1
                fi
                ;;
            yum|dnf) 
                if ! run_with_sudo "$PACKAGE_MANAGER" update -y 2>&1; then
                    log_error "Failed to update package lists"
                    return 1
                fi
                if ! run_with_sudo "$PACKAGE_MANAGER" install -y -q "${missing_tools[@]}" 2>&1; then
                    log_error "Failed to install utilities"
                    return 1
                fi
                ;;
            apk) 
                if ! run_with_sudo apk update 2>&1; then
                    log_error "Failed to update package lists"
                    return 1
                fi
                if ! run_with_sudo apk add --no-cache --quiet "${missing_tools[@]}"; then
                    log_error "Failed to install utilities"
                    return 1
                fi
                ;;
            brew) 
                if ! brew install --quiet "${missing_tools[@]}" 2>&1; then
                    log_error "Failed to install utilities"
                    return 1
                fi
                ;;
        esac
        log_success "Utilities installed successfully"
    else
        log_success "All required utilities are installed"
    fi
    return 0
}

get_tool_version() {
    local version
    case $1 in
        terraform) version=$(terraform version | head -n1 | cut -d'v' -f2) ;;
        kubectl) version=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | cut -d'v' -f2) ;;
        helm) version=$(helm version --short | cut -d'+' -f1) ;;
        aws) version=$(aws --version 2>&1 | cut -d'/' -f2) ;;
        gcloud) version=$(gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}') ;;
        az) version=$(az version | jq -r '."azure-cli"') ;;
        jq) version=$(jq --version | cut -d'-' -f2) ;;
    esac
    log_debug "Got version for $1: $version"
    echo "$version"
}

# Function to check if upgrade is needed for a tool
upgrade_tool_version() {
    local tool=$1
    local required_version
    local current_version

    required_version=$(get_tool_required_version "$tool")
    current_version=$(get_tool_version "$tool")

    if ! version_compare "$current_version" "$required_version"; then
        log_error "$tool version $current_version found. Version $required_version or higher required"
        true
    else
        false
    fi
}

install_tool() {
    local tool=$1 tmp_dir="$(mktemp -d)"
    pushd "$tmp_dir" > /dev/null
    mkdir -p "$tmp_dir" && cd "$tmp_dir" || exit 1
    log_debug "Installing $tool in temporary directory: $tmp_dir"
    local version
    version=$(get_tool_required_version "$tool")

    case $tool in
        terraform)
            # On macOS, prefer brew installation
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed terraform; then
                    log_debug "Terraform is installed via brew. Using brew to upgrade terraform..."
                    brew upgrade terraform || brew install terraform
                else
                    log_debug "Installing terraform via brew..."
                    brew install terraform
                fi
            else
                log_debug "Downloading terraform version $version"
                wget -q "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${OS}_${ARCH}.zip" -O terraform.zip
                unzip -q terraform.zip && run_with_sudo mv terraform /usr/local/bin/
            fi
            ;;
        kubectl)
            # On macOS, prefer brew installation
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed kubernetes-cli; then
                    log_debug "Kubectl is installed via brew. Using brew to upgrade kubectl..."
                    brew upgrade kubernetes-cli || brew install kubernetes-cli
                else
                    log_debug "Installing kubectl via brew..."
                    brew install kubernetes-cli
                fi
            else
                log_debug "Downloading kubectl version $version"
                wget -q "https://dl.k8s.io/release/v${version}/bin/${OS}/${ARCH}/kubectl" -O kubectl
                chmod +x kubectl && run_with_sudo mv kubectl /usr/local/bin/
            fi
            ;;
        helm)
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed helm; then
                    log_debug "Helm is installed via brew. Using brew to upgrade helm..."
                    brew upgrade helm || brew install helm
                else
                    log_debug "Installing helm via brew..."
                    brew install helm
                fi
            else
                log_debug "Downloading helm version $version"
                wget -q "https://get.helm.sh/helm-v${version}-${OS}-${ARCH}.tar.gz" -O helm.tar.gz
                tar -zxf helm.tar.gz && run_with_sudo mv "${OS}-${ARCH}/helm" /usr/local/bin/
            fi
            ;;
        aws)
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed awscli; then
                    log_debug "AWS CLI is installed via brew. Using brew to upgrade awscli..."
                    brew upgrade awscli || brew install awscli
                else
                    log_debug "Installing AWS CLI via brew..."
                    brew install awscli
                fi
            else
                case $OS in
                    linux)
                        if [[ "$ARCH" == "arm64" ]]; then
                            curl -s "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
                        else
                            curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        fi
                        unzip -q awscliv2.zip && run_with_sudo ./aws/install --update
                        rm -rf aws awscliv2.zip
                        ;;
                esac
            fi
            ;;
        gcloud)
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed google-cloud-sdk; then
                    log_debug "Google Cloud SDK is installed via brew. Using brew to upgrade..."
                    brew upgrade google-cloud-sdk || brew install google-cloud-sdk
                else
                    log_debug "Installing Google Cloud SDK via brew..."
                    brew install google-cloud-sdk
                fi
            else
                case $OS in
                    linux|darwin)
                        # Download and install from archive
                        local gcloud_archive install_dir
                        install_dir="$HOME/.google-cloud-sdk"

                        if [[ "$ARCH" == "arm64" ]]; then
                            gcloud_archive="google-cloud-cli-${OS}-arm.tar.gz"
                        else
                            gcloud_archive="google-cloud-cli-${OS}-x86_64.tar.gz"
                        fi

                        log_debug "Downloading gcloud archive: $gcloud_archive"
                        curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${gcloud_archive}"
                        tar -xf "$gcloud_archive"
                        rm -f "$gcloud_archive"

                        # Move to install directory if it doesn't exist
                        if [[ ! -d "$install_dir" ]]; then
                            mv google-cloud-sdk "$install_dir"
                        else
                            rm -rf google-cloud-sdk
                        fi

                        # Run install script with appropriate flags
                        "$install_dir/install.sh" --quiet --command-completion true --path-update true --usage-reporting false --rc-path "$HOME/.$(basename "$SHELL")rc"

                        # Add to PATH for immediate use
                        export PATH="$install_dir/bin:$PATH"

                        log_info "The installer has updated your shell configuration. You may need to restart your shell or source your rc file."
                        ;;
                esac
            fi
            # Skip initialization as it requires user interaction
            log_debug "Skipping gcloud init as it requires user interaction. Please run 'gcloud init' manually after installation."
            ;;
        az)
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed azure-cli; then
                    log_debug "Azure CLI is installed via brew. Using brew to upgrade..."
                    brew upgrade azure-cli || brew install azure-cli
                else
                    log_debug "Installing Azure CLI via brew..."
                    brew install azure-cli
                fi
            else
                case $OS in
                    linux)
                        case $PACKAGE_MANAGER in
                            apt-get)
                                curl -sL https://aka.ms/InstallAzureCLIDeb | run_with_sudo bash
                                ;;
                            yum|dnf)
                                # Import Microsoft repository key
                                run_with_sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

                                # Add Azure CLI repository
                                run_with_sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm

                                # Install Azure CLI
                                run_with_sudo "$PACKAGE_MANAGER" install -y azure-cli
                                ;;
                            *)
                                log_error "Unsupported package manager for Azure CLI installation"
                                return 1
                                ;;
                        esac
                        ;;
                esac
            fi
            ;;
        jq)
            if [[ "$OS" == "darwin" ]]; then
                if is_brew_installed jq; then
                    log_debug "jq is installed via brew. Using brew to upgrade..."
                    brew upgrade jq || brew install jq
                else
                    log_debug "Installing jq via brew..."
                    brew install jq
                fi
            else
                case $OS in
                    linux)
                        case $PACKAGE_MANAGER in
                            apt-get) run_with_sudo apt-get update && run_with_sudo apt-get install -y jq ;;
                            yum|dnf) run_with_sudo "$PACKAGE_MANAGER" install -y jq ;;
                            apk) run_with_sudo apk add --no-cache jq ;;
                        esac
                        ;;
                esac
            fi
            ;;
        gke-gcloud-auth-plugin)
            tool_exists gcloud || { log_error "gcloud must be installed first"; return 1; }
            gcloud components install gke-gcloud-auth-plugin
            ;;
    esac

    popd > /dev/null && rm -rf "$tmp_dir"
    log_debug "Finished installing $tool"
}

# Simple function to verify and install tools (checks first, then installs if needed)
verify_tools() {
    log_debug "Verifying tools..."
    local cloud_provider=$1
    local missing_tools=()
    local install_failed=()

    # Step 1: Check what's missing (NO SUDO)
    log_info "Checking tool requirements..."
    
    # Check common tools
    for tool in "${COMMON_TOOLS[@]}"; do
        if ! tool_exists "$tool"; then
            missing_tools+=("$tool")
        elif upgrade_tool_version "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    # Check cloud-specific tools
    read -r -a cloud_tools <<< "$(get_cloud_tools "$cloud_provider")"
    for tool in "${cloud_tools[@]}"; do
        if ! tool_exists "$tool"; then
            missing_tools+=("$tool")
        elif upgrade_tool_version "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    # Step 2: Install if needed (SUDO only when installing)
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_info "Tools need installation/upgrade: ${missing_tools[*]}"
        
        for tool in "${missing_tools[@]}"; do
            if confirm_installation "$tool"; then
                log_info "Installing/upgrading $tool..."
                if ! install_tool "$tool"; then
                    log_error "Failed to install $tool"
                    install_failed+=("$tool")
                fi
            else
                log_error "Skipping $tool installation"
                install_failed+=("$tool")
            fi
        done
    else
        log_success "All required tools are already installed and up to date"
    fi

    # Check for failures
    if [ ${#install_failed[@]} -ne 0 ]; then
        log_error "Failed to install tools: ${install_failed[*]}"
        log_error "Cannot proceed without these tools."
        return $MISSING_TOOLS
    fi

    log_success "All tools verified and installed"
    return $SUCCESS
}



create_backend() {
    local cloud_provider=$1
    local manifest_inputs
    if ! manifest_inputs=$(cat "$2"); then
        log_error "Failed to read config file: $2"
        return 1
    fi
    log_debug "Processing backend configuration from: $2"
    log_info "Creating backend infrastructure for $cloud_provider"

    case $cloud_provider in
        aws)
            export AWS_PAGER=""
            local bucket_name region auth_type dynamodb_table
            bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket_name')
            region=$(echo "$manifest_inputs" | jq -r '.manifest.region')
            auth_type=$(echo "$manifest_inputs" | jq -r '.manifest.auth.type')
            dynamodb_table=$(echo "$manifest_inputs" | jq -r '.manifest.backend.dynamodb_table')

            log_debug "Backend configuration:"
            log_debug "  Bucket: $bucket_name"
            log_debug "  Region: $region"
            log_debug "  Auth Type: $auth_type"
            log_debug "  DynamoDB Table: $dynamodb_table"

            log_info "Configuring AWS authentication"
            
            # Check if we already have working AWS credentials (e.g., CloudShell, EC2 instance role)
            if aws sts get-caller-identity >/dev/null 2>&1; then
                local caller_identity
                caller_identity=$(aws sts get-caller-identity --output text --query 'Arn' 2>/dev/null)
                log_success "AWS credentials already available: $caller_identity"
                log_info "Skipping profile configuration (using existing credentials)"
            elif [[ $auth_type == "profile" ]]; then
                local profile
                profile=$(echo "$manifest_inputs" | jq -r '.manifest.auth.profile')
                
                # Handle case where profile might be null/empty but we want to try anyway
                if [[ -z "$profile" || "$profile" == "null" ]]; then
                    log_debug "No profile specified, attempting default credentials"
                else
                    log_debug "Using AWS profile: $profile"
                    export AWS_PROFILE="$profile"
                fi
                
                # Verify AWS credentials
                if ! aws sts get-caller-identity >/dev/null 2>&1; then
                    log_error "AWS authentication failed with profile '${profile:-default}'."
                    log_error "Please check:"
                    log_error "  1. Profile exists: aws configure list-profiles"
                    log_error "  2. If using SSO: aws sso login --profile '${profile:-default}'"
                    log_error "  3. Profile configuration: aws configure list"
                    return 1
                fi
                log_success "AWS authentication successful using profile: ${profile:-default}"
            else
                log_debug "Using AWS access key authentication"
                local access_key secret_key
                access_key=$(echo "$manifest_inputs" | jq -r '.manifest.auth.access_key')
                secret_key=$(echo "$manifest_inputs" | jq -r '.manifest.auth.secret_key')
                export AWS_ACCESS_KEY_ID="$access_key"
                export AWS_SECRET_ACCESS_KEY="$secret_key"
                # Verify AWS credentials
                if ! aws sts get-caller-identity >/dev/null 2>&1; then
                    log_error "AWS authentication failed. Please check your access key and secret"
                    return 1
                fi
                log_success "AWS authentication successful using access key"
            fi

            log_info "Creating S3 bucket for Terraform state"
            log_info "Checking if bucket exists $bucket_name"
            log_debug "Running: aws s3api head-bucket --bucket $bucket_name --region $region"
            if ! aws s3api head-bucket --bucket "$bucket_name" --region "$region" 2>/dev/null; then
                log_info "Creating S3 bucket: $bucket_name"
                if [[ $region == "us-east-1" ]]; then
                    if ! aws s3api create-bucket --bucket "$bucket_name" --region "$region"; then
                        log_error "Failed to create S3 bucket"
                        return 1
                    fi
                else
                    if ! aws s3api create-bucket --bucket "$bucket_name" --region "$region" \
                        --create-bucket-configuration LocationConstraint="$region"; then
                        log_error "Failed to create S3 bucket"
                        return 1
                    fi
                fi
                log_success "Created S3 bucket: $bucket_name"
            else
                log_info "S3 bucket already exists: $bucket_name"
            fi

            if [[ $dynamodb_table != "null" ]]; then
                log_info "Creating DynamoDB table for state locking"
                if ! aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" >/dev/null 2>&1; then
                    log_info "Creating DynamoDB table: $dynamodb_table"
                    if ! aws dynamodb create-table \
                        --table-name "$dynamodb_table" \
                        --attribute-definitions AttributeName=LockID,AttributeType=S \
                        --key-schema AttributeName=LockID,KeyType=HASH \
                        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
                        --region "$region"; then
                        log_error "Failed to create DynamoDB table $dynamodb_table in region $region"
                        return 1
                    fi
                    log_success "Created DynamoDB table: $dynamodb_table"
                else
                    log_info "DynamoDB table already exists: $dynamodb_table"
                fi
            fi
            ;;
        gcp)
            local bucket_name region
            bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket')
            region=$(echo "$manifest_inputs" | jq -r '.manifest.region')
            log_debug "GCP Backend configuration:"
            log_debug "  Bucket: $bucket_name"
            log_debug "  Region: $region"
            if ! gcloud storage buckets describe "gs://$bucket_name" >/dev/null 2>&1; then
                log_info "Creating GCS bucket $bucket_name"
                if ! gcloud storage buckets create "gs://$bucket_name" --location="$region"; then
                    log_error "Failed to create GCS bucket"
                    return 1
                fi
                log_success "Created GCS bucket: $bucket_name"
            else
                log_info "GCS bucket already exists: $bucket_name"
            fi
            ;;
        azure)
            local resource_group storage_account container_name location
            resource_group=$(echo "$manifest_inputs" | jq -r '.manifest.backend.resource_group_name')
            storage_account=$(echo "$manifest_inputs" | jq -r '.manifest.backend.storage_account_name')
            container_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.container_name')
            location=$(echo "$manifest_inputs" | jq -r '.manifest.location')
            log_debug "Azure Backend configuration:"
            log_debug "  Resource Group: $resource_group"
            log_debug "  Storage Account: $storage_account"
            log_debug "  Container: $container_name"
            log_debug "  Location: $location"
            
            # Create resource group if needed
            if ! az group show --name "$resource_group" >/dev/null 2>&1; then
                log_info "Creating resource group $resource_group"
                if ! az group create --name "$resource_group" --location "$location"; then
                    log_error "Failed to create resource group"
                    return 1
                fi
                log_success "Created resource group: $resource_group"
            else
                log_info "Resource group already exists: $resource_group"
            fi

            # Create storage account if needed
            if ! az storage account show --name "$storage_account" --resource-group "$resource_group" >/dev/null 2>&1; then
                log_info "Creating storage account $storage_account"
                if ! az storage account create \
                    --name "$storage_account" \
                    --resource-group "$resource_group" \
                    --location "$location" \
                    --sku Standard_LRS; then
                    log_error "Failed to create storage account"
                    return 1
                fi
                log_success "Created storage account: $storage_account"
            else
                log_info "Storage account already exists: $storage_account"
            fi

            # Create container if needed
            if ! az storage container show --name "$container_name" --account-name "$storage_account" >/dev/null 2>&1; then
                log_info "Creating storage container $container_name"
                if ! az storage container create --name "$container_name" --account-name "$storage_account"; then
                    log_error "Failed to create storage container"
                    return 1
                fi
                log_success "Created storage container: $container_name"
            else
                log_info "Storage container already exists: $container_name"
            fi
            ;;
    esac
    return 0
}

display_installed_versions() {
    local cloud_provider=$1
    log_info "Checking installed tools:"

    local all_ok=true
    # Display common tools
    log "" "$BLUE" "\nCore Tools:"
    for tool in "${COMMON_TOOLS[@]}"; do
        if tool_exists "$tool"; then
            local version required_version
            version=$(get_tool_version "$tool")
            required_version=$(get_tool_required_version "$tool")
            if version_compare "$version" "$required_version"; then
                log "" "$GREEN" "  ✓ $tool $version"
            else
                log "" "$YELLOW" "  ! $tool $version (min: $required_version)"
                all_ok=false
            fi
        else
            log "" "$RED" "  ✗ $tool (not installed)"
            all_ok=false
        fi
    done

    # Display cloud-specific tools
    if [ "$cloud_provider" != "generic" ]; then
        read -r -a cloud_tools <<< "$(get_cloud_tools "$cloud_provider")"
        for tool in "${cloud_tools[@]}"; do
            if [ "$tool" == "gke-gcloud-auth-plugin" ]; then
                continue
            fi
            if tool_exists "$tool"; then
                local version required_version
                version=$(get_tool_version "$tool")
                required_version=$(get_tool_required_version "$tool")
                if version_compare "$version" "$required_version"; then
                    log "" "$GREEN" "  ✓ $tool $version"
                else
                    log "" "$YELLOW" "  ! $tool $version (min: $required_version)"
                    all_ok=false
                fi
            else
                log "" "$RED" "  ✗ $tool (not installed)"
                all_ok=false
            fi
        done
    fi
    echo

    if [ "$all_ok" = true ]; then
        log_success "All required tools are properly installed"
    else
        log_error "Some tools need attention"
    fi
}

# Main execution
main() {
    log_debug "Starting script with arguments: $*"

    # Parse arguments
    cloud_provider="aws"  # Default to AWS
    config_file=""
    positional_args=()

    # Process all arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                AUTO_CONFIRM=true
                log_debug "Auto-confirm enabled"
                shift
                ;;
            -h|--help)
                show_help
                exit $SUCCESS
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit $INVALID_PROVIDER
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done

    # Restore positional arguments for processing
    set -- "${positional_args[@]}"

    # Process positional arguments
    if [ $# -eq 0 ]; then
        log_info "No cloud provider specified, using AWS as default"
    elif [ $# -eq 1 ]; then
        cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        log_error "Config file is required for $cloud_provider provider"
        log_info "Run with --help for usage information"
        exit $INVALID_PROVIDER
    elif [ $# -ge 2 ]; then
        cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        config_file=$2

        # Check if config file exists and is readable
        if [ ! -f "$config_file" ]; then
            log_error "Config file not found: $config_file"
            exit $INVALID_PROVIDER
        fi
        log_debug "Using cloud provider: $cloud_provider"
        log_debug "Config file: $config_file"
    fi

    # Validate cloud provider
    case $cloud_provider in
        "aws"|"gcp"|"azure")
            log_info "Checking prerequisites for $cloud_provider deployment"
            ;;
        *)
            log_error "Invalid cloud provider: $cloud_provider"
            log_info "Run with --help for usage information"
            exit $INVALID_PROVIDER
            ;;
    esac

    # Step 1: Detect system
    log_info "Step 1: Detecting system configuration..."
    detect_system
    log_success "System detection complete"

    # Step 2: Install essential utilities
    log_info "Step 2: Installing essential utilities..."
    if ! install_essential_utilities; then
        log_error "Failed to install essential utilities. Cannot proceed."
        exit $MISSING_TOOLS
    fi
    log_success "Essential utilities installation complete"

    # Step 3: Verify tools (checks first, then installs if needed)
    log_info "Step 3: Verifying required tools..."
    verify_tools "$cloud_provider"
    local verify_status=$?
    if [ $verify_status -ne $SUCCESS ]; then
        log_error "Tool verification failed. Cannot proceed to backend setup."
        exit $verify_status
    fi
    log_success "Tool verification complete"

    # Step 4: Create backend (required for all providers)
    if [ -n "$config_file" ]; then
        log_info "Step 4: Setting up backend storage for $cloud_provider..."
        if ! create_backend "$cloud_provider" "$config_file"; then
            log_error "Failed to create backend storage. Deployment may fail."
            exit 1
            return 1
        fi
        log_success "Backend storage setup complete"
    else
        log_error "Config file is required for backend setup"
        exit $INVALID_PROVIDER
    fi

    # Display final summary
    display_installed_versions "$cloud_provider"

    # Reload shell notice
    if [ "$cloud_provider" == "gcp" ] && [ "$verify_status" -eq $SUCCESS ]; then
        echo -e "\n${BLUE}Action Required:${NC}"
        echo -e "Run the following command to update your shell environment:"
        echo -e "    ${GREEN}exec -l $SHELL${NC}\n"
    fi

    exit $SUCCESS
}

main "$@"
