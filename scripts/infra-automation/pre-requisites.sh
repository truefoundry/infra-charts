#!/bin/bash
set -e 

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Exit codes
SUCCESS=0
MISSING_ARGUMENT=1
INVALID_PROVIDER=2
MISSING_TOOLS=3
VERSION_ERROR=4

# Tool version requirements and installation docs as parallel arrays
TOOLS=(terraform kubectl helm aws gcloud az jq)
MIN_VERSIONS=(1.9.0 1.28.0 3.16.0 2.17.0 500.0.0 2.67.0 1.7.1)
INSTALL_URLS=(
    "https://developer.hashicorp.com/terraform/downloads"
    "https://kubernetes.io/docs/tasks/tools/"
    "https://helm.sh/docs/intro/install/"
    "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    "https://cloud.google.com/sdk/docs/install"
    "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    "https://stedolan.github.io/jq/download/"
)

# Add new functions for OS and architecture detection
function get_os() {
    local os
    case "$(uname -s)" in
        Linux*)     os="linux";;
        Darwin*)    os="darwin";;
        MINGW*)     os="windows";;
        *)          os="unknown";;
    esac
    echo "$os"
}

function get_arch() {
    local arch
    case "$(uname -m)" in
        x86_64*)    arch="amd64";;
        aarch64*)   arch="arm64";;
        arm64*)     arch="arm64";;
        *)          arch="amd64";;
    esac
    echo "$arch"
}

# Function to install a tool
function install_tool() {
    local tool=$1
    local os=$(get_os)
    local arch=$(get_arch)
    local tmp_dir="/tmp/tool-install"
    
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"
    
    case $tool in
        "terraform")
            local version="1.9.0"
            local url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip"
            wget "$url" -O terraform.zip
            unzip terraform.zip
            sudo mv terraform /usr/local/bin/
            ;;
        "kubectl")
            local version="v1.28.0"
            local url="https://dl.k8s.io/release/${version}/bin/${os}/${arch}/kubectl"
            wget "$url" -O kubectl
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            ;;
        "helm")
            local version="v3.16.0"
            local url="https://get.helm.sh/helm-${version}-${os}-${arch}.tar.gz"
            wget "$url" -O helm.tar.gz
            tar -zxvf helm.tar.gz
            sudo mv "${os}"-"${arch}"/helm /usr/local/bin/
            ;;
        "aws")
            case $os in
                "linux")
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip awscliv2.zip
                    sudo ./aws/install
                    ;;
                "darwin")
                    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                    sudo installer -pkg AWSCLIV2.pkg -target /
                    ;;
            esac
            ;;
        "gcloud")
            case $os in
                "linux")
                    curl https://sdk.cloud.google.com > install.sh
                    bash install.sh --disable-prompts
                    ;;
                "darwin")
                    brew install --cask google-cloud-sdk
                    ;;
            esac
            ;;
        "az")
            case $os in
                "linux")
                    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
                    ;;
                "darwin")
                    brew install azure-cli
                    ;;
            esac
            ;;
        "jq")
            case $os in
                "linux")
                    sudo apt-get update && sudo apt-get install -y jq || sudo yum install -y jq
                    ;;
                "darwin")
                    brew install jq
                    ;;
            esac
            ;;
    esac
    
    cd - > /dev/null
    rm -rf "$tmp_dir"
}

# Function to log info
function log_debug() {
	echo -e "${YELLOW}pre-requisite.sh - [DEBUG] - $1${NC}"
}

function log_success() {
	echo -e "${GREEN}pre-requisite.sh - [INFO] - $1${NC}"
}

function log_error() {
	echo -e "${RED}pre-requisite.sh - [ERROR] - $1${NC}"
}


# Function to get array index
function get_index() {
    local element=$1
    local i=0
    for tool in "${TOOLS[@]}"; do
        if [ "$tool" = "$element" ]; then
            echo $i
            return
        fi
        ((i++))
    done
    echo -1
}

