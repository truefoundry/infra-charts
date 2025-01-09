#!/bin/bash
set -e 

readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
# Colors and Exit codes
readonly SUCCESS=0 INVALID_PROVIDER=2 MISSING_TOOLS=3 VERSION_ERROR=4

# Tool configurations
declare -a COMMON_TOOLS=("terraform" "kubectl" "helm" "jq")

# Get required version for a tool
get_tool_required_version() {
    case $1 in
        terraform) echo "1.9.0" ;;
        kubectl) echo "1.28.0" ;;
        helm) echo "3.16.0" ;;
        jq) echo "1.7.1" ;;
        aws) echo "2.17.0" ;;
        gcloud) echo "500.0.0" ;;
        az) echo "2.67.0" ;;
        gke-gcloud-auth-plugin) echo "0.0.1" ;;
        *) echo "0.0.0" ;;  # Default case
    esac
}

# System information
declare OS PACKAGE_MANAGER ARCH HAS_SUDO

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

# Function to check if sudo is available and can be used
check_sudo() {
    if tool_exists sudo; then
        # Check if user has sudo privileges by attempting a harmless command
        if sudo -n true 2>/dev/null; then
            HAS_SUDO=true
            log_debug "Sudo access is available"
        else
            log_debug "Sudo access check failed"
        fi
    else
        log_debug "Sudo command not found"
    fi
    HAS_SUDO=false
}

# Function to run command with sudo if available
run_with_sudo() {
    if [ "$HAS_SUDO" = true ]; then
        sudo "$@"
    else
        "$@"
    fi
}

confirm_installation() {
    read -r -p "$(echo -e "${YELLOW}$1 is not installed. Would you like to install it? (Y/n)${NC}") " response
    [[ $response =~ ^[nN] ]] && { log_error "Skipping $1 installation"; return 1; } || return 0
}

version_compare() {
    local v1=${1#v} v2=${2#v}
    log_debug "Comparing versions: $v1 >= $v2"
    [ "$(echo "$v1" | awk -F. '{printf "%d%02d", $1, $2}')" -ge "$(echo "$v2" | awk -F. '{printf "%d%02d", $1, $2}')" ]
}

get_cloud_tools() {
    case $1 in
        aws) echo "aws" ;;
        gcp) echo "gcloud gke-gcloud-auth-plugin" ;;
        azure) echo "az" ;;
        generic|"") echo "" ;;  # Return empty for generic/default case
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
    check_sudo
    log_debug "System check: sudo=$HAS_SUDO"

    if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* ]]; then
        OS="linux"
        for pm in apt-get yum dnf apk; do
            if tool_exists "$pm"; then
                PACKAGE_MANAGER="$pm"
                [[ $pm == "apk" ]] && OS="alpine"
                break
            fi
        done
        [[ -z $PACKAGE_MANAGER ]] && { log_error "No supported package manager found"; exit 1; }
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        tool_exists brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
        read -r -p "$(echo -e "${YELLOW}Install missing utilities? (Y/n)${NC}") " response
        if [[ ! $response =~ ^[nN] ]]; then
            log_debug "Installing utilities... ${missing_tools[*]}"
            case $PACKAGE_MANAGER in
                apt-get) 
                    run_with_sudo apt-get update 2>&1
                    run_with_sudo apt-get install -y "${missing_tools[@]}" 2>&1
                    ;;
                yum|dnf) run_with_sudo "$PACKAGE_MANAGER" install -y -q "${missing_tools[@]}" 2>&1 ;;
                apk) run_with_sudo apk update 2>&1 && run_with_sudo apk add --no-cache --quiet "${missing_tools[@]}" ;;
                brew) brew install --quiet "${missing_tools[@]}" 2>&1 ;;
            esac
            log_success "Utilities installed successfully"
        else
            log_error "Installation skipped - some features may not work"
            return 1
        fi
    else
        log_success "All required utilities are installed"
    fi
}

