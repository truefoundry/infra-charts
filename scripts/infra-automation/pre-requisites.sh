#!/bin/bash
set -e 

# Colors and Exit codes
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'
readonly SUCCESS=0 INVALID_PROVIDER=2 MISSING_TOOLS=3 VERSION_ERROR=4

# Tool configurations
declare -a COMMON_TOOLS=("terraform" "kubectl" "helm" "jq")
declare -A TOOL_VERSIONS=(
    ["terraform"]="1.9.0"
    ["kubectl"]="1.28.0"
    ["helm"]="3.16.0"
    ["jq"]="1.7.1"
    ["aws"]="2.17.0"
    ["gcloud"]="500.0.0"
    ["az"]="2.67.0"
    ["gke-gcloud-auth-plugin"]="0.0.1"
)

# System information
declare OS PACKAGE_MANAGER ARCH HAS_SUDO

# Logging functions
log() { echo -e "${2}$3${NC}"; }
log_debug() { log "DEBUG" "$YELLOW" "$1"; }
log_success() { log "SUCCESS" "$GREEN" "$1"; }
log_error() { log "ERROR" "$RED" "$1"; }

# Utility functions
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Function to check if sudo is available and can be used
check_sudo() {
    if command_exists sudo; then
        # Check if user has sudo privileges by attempting a harmless command
        if sudo -n true 2>/dev/null; then
            HAS_SUDO=true
        fi
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
    echo -e "${YELLOW}$1 is not installed. Would you like to install it? (Y/n)${NC}"
    read -r response
    [[ $response =~ ^[nN] ]] && { log_error "Skipping $1 installation"; return 1; } || return 0
}

version_compare() {
    local v1=${1#v} v2=${2#v}
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
        apt-get) echo "wget curl unzip git software-properties-common apt-transport-https ca-certificates lsb-release" ;;
        yum|dnf) echo "wget curl unzip git  which" ;;
        apk) echo "wget curl unzip git" ;;
        brew) echo "wget curl unzip git" ;;
    esac
}

# System detection
detect_system() {
    # Check sudo availability first
    check_sudo
    log_debug "Sudo availability: $HAS_SUDO"

    # Detect OS and package manager
    if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* ]]; then
        OS="linux"
        for pm in apt-get yum dnf apk; do
            if command_exists "$pm"; then
                PACKAGE_MANAGER="$pm"
                [[ $pm == "apk" ]] && OS="alpine"
                break
            fi
        done
        [[ -z $PACKAGE_MANAGER ]] && { log_error "Unsupported package manager"; exit 1; }
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        command_exists brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        PACKAGE_MANAGER="brew"
    else
        log_error "Unsupported operating system"; exit 1
    fi

    # Detect architecture
    case "$(uname -m)" in
        x86_64*) ARCH="amd64" ;;
        aarch64*|arm64*) ARCH="arm64" ;;
        *) log_error "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    export OS PACKAGE_MANAGER ARCH
    log_success "Detected OS: $OS, Package Manager: $PACKAGE_MANAGER, Architecture: $ARCH"
}

# Installation functions
install_essential_utilities() {
    local missing_tools=()
    local tools_list
    tools_list=$(get_essential_tools "$PACKAGE_MANAGER")
    
    for tool in $tools_list; do
        command_exists "$tool" || missing_tools+=("$tool")
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_debug "Installing missing tools: ${missing_tools[*]}"
        case $PACKAGE_MANAGER in
            apt-get) run_with_sudo apt-get update && run_with_sudo apt-get install -y "${missing_tools[@]}" ;;
            yum|dnf) run_with_sudo "$PACKAGE_MANAGER" install -y "${missing_tools[@]}" --allowerasing ;;
            apk) run_with_sudo apk update && run_with_sudo apk add --no-cache "${missing_tools[@]}" ;;
            brew) brew install "${missing_tools[@]}" ;;
        esac
        log_success "Essential utilities installed successfully"
    else
        log_success "All essential utilities are already installed"
    fi
}

get_tool_version() {
    case $1 in
        terraform) terraform version | head -n1 | cut -d'v' -f2 ;;
        kubectl) kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | cut -d'v' -f2 ;;
        helm) helm version --short | cut -d'v' -f2 ;;
        aws) aws --version 2>&1 | cut -d'/' -f2 ;;
        gcloud) gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}' ;;
        az) az version | jq -r '."azure-cli"' ;;
        jq) jq --version | cut -d'-' -f2 ;;
    esac
}

verify_tool_version() {
    local tool=$1
    local required_version=${TOOL_VERSIONS[$tool]}
    local current_version
    current_version=$(get_tool_version "$tool")
    
    version_compare "$current_version" "$required_version" || \
        log_error "$tool version $current_version found. Version $required_version or higher required"
}