# Function to get minimum version for a tool
function get_min_version() {
    local tool=$1
    local idx=$(get_index "$tool")
    if [ "$idx" -ge 0 ]; then
        echo "${MIN_VERSIONS[$idx]}"
    fi
}

# Function to get install URL for a tool
function get_install_url() {
    local tool=$1
    local idx=$(get_index "$tool")
    if [ "$idx" -ge 0 ]; then
        echo "${INSTALL_URLS[$idx]}"
    fi
}

# Function to check if a command exists
function command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
function version_compare() {
	local ver1=$1
	local ver2=$2
	
	# Remove any leading 'v' if present
	ver1=${ver1#v}
	ver2=${ver2#v}
	
	# Convert versions to comparable integers
	ver1_comp=$(echo "$ver1" | awk -F. '{printf "%d%02d", $1, $2}')
	ver2_comp=$(echo "$ver2" | awk -F. '{printf "%d%02d", $1, $2}')
	
	[ "$ver1_comp" -ge "$ver2_comp" ]
}

# Function to get tool version
function get_tool_version() {
	local tool=$1
	case $tool in
		"terraform")
			terraform version | head -n1 | cut -d'v' -f2
			;;
		"kubectl")
			kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | cut -d'v' -f2
			;;
		"helm")
			helm version --short | cut -d'v' -f2
			;;
		"aws")
			aws --version 2>&1 | cut -d'/' -f2
			;;
		"gcloud")
			gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}'
			;;
		"az")
			az version | jq -r '."azure-cli"'
			;;
		"jq")
			jq --version | cut -d'-' -f2
			;;
	esac
}

# Function to validate basic tools
function validate_basic_tools() {
	local missing_tools=()
	local missing_docs=()

	for tool in wget curl unzip jq; do
		if ! command_exists "$tool"; then
			missing_tools+=("$tool")
			if [ "$tool" = "jq" ]; then
				missing_docs+=("$tool: Please install from here ${INSTALL_DOCS[$tool]}")
			else
				missing_docs+=("$tool: Install via your system package manager (apt, yum, brew)")
			fi
		fi
	done

	if [ ${#missing_tools[@]} -ne 0 ]; then
		log_error "Missing basic tools: ${missing_docs[@]} "
		return $MISSING_TOOLS
	fi
	return $SUCCESS
}

# Function to validate cloud tools
function validate_cloud_tools() {
    local cloud_provider=$1
    local outdated_tools=()
    local missing_tools=()
    local tools_to_check=("terraform" "kubectl" "helm")

    # Add cloud-specific tool
    case $cloud_provider in
        "aws") tools_to_check+=("aws") ;;
        "gcp") tools_to_check+=("gcloud") ;;
        "azure") tools_to_check+=("az") ;;
    esac

    # Check each tool and attempt installation if missing
    for tool in "${tools_to_check[@]}"; do
        if ! command_exists "$tool"; then
            log_debug "Attempting to install $tool..."
            install_tool "$tool"
            
            if ! command_exists "$tool"; then
                missing_tools+=("$tool: Failed to install. Please install manually from $(get_install_url "$tool")")
                continue
            fi
        fi

        local version=$(get_tool_version "$tool")
        local min_version=$(get_min_version "$tool")
        if ! version_compare "$version" "$min_version"; then
            outdated_tools+=("$tool version ${version} found. Version ${min_version} or higher required")
        fi
    done

    # Report missing tools
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[@]}"
        return $MISSING_TOOLS
    fi

    # Report outdated tools
    if [ ${#outdated_tools[@]} -ne 0 ]; then
        log_error "Outdated tools found: ${outdated_tools[@]}"
        return $VERSION_ERROR
    fi

    return $SUCCESS
}

# Function to display tool versions
function display_versions() {
	local cloud_provider=$1
	log_success "Installed tool versions:"
	log_success "Terraform: $(terraform version | head -n1)"
	log_success "kubectl: $(kubectl version --client | head -n1)"
	log_success "Helm: $(helm version --short)"

	case $cloud_provider in
		"aws")
			log_success "AWS CLI: $(aws --version)"
			;;
		"gcp")
			log_success "Google Cloud SDK: $(gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}')"
			;;
		"azure")
			log_success "Azure CLI: $(az version | jq -r '."azure-cli"')"
			;;
	esac
}