get_tool_version() {
    local version
    case $1 in
        terraform) version=$(terraform version | head -n1 | cut -d'v' -f2) ;;
        kubectl) version=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | cut -d'v' -f2) ;;
        helm) version=$(helm version --short | cut -d'v' -f2) ;;
        aws) version=$(aws --version 2>&1 | cut -d'/' -f2) ;;
        gcloud) version=$(gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}') ;;
        az) version=$(az version | jq -r '."azure-cli"') ;;
        jq) version=$(jq --version | cut -d'-' -f2) ;;
    esac
    log_debug "Got version for $1: $version"
    echo "$version"
}

verify_tool_version() {
    local tool=$1
    local required_version
    local current_version
    
    required_version=$(get_tool_required_version "$tool")
    current_version=$(get_tool_version "$tool")
    
    version_compare "$current_version" "$required_version" || \
        log_error "$tool version $current_version found. Version $required_version or higher required"
}

install_tool() {
    local tool=$1 tmp_dir="/tmp/tool-install"
    mkdir -p "$tmp_dir" && cd "$tmp_dir" || exit 1
    log_debug "Installing $tool in temporary directory: $tmp_dir"
    local version
    version=$(get_tool_required_version "$tool")

    case $tool in
        terraform)
            log_debug "Downloading terraform version $version"
            wget -q "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${OS}_${ARCH}.zip" -O terraform.zip
            unzip -q terraform.zip && run_with_sudo mv terraform /usr/local/bin/
            ;;
        kubectl)
            log_debug "Downloading kubectl version $version"
            wget -q "https://dl.k8s.io/release/v${version}/bin/${OS}/${ARCH}/kubectl" -O kubectl
            chmod +x kubectl && run_with_sudo mv kubectl /usr/local/bin/
            ;;
        helm)
            log_debug "Downloading helm version $version"
            wget -q "https://get.helm.sh/helm-v${version}-${OS}-${ARCH}.tar.gz" -O helm.tar.gz
            tar -zxf helm.tar.gz && run_with_sudo mv "${OS}-${ARCH}/helm" /usr/local/bin/
            ;;
        aws)
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
                darwin)
                    curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                    run_with_sudo installer -pkg AWSCLIV2.pkg -target /
                    rm -f AWSCLIV2.pkg
                    ;;
            esac
            ;;
        gcloud)
            case $OS in
                linux) 
                    # Download and install from archive for all Linux systems
                    local gcloud_archive
                    if [[ "$ARCH" == "arm64" ]]; then
                        gcloud_archive="google-cloud-cli-linux-arm.tar.gz"
                    else
                        gcloud_archive="google-cloud-cli-linux-x86_64.tar.gz"
                    fi
                    
                    curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${gcloud_archive}"
                    tar -xf "$gcloud_archive"
                    rm -f "$gcloud_archive"
                    
                    # Install to system-wide location
                    run_with_sudo rm -rf /usr/local/google-cloud-sdk
                    run_with_sudo mv google-cloud-sdk /usr/local/
                    
                    # Run install script with appropriate flags
                    /usr/local/google-cloud-sdk/install.sh --quiet --command-completion true --path-update true --usage-reporting false --rc-path "$HOME/.bashrc" 
                    
                    # Add to system-wide PATH
                    echo 'export PATH=/usr/local/google-cloud-sdk/bin:$PATH' | run_with_sudo tee /etc/profile.d/gcloud.sh
                    
                    # Add to current session
                    export PATH=/usr/local/google-cloud-sdk/bin:$PATH
                    ;;
                darwin) 
                    # Download and install from archive for macOS
                    local gcloud_archive
                    if [[ "$ARCH" == "arm64" ]]; then
                        gcloud_archive="google-cloud-cli-darwin-arm.tar.gz"
                    else
                        gcloud_archive="google-cloud-cli-darwin-x86_64.tar.gz"
                    fi
                    
                    curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${gcloud_archive}"
                    tar -xf "$gcloud_archive"
                    rm -f "$gcloud_archive"
                    
                    # Install to system-wide location
                    run_with_sudo rm -rf /usr/local/google-cloud-sdk
                    run_with_sudo mv google-cloud-sdk /usr/local/
                    
                    # Add to system-wide PATH
                    echo 'export PATH=/usr/local/google-cloud-sdk/bin:$PATH' | run_with_sudo tee /etc/profile.d/gcloud.sh
                    
                    # Add to current session
                    export PATH=/usr/local/google-cloud-sdk/bin:$PATH
                    ;;
            esac
            # Skip initialization as it requires user interaction
            log_debug "Skipping gcloud init as it requires user interaction. Please run 'gcloud init' manually after installation."
            log_info "You may need to restart your shell or source your shell's rc file to use gcloud in new sessions"
            ;;
        az)
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
                darwin)
                    brew install azure-cli
                    ;;
            esac
            ;;
        jq)
            case $OS in
                linux)
                    case $PACKAGE_MANAGER in
                        apt-get) run_with_sudo apt-get update && run_with_sudo apt-get install -y jq ;;
                        yum|dnf) run_with_sudo "$PACKAGE_MANAGER" install -y jq ;;
                        apk) run_with_sudo apk add --no-cache jq ;;
                    esac
                    ;;
                darwin) brew install jq ;;
            esac
            ;;
        gke-gcloud-auth-plugin)
            tool_exists gcloud || { log_error "gcloud must be installed first"; return 1; }        
            gcloud components install gke-gcloud-auth-plugin
            ;;
    esac

    cd - > /dev/null && rm -rf "$tmp_dir"
    log_debug "Finished installing $tool"
}