install_tool() {
    local tool=$1 tmp_dir="/tmp/tool-install"
    mkdir -p "$tmp_dir" && cd "$tmp_dir" || exit 1
    log_debug "Installing $tool..."

    case $tool in
        terraform)
            local version
            version=${TOOL_VERSIONS[$tool]}
            wget -q "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${OS}_${ARCH}.zip" -O terraform.zip
            unzip -q terraform.zip && run_with_sudo mv terraform /usr/local/bin/
            ;;
        kubectl)
            local version
            version=${TOOL_VERSIONS[$tool]}
            wget -q "https://dl.k8s.io/release/v${version}/bin/${OS}/${ARCH}/kubectl" -O kubectl
            chmod +x kubectl && run_with_sudo mv kubectl /usr/local/bin/
            ;;
        helm)
            local version
            version=${TOOL_VERSIONS[$tool]}
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
                    /usr/local/google-cloud-sdk/install.sh --quiet --command-completion true --path-update true --usage-reporting false --rc-path "$HOME/.bashrc" --completion-path /etc/bash_completion.d/gcloud
                    
                    # Add to system-wide PATH
                    echo 'export PATH=/usr/local/google-cloud-sdk/bin:$PATH' | run_with_sudo tee /etc/profile.d/gcloud.sh
                    
                    # Add to current session
                    export PATH=/usr/local/google-cloud-sdk/bin:$PATH
                    
                    # Source the completion script for current session if it exists
                    [[ -f /etc/bash_completion.d/gcloud ]] && source /etc/bash_completion.d/gcloud
                    
                    # Initialize gcloud configuration directory
                    mkdir -p "$HOME/.config/gcloud"
                    
                    ;;
                darwin) 
                    brew install --cask google-cloud-sdk
                    # Add to current session PATH for macOS
                    export PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
                    ;;
            esac
            # Skip initialization as it requires user interaction
            log_debug "Skipping gcloud init as it requires user interaction. Please run 'gcloud init' manually after installation."
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
            command_exists gcloud || { log_error "gcloud must be installed first"; return 1; }
            case $OS in
                linux)
                    case $PACKAGE_MANAGER in
                        apt-get) 
                            gcloud components install gke-gcloud-auth-plugin || {
                                log_error "Failed to install gke-gcloud-auth-plugin via gcloud components"
                                return 1
                            }
                            ;;
                        yum|dnf) 
                            # Install via package manager
                            run_with_sudo "$PACKAGE_MANAGER" install -y google-cloud-sdk-gke-gcloud-auth-plugin || {
                                log_error "Failed to install gke-gcloud-auth-plugin via $PACKAGE_MANAGER"
                                return 1
                            }
                            ;;
                        *) 
                            gcloud components install gke-gcloud-auth-plugin || {
                                log_error "Failed to install gke-gcloud-auth-plugin via gcloud components"
                                return 1
                            }
                            ;;
                    esac
                    ;;
                darwin) 
                    gcloud components install gke-gcloud-auth-plugin || {
                        log_error "Failed to install gke-gcloud-auth-plugin via gcloud components"
                        return 1
                    }
                    ;;
            esac
						;;
    esac

    cd - > /dev/null && rm -rf "$tmp_dir"
    log_success "$tool installed successfully"
}

verify_tools() {
    local cloud_provider=$1
    local missing_tools=()
    local install_failed=()
    
    # Check common tools
    for tool in "${COMMON_TOOLS[@]}"; do
        if ! command_exists "$tool"; then
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
        if ! command_exists "$tool"; then
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
        if ! command_exists "$tool"; then
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
    log_debug "Creating backend for $cloud_provider"

    case $cloud_provider in
        aws)
            export AWS_PAGER=""
            local bucket_name region auth_type dynamodb_table
            bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket_name')
            region=$(echo "$manifest_inputs" | jq -r '.manifest.region')
            auth_type=$(echo "$manifest_inputs" | jq -r '.manifest.auth.type')
            dynamodb_table=$(echo "$manifest_inputs" | jq -r '.manifest.backend.dynamodb_table')

            # Handle AWS authentication
            if [[ $auth_type == "profile" ]]; then
                local profile
                profile=$(echo "$manifest_inputs" | jq -r '.manifest.auth.profile')
                export AWS_PROFILE=$profile
            else
                local access_key secret_key
                access_key=$(echo "$manifest_inputs" | jq -r '.manifest.auth.access_key')
                secret_key=$(echo "$manifest_inputs" | jq -r '.manifest.auth.secret_key')
                export AWS_ACCESS_KEY_ID=$access_key
                export AWS_SECRET_ACCESS_KEY=$secret_key
            fi

            # Create S3 bucket if needed
            if ! aws s3api head-bucket --bucket "$bucket_name" --region "$region" 2>&1; then
                log_debug "Creating bucket $bucket_name in region $region"
                if [[ $region == "us-east-1" ]]; then
                    aws s3api create-bucket --bucket "$bucket_name" --region "$region"
                else
                    aws s3api create-bucket --bucket "$bucket_name" --region "$region" \
                        --create-bucket-configuration LocationConstraint="$region"
                fi
            fi

            # Create DynamoDB table if needed
            if [[ $dynamodb_table != "null" ]]; then
                if ! aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" >/dev/null 2>&1; then
                    log_debug "Creating DynamoDB table $dynamodb_table"
                    aws dynamodb create-table \
                        --table-name "$dynamodb_table" \
                        --attribute-definitions AttributeName=ID,AttributeType=S \
                        --key-schema AttributeName=ID,KeyType=HASH \
                        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
                        --region "$region"
                fi
            fi
            ;;
        gcp)
            local bucket_name region
            bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket')
            region=$(echo "$manifest_inputs" | jq -r '.manifest.region')

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

