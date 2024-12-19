#!/bin/bash

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

# Tool version requirements
declare -A MIN_VERSIONS=(
	["terraform"]="1.9.0"
	["kubectl"]="1.28.0"
	["helm"]="3.16.0"
	["aws"]="2.17.0"
	["gcloud"]="500.0.0"
	["az"]="2.67.0"
	["jq"]="1.7.1"
)

# Tool installation docs
declare -A INSTALL_DOCS=(
	["terraform"]="https://developer.hashicorp.com/terraform/downloads"
	["kubectl"]="https://kubernetes.io/docs/tasks/tools/"
	["helm"]="https://helm.sh/docs/intro/install/"
	["aws"]="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
	["gcloud"]="https://cloud.google.com/sdk/docs/install"
	["az"]="https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
	["jq"]="https://stedolan.github.io/jq/download/"
)

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
version_compare() {
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
get_tool_version() {
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
validate_basic_tools() {
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
		echo -e "\n${RED}Missing basic tools:${NC}"
		printf "${RED}%s${NC}\n" "${missing_docs[@]}"
		return $MISSING_TOOLS
	fi
	return $SUCCESS
}

# Function to validate cloud tools
validate_cloud_tools() {
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

	# Check each tool
	for tool in "${tools_to_check[@]}"; do
		if ! command_exists "$tool"; then
			missing_tools+=("$tool: Please install from here ${INSTALL_DOCS[$tool]}")
			continue
		fi

		local version=$(get_tool_version "$tool")
		if ! version_compare "$version" "${MIN_VERSIONS[$tool]}"; then
			outdated_tools+=("$tool version ${version} found. Version ${MIN_VERSIONS[$tool]} or higher required")
		fi
	done

	# Report missing tools
	if [ ${#missing_tools[@]} -ne 0 ]; then
		echo -e "\n${RED}Missing required tools:${NC}"
		printf "${RED}%s${NC}\n" "${missing_tools[@]}"
		return $MISSING_TOOLS
	fi

	# Report outdated tools
	if [ ${#outdated_tools[@]} -ne 0 ]; then
		echo -e "\n${RED}Outdated tools found:${NC}"
		printf "${RED}%s${NC}\n" "${outdated_tools[@]}"
		return $VERSION_ERROR
	fi

	return $SUCCESS
}

# Function to display tool versions
display_versions() {
	local cloud_provider=$1
	echo -e "\n${GREEN}Installed tool versions:${NC}"
	echo -e "Terraform: $(terraform version | head -n1)"
	echo -e "kubectl: $(kubectl version --client)"
	echo -e "Helm: $(helm version --short)"

	case $cloud_provider in
		"aws")
			echo -e "AWS CLI: $(aws --version)"
			;;
		"gcp")
			echo -e "Google Cloud SDK: $(gcloud version 2>/dev/null | grep "Google Cloud SDK" | awk '{print $4}')"
			;;
		"azure")
			echo -e "Azure CLI: $(az version | jq -r '."azure-cli"')"
			;;
	esac
}

# Main execution
main() {
	# Validate arguments
	if [ $# -eq 0 ]; then
		echo -e "${RED}Error: No cloud provider specified${NC}"
		echo "Usage: $0 [aws|gcp|azure]"
		exit $MISSING_ARGUMENT
	fi

	# Validate cloud provider
	local cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case $cloud_provider in
		"aws"|"gcp"|"azure")
			echo -e "${GREEN}Validating environment for $cloud_provider${NC}"
			;;
		*)
			echo -e "${RED}Error: Invalid cloud provider. Please specify aws, gcp, or azure${NC}"
			exit $INVALID_PROVIDER
			;;
	esac

	echo -e "\n${YELLOW}Validating required tools...${NC}"

	# Validate basic tools first
	validate_basic_tools
	[ $? -eq $SUCCESS ] || exit $MISSING_TOOLS

	# Validate cloud tools
	validate_cloud_tools "$cloud_provider"
	local validation_result=$?

	# Show versions and exit status if validation passed
	if [ $validation_result -eq $SUCCESS ]; then
		display_versions "$cloud_provider"
		echo -e "\n${GREEN}Validation complete! All tools are present and up to date.${NC}"
		exit $SUCCESS
	fi

	exit $validation_result
}

# Execute main function with all arguments
main "$@"