verify_tools() {
    local cloud_provider=$1
    local missing_tools=()
    local install_failed=()
    
    # Check common tools
    for tool in "${COMMON_TOOLS[@]}"; do
        if ! tool_exists "$tool"; then
            if confirm_installation "$tool"; then
                install_tool "$tool" || install_failed+=("$tool")
            else
                missing_tools+=("$tool")
            fi
        elif ! verify_tool_version "$tool"; then
            return $VERSION_ERROR
        fi
    done

    # Check cloud-specific tools
    read -r -a cloud_tools <<< "$(get_cloud_tools "$cloud_provider")"
    for tool in "${cloud_tools[@]}"; do
        if ! tool_exists "$tool"; then
            if confirm_installation "$tool"; then
                install_tool "$tool" || install_failed+=("$tool")
            else
                missing_tools+=("$tool")
            fi
        elif ! verify_tool_version "$tool"; then
            return $VERSION_ERROR
        fi
    done

    [ ${#missing_tools[@]} -ne 0 ] && {
        log_error "Tools not installed (skipped): ${missing_tools[*]}"
        return $MISSING_TOOLS
    }

    [ ${#install_failed[@]} -ne 0 ] && {
        log_error "Tools failed to install: ${install_failed[*]}"
        return $MISSING_TOOLS
    }

    return $SUCCESS
}

install_cloud_tools() {
    local cloud_provider=$1
    read -r -a tools <<< "$(get_cloud_tools "$cloud_provider")"
    
    for tool in "${tools[@]}"; do
        if ! tool_exists "$tool"; then
            if confirm_installation "$tool"; then
                install_tool "$tool"
            else
                return $MISSING_TOOLS
            fi
        fi
    done
}

create_backend() {
    local cloud_provider=$1
    local manifest_inputs
    manifest_inputs=$(cat "$2")
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
            if [[ $auth_type == "profile" ]]; then
                local profile
                profile=$(echo "$manifest_inputs" | jq -r '.manifest.auth.profile')
                log_debug "Using AWS profile: $profile"
                export AWS_PROFILE="$profile"
                # Verify AWS credentials
                if ! aws sts get-caller-identity >/dev/null 2>&1; then
                    log_error "AWS authentication failed. Please run 'aws sso login' or check your credentials"
                    exit 1
                fi
                log_success "AWS authentication successful using profile: $profile"
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
                    exit 1
                fi
                log_success "AWS authentication successful using access key"
            fi

            log_info "Creating S3 bucket for Terraform state"
            log_info "Checking if bucket exists $bucket_name"
            log_info "Running: aws s3api head-bucket --bucket $bucket_name --region $region"
            if ! aws s3api head-bucket --bucket "$bucket_name" --region "$region" 2>/dev/null; then
                log_info "Running: aws s3api create-bucket --bucket $bucket_name --region $region"
                if [[ $region == "us-east-1" ]]; then
                    if ! aws s3api create-bucket --bucket "$bucket_name" --region "$region"; then
                        log_error "Failed to create S3 bucket"
                        exit 1
                    fi
                else
                    if ! aws s3api create-bucket --bucket "$bucket_name" --region "$region" \
                        --create-bucket-configuration LocationConstraint="$region"; then
                        log_error "Failed to create S3 bucket"
                        exit 1
                    fi
                fi
                log_success "Created S3 bucket: $bucket_name"
            else
                log_info "S3 bucket already exists: $bucket_name"
            fi

            if [[ $dynamodb_table != "null" ]]; then
                log_info "Creating DynamoDB table for state locking"
                if ! aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" >/dev/null 2>&1; then
                    log_info "Running: aws dynamodb create-table --table-name $dynamodb_table --region $region"
                    if ! aws dynamodb create-table \
                        --table-name "$dynamodb_table" \
                        --attribute-definitions AttributeName=LockID,AttributeType=S \
                        --key-schema AttributeName=LockID,KeyType=HASH \
                        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
                        --region "$region"; then
                        log_error "Failed to create DynamoDB table $dynamodb_table in region $region"
                        exit 1
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
                log_debug "Creating GCS bucket $bucket_name"
                gcloud storage buckets create "gs://$bucket_name" --location="$region"
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
                log_debug "Creating resource group $resource_group"
                az group create --name "$resource_group" --location "$location"
            fi

            # Create storage account if needed
            if ! az storage account show --name "$storage_account" --resource-group "$resource_group" >/dev/null 2>&1; then
                log_debug "Creating storage account $storage_account"
                az storage account create \
                    --name "$storage_account" \
                    --resource-group "$resource_group" \
                    --location "$location" \
                    --sku Standard_LRS
            fi

            # Create container if needed
            if ! az storage container show --name "$container_name" --account-name "$storage_account" >/dev/null 2>&1; then
                log_debug "Creating storage container $container_name"
                az storage container create --name "$container_name" --account-name "$storage_account"
            fi
            ;;
    esac
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
    
    # Validate arguments
    if [ $# -eq 0 ]; then
        log_info "No cloud provider specified, using generic setup"
        cloud_provider="generic"
        config_file=""
    elif [ $# -eq 1 ]; then
        cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        log_error "Config file is required for $cloud_provider provider"
        log_info "Usage: $0 [aws|gcp|azure|generic] config.json"
        exit $INVALID_PROVIDER
    else
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
        "aws"|"gcp"|"azure"|"generic")
            log_info "Checking prerequisites for $cloud_provider deployment"
            ;;
        *)
            log_error "Invalid cloud provider. Usage: $0 [aws|gcp|azure|generic] config.json"
            exit $INVALID_PROVIDER
            ;;
    esac

    # Step 1: Detect system
    detect_system
    
    # Step 2: Install essential utilities
    install_essential_utilities || log_error "Missing essential utilities may affect deployment"

    # Step 3: Verify and install required tools
    verify_tools "$cloud_provider"
    local verify_status=$?
    if [ $verify_status -eq $MISSING_TOOLS ]; then
        log_info "Installing missing tools..."
        install_cloud_tools "$cloud_provider"
    elif [ $verify_status -ne $SUCCESS ]; then
        exit $verify_status
    fi

    # Step 4: Create backend (only for cloud-specific providers)
    if [ "$cloud_provider" != "generic" ] && [ -n "$config_file" ]; then
        log_info "Setting up backend storage for $cloud_provider"
        create_backend "$cloud_provider" "$config_file"
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