# Utility functions
display_required_tools() {
    local cloud_provider=$1
    log_debug "Required tools and versions:"
    
    # Display common tools
    echo -e "${YELLOW}Common tools:${NC}"
    for tool in "${COMMON_TOOLS[@]}"; do
        echo -e "  - $tool (>= ${TOOL_VERSIONS[$tool]})"
    done
    
    # Display cloud-specific tools
    echo -e "\n${YELLOW}Cloud-specific tools for $cloud_provider:${NC}"
    read -r -a cloud_tools <<< "$(get_cloud_tools "$cloud_provider")"
    for tool in "${cloud_tools[@]}"; do
        echo -e "  - $tool (>= ${TOOL_VERSIONS[$tool]})"
    done
    echo
}

display_installed_versions() {
    local cloud_provider=$1
    log_success "Installed tool versions:"
    
    # Display common tools
    for tool in "${COMMON_TOOLS[@]}"; do
        if command_exists "$tool"; then
            local version
            version=$(get_tool_version "$tool")
            echo -e "  - $tool: $version"
        fi
    done
    
    # Display cloud-specific tools
    read -r -a cloud_tools <<< "$(get_cloud_tools "$cloud_provider")"
    for tool in "${cloud_tools[@]}"; do
        if command_exists "$tool"; then
            local version
            version=$(get_tool_version "$tool")
            echo -e "  - $tool: $version"
        fi
    done
    echo
}

display_login_instructions() {
    local cloud_provider=$1
    
    echo -e "\n${YELLOW}Post-Installation Login Instructions:${NC}"
    case $cloud_provider in
        "aws")
            echo -e "To configure AWS CLI:"
            echo -e "1. Run: ${GREEN}aws configure${NC}"
            echo -e "2. Enter your:"
            echo -e "   - AWS Access Key ID"
            echo -e "   - AWS Secret Access Key"
            echo -e "   - Default region name"
            echo -e "   - Default output format (json recommended)"
            echo -e "\nOr to use a named profile:"
            echo -e "Run: ${GREEN}aws configure --profile <profile-name>${NC}"
            ;;
        "gcp")
            echo -e "To configure Google Cloud CLI:"
            echo -e "1. Run: ${GREEN}gcloud init${NC}"
            echo -e "2. Follow the prompts to:"
            echo -e "   - Log in to your Google account"
            echo -e "   - Select or create a project"
            echo -e "   - Set a default compute region and zone"
            echo -e "\nFor service account authentication:"
            echo -e "Run: ${GREEN}gcloud auth activate-service-account --key-file=KEY-FILE${NC}"
            ;;
        "azure")
            echo -e "To configure Azure CLI:"
            echo -e "1. Run: ${GREEN}az login${NC}"
            echo -e "2. Follow the browser prompt to complete authentication"
            echo -e "\nFor service principal authentication:"
            echo -e "Run: ${GREEN}az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID${NC}"
            ;;
        "generic")
            echo -e "No cloud provider specified. No login required."
            ;;
    esac
    echo
}

# Main execution
main() {
    # Validate arguments
    if [ $# -eq 0 ]; then
        log_debug "No cloud provider specified, using generic setup"
        cloud_provider="generic"
        config_file=""
    else
        cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        config_file=$2
    fi

    # Validate cloud provider
    case $cloud_provider in
        "aws"|"gcp"|"azure"|"generic")
            log_success "Setting up environment for $cloud_provider"
            display_required_tools "$cloud_provider"
            ;;
        *)
            log_error "Error: Invalid cloud provider. Please specify aws, gcp, azure, or generic"
            log_error "Usage: $0 [aws|gcp|azure|generic] [config.json]"
            exit $INVALID_PROVIDER
            ;;
    esac

    # Step 1: Detect system and install essential utilities
    detect_system
    install_essential_utilities

    # Step 2: Verify and install required tools
    verify_tools "$cloud_provider"
    local verify_status=$?
    if [ $verify_status -eq $MISSING_TOOLS ]; then
        log_debug "Installing missing tools..."
        install_cloud_tools "$cloud_provider"
        verify_tools "$cloud_provider" || exit $?
    elif [ $verify_status -ne $SUCCESS ]; then
        exit $verify_status
    fi

    # Step 3: Create backend (only for cloud-specific providers)
    if [ "$cloud_provider" != "generic" ] && [ -n "$config_file" ]; then
        create_backend "$cloud_provider" "$config_file"
    fi

    # Display final summary
    display_installed_versions "$cloud_provider"
    log_success "Setup complete!"
		# Reload shell
		echo "Reload your shell to ensure all tools are properly available in your PATH"
		echo "$GREEN Please run 'exec -l $SHELL' to reload your shell"

    # Display login instructions if a cloud provider was specified
    if [ "$cloud_provider" != "generic" ]; then
        display_login_instructions "$cloud_provider"
    fi

    exit $SUCCESS
}

main "$@"