# Function to create cloud backend
function create_backend() {
	log_debug "create_backend - trying to create backend..."
	local cloud_provider=$1
	local manifest_inputs=$(cat "$2")
	log_debug "create_backend - $manifest_inputs"
	case $cloud_provider in
	"aws")
		# AWS Backend Creation
		# -------------------
		# Disable AWS pager for cleaner output
	    export AWS_PAGER=""

		# Extract backend configuration from manifest
		local bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket_name')
		local region=$(echo "$manifest_inputs" | jq -r '.manifest.region')
		local auth_type=$(echo "$manifest_inputs" | jq -r '.manifest.auth.type')
		local dynamodb_table=$(echo "$manifest_inputs" | jq -r '.manifest.backend.dynamodb_table')

		# Handle authentication
		if [[ $auth_type == "profile" ]]
		then
			# Use AWS profile-based authentication
			log_debug "Auth mode $auth_type"
			local profile=$(echo $manifest_inputs | jq -r '.manifest.auth.profile')
			export AWS_PROFILE=$profile
		else
			local access_key=$(echo $manifest_inputs | jq -r '.manifest.auth.access_key')
			export AWS_ACCESS_KEY_ID=$access_key
			export AWS_SECRET_ACCESS_KEY=$secret_key
			local secret_key=$(echo $manifest_inputs | jq -r '.manifest.auth.secret_key')
		fi
		
		# Create or verify S3 bucket
		if aws s3api head-bucket --bucket "$bucket_name" --region "$region" 2>&1; then
				log_success "create_backend - Bucket $bucket_name already present"
		else
			log_debug "create_backend - Bucket $bucket_name doesn't exist. Creating ..."
			if [[ $region == "us-east-1" ]]
			then
				# Special handling for us-east-1 region
				aws s3api create-bucket --bucket "$bucket_name" --region "$region"
			else
				# Create bucket in specified region
				aws s3api create-bucket --bucket "$bucket_name" --region "$region" --create-bucket-configuration LocationConstraint="$region"
				if [ $? -eq 0 ]
				then
					log_success "create_backend - Bucket $bucket_name created successfully."
				else
					log_error "create_backend - Failed to create bucket $bucket_name in the region $region."
				fi
			fi
		fi

		# Create or verify DynamoDB table for state locking
		if [[ $dynamodb_table == "null" ]]
		then
			log_debug "Skipping dynamodb table check as it is not present in the manifest..."
		else
			log_debug "Checking for dynamodb table $dynamodb_table in region $region..."
			if aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" > /dev/null 2>&1; then
				log_success "Table '$dynamodb_table' already exists."
			else
				log_debug "Table '$dynamodb_table' does not exist. Creating..."
				# Create DynamoDB table with LockID as primary key
				aws dynamodb create-table \
					--table-name "$dynamodb_table" \
					--attribute-definitions AttributeName=ID,AttributeType=S \
					--key-schema AttributeName=ID,KeyType=HASH \
					--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
					--region "$region"

				if [ $? -eq 0 ]; then
					log_success "Table '$dynamodb_table' created successfully."
				else
					log_error "Failed to create table '$dynamodb_table'."
				fi
			fi
		fi
		;;
	"gcp")
		# Google Cloud Backend Creation
		# ---------------------------
		# Extract backend configuration
		local bucket_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.bucket')
		local region=$(echo "$manifest_inputs" | jq -r '.manifest.region')

		# Create or verify GCS bucket
		if gcloud storage buckets describe gs://"$bucket_name" > /dev/null 2>&1; then
			log_success "Bucket '$bucket_name' already exists."
		else
			log_debug "Bucket '$bucket_name' does not exist. Creating..."
			gcloud storage buckets create gs://"$bucket_name" --location="$region"
			if [ $? -eq 0 ]; then
				log_success "Bucket '$bucket_name' created successfully."
			else
				log_error "Failed to create bucket '$bucket_name'."
			fi
		fi
		;;
	"azure")
		# Azure Backend Creation
		# ---------------------
		# Extract backend configuration
		local resource_group=$(echo "$manifest_inputs" | jq -r '.manifest.backend.resource_group_name')
		local storage_account=$(echo "$manifest_inputs" | jq -r '.manifest.backend.storage_account_name')
		local container_name=$(echo "$manifest_inputs" | jq -r '.manifest.backend.container_name')
		local location=$(echo "$manifest_inputs" | jq -r '.manifest.location')

		# Create or verify resource group
		if az group show --name "$resource_group" > /dev/null 2>&1; then
			log_success "Resource group '$resource_group' already exists."
		else
			log_debug "Resource group '$resource_group' does not exist. Creating..."
			az group create --name "$resource_group" --location "$location"
			if [ $? -eq 0 ]; then
				log_success "Resource group '$resource_group' created successfully."
			else
				log_error "Failed to create resource group '$resource_group'."
			fi
		fi

		# Create or verify storage account
		if az storage account show --name "$storage_account" --resource-group "$resource_group" > /dev/null 2>&1; then
			log_success "Storage account '$storage_account' already exists."
		else
			log_debug "Storage account '$storage_account' does not exist. Creating..."
			az storage account create --name "$storage_account" --resource-group "$resource_group" --location "$location" --sku Standard_LRS
			if [ $? -eq 0 ]; then
				log_success "Storage account '$storage_account' created successfully."
			else
				log_error "Failed to create storage account '$storage_account'. Exiting."
			fi
		fi

		# Create or verify storage container
		if az storage container show --name "$container_name" --account-name "$storage_account" > /dev/null 2>&1; then
			log_success "Container '$container_name' already exists in storage account '$storage_account'."
		else
			log_debug "Container '$container_name' does not exist. Creating..."
			az storage container create --name "$container_name" --account-name "$storage_account"
			if [ $? -eq 0 ]; then
				log_success "Container '$container_name' created successfully."
			else
				log_error "Failed to create container '$container_name'."
			fi
		fi
		;;
	esac
}

# Main execution
main() {
	# Validate arguments
	if [ $# -eq 0 ]; then
		log_error "Error: No cloud provider specified"
		log_error "Usage: $0 [aws|gcp|azure] config.json"
		exit $MISSING_ARGUMENT
	fi

	# Validate cloud provider
	local cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case $cloud_provider in
		"aws"|"gcp"|"azure")
			log_success "Validating environment for $cloud_provider"
			;;
		*)
			log_error "Error: Invalid cloud provider. Please specify aws, gcp, or azure"
			exit $INVALID_PROVIDER
			;;
	esac

	# inputs file name
	# local manifest_inputs=$(cat "$2")
	create_backend "$cloud_provider" "$2"

	log_debug "Validating required tools..."

	# Validate basic tools first
	validate_basic_tools
	[ $? -eq $SUCCESS ] || exit $MISSING_TOOLS

	# Validate cloud tools
	validate_cloud_tools "$cloud_provider"
	local validation_result=$?

	# Show versions and exit status if validation passed
	if [ $validation_result -eq $SUCCESS ]; then
		display_versions "$cloud_provider"
		log_success "Validation complete! All tools are present and up to date."
		exit $SUCCESS
	fi

	exit $validation_result
}

# Execute main function with all arguments
main "$@"
