#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if an argument is provided
if [ $# -eq 0 ]; then
	echo -e "${RED}Error: No cloud provider specified${NC}"
	echo "Usage: $0 [aws|gcp|azure]"
	exit 1
fi

# Validate the argument
cloud_provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
case $cloud_provider in
"aws" | "gcp" | "azure")
	echo -e "${GREEN}Setting up environment for $cloud_provider${NC}"
	;;
*)
	echo -e "${RED}Error: Invalid cloud provider. Please specify aws, gcp, or azure${NC}"
	exit 1
	;;
esac

# Convert cloud provider to numeric choice for existing functions
case $cloud_provider in
"aws") cloud_choice="1" ;;
"gcp") cloud_choice="2" ;;
"azure") cloud_choice="3" ;;
esac

# Declare global variables
declare OS
declare PACKAGE_MANAGER

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
	if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "linux-musl"* ]]; then
		OS="linux"
		if command_exists apt-get; then
			PACKAGE_MANAGER="apt-get"
		elif command_exists yum; then
			PACKAGE_MANAGER="yum"
		elif command_exists dnf; then
			PACKAGE_MANAGER="dnf"
		elif command_exists apk; then
			OS="alpine"
			PACKAGE_MANAGER="apk"
		else
			echo -e "${RED}Unsupported package manager${NC}"
			exit 1
		fi
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		OS="macos"
		if ! command_exists brew; then
			echo -e "${YELLOW}Installing Homebrew...${NC}"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
	else
		echo -e "${RED}Unsupported operating system${NC}"
		exit 1
	fi

	# Export variables to make them available to subshells
	export OS
	export PACKAGE_MANAGER
}

# Function to install essential utilities first
install_essential_utilities() {
	echo -e "\n${YELLOW}Installing essential utilities...${NC}"

	if [[ "$OS" == "linux" ]]; then
		case $PACKAGE_MANAGER in
		"apt-get")
			apt-get update
			apt-get install -y wget curl unzip git software-properties-common gnupg2 apt-transport-https ca-certificates lsb-release
			;;
		"yum" | "dnf")
			$PACKAGE_MANAGER install -y wget curl unzip git gnupg2 which
			;;
		esac
	elif [[ "$OS" == "alpine" ]]; then
		apk update
		apk add --no-cache wget curl unzip git gnupg
	elif [[ "$OS" == "macos" ]]; then
		brew install wget curl unzip git gnupg
	fi

	echo -e "${GREEN}Essential utilities installed successfully${NC}"
}

# Function to install packages based on OS
install_package() {
	local package_name="$1"
	if [[ "$OS" == "linux" ]]; then
		case $PACKAGE_MANAGER in
		"apt-get")
			apt-get update
			apt-get install -y "$package_name"
			;;
		"yum" | "dnf")
			$PACKAGE_MANAGER install -y "$package_name"
			;;
		esac
	elif [[ "$OS" == "alpine" ]]; then
		apk update
		apk add "$package_name"
	elif [[ "$OS" == "macos" ]]; then
		brew install "$package_name"
	fi
}

# Function to install Terraform
install_terraform() {
	if [[ "$OS" == "linux" ]]; then
		apt-get update && apt-get install -y gnupg software-properties-common
		wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
		apt-get update && apt-get install terraform
	elif [[ "$OS" == "alpine" ]]; then
		apk add --no-cache terraform
	elif [[ "$OS" == "macos" ]]; then
		brew tap hashicorp/tap
		brew install hashicorp/tap/terraform
	fi
}

# Function to install Helm
install_helm() {
	if [[ "$OS" == "linux" ]]; then
		curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg >/dev/null
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
		apt-get update && apt-get install helm
	elif [[ "$OS" == "alpine" ]]; then
		apk add --no-cache helm
	elif [[ "$OS" == "macos" ]]; then
		brew install helm
	fi
}

# Function to install kubectl
install_kubectl() {
	if [[ "$OS" == "linux" ]]; then
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm kubectl
	elif [[ "$OS" == "alpine" ]]; then
		apk add --no-cache kubectl
	elif [[ "$OS" == "macos" ]]; then
		brew install kubectl
	fi
}

# Function to install AWS CLI
install_aws_cli() {
	echo -e "${YELLOW}Installing AWS CLI...${NC}"
	if [[ "$OS" == "linux" ]]; then
		ARCH=$(uname -m)
		if [[ "$ARCH" == "x86_64" ]]; then
			curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
			unzip awscliv2.zip
			./aws/install
			rm -rf aws awscliv2.zip
		elif [[ "$ARCH" == "aarch64" ]]; then
			curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
			unzip awscliv2.zip
			./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
			rm -rf aws awscliv2.zip
		fi
	elif [[ "$OS" == "alpine" ]]; then
		apk add --no-cache aws-cli
	elif [[ "$OS" == "macos" ]]; then
		curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
		installer -pkg AWSCLIV2.pkg -target /
		rm AWSCLIV2.pkg
	fi
}

# Function to install Azure CLI
install_azure_cli() {
	echo -e "${YELLOW}Installing Azure CLI...${NC}"
	if [[ "$OS" == "linux" ]]; then
		curl -sL https://aka.ms/InstallAzureCLIDeb | bash
	elif [[ "$OS" == "alpine" ]]; then
		apk add --no-cache azure-cli
	elif [[ "$OS" == "macos" ]]; then
		brew install azure-cli
	fi
}

# Function to check and install cloud provider tools
install_cloud_tools() {
	case $cloud_choice in
	"1") # AWS
		if ! command_exists aws; then
			install_aws_cli
		fi
		;;

	"2") # GCP
		if ! command_exists gcloud; then
			echo -e "${YELLOW}Installing gcloud CLI...${NC}"
			if [[ "$OS" == "linux" ]]; then
				curl https://sdk.cloud.google.com | bash
				exec -l $SHELL
			elif [[ "$OS" == "alpine" ]]; then
				apk add --no-cache google-cloud-sdk
			elif [[ "$OS" == "macos" ]]; then
				ARCH=$(uname -m)
				if [[ "$ARCH" == "arm64" ]]; then
					brew install --cask google-cloud-sdk-arm
				else
					brew install --cask google-cloud-sdk
				fi
			fi
			gcloud init
		fi
		;;

	"3") # Azure
		if ! command_exists az; then
			install_azure_cli
		fi
		# Install Azure specific tools
		if ! command_exists aks-preview; then
			echo -e "${YELLOW}Installing AKS preview extensions...${NC}"
			az extension add --name aks-preview
		fi
		;;
	esac
}

# Function to check system architecture
check_architecture() {
	ARCH=$(uname -m)
	echo -e "${GREEN}Detected architecture: $ARCH${NC}"
	if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
		echo -e "${RED}Unsupported architecture: $ARCH${NC}"
		exit 1
	fi
}

# Main script starts here
echo -e "${YELLOW}Starting prerequisites installation...${NC}"

# Detect OS
detect_os
echo -e "${GREEN}Detected OS: $OS${NC}"

# Check system architecture
check_architecture

# Check and install prerequisites
echo -e "\n${YELLOW}Checking and installing required tools...${NC}"

# Check and install unzip
if ! command_exists unzip; then
	echo -e "${YELLOW}Installing unzip...${NC}"
	install_package "unzip"
fi

# Check and install curl
if ! command_exists curl; then
	echo -e "${YELLOW}Installing curl...${NC}"
	install_package "curl"
fi

# Check and install terraform
if ! command_exists terraform; then
	echo -e "${YELLOW}Installing Terraform...${NC}"
	install_terraform
fi

# Check and install helm
if ! command_exists helm; then
	echo -e "${YELLOW}Installing Helm...${NC}"
	install_helm
fi

# Check and install kubectl
if ! command_exists kubectl; then
	echo -e "${YELLOW}Installing kubectl...${NC}"
	install_kubectl
fi

# Check and install jq
if ! command_exists jq; then
	echo -e "${YELLOW}Installing jq...${NC}"
	install_package "jq"
fi

# Install cloud-specific tools based on selection
echo -e "\n${YELLOW}Installing cloud provider specific tools...${NC}"
case $cloud_provider in
"aws")
	if ! command_exists aws; then
		install_aws_cli
	fi
	;;
"gcp")
	if ! command_exists gcloud; then
		echo -e "${YELLOW}Installing gcloud CLI...${NC}"
		if [[ "$OS" == "linux" ]]; then
			curl https://sdk.cloud.google.com | bash
			exec -l $SHELL
			gcloud init
		elif [[ "$OS" == "alpine" ]]; then
			apk add --no-cache google-cloud-sdk
			gcloud init
		elif [[ "$OS" == "macos" ]]; then
			brew install --cask google-cloud-sdk
			gcloud init
		fi
	fi
	echo -e "${YELLOW}Installing GKE authentication plugin...${NC}"
	if [[ "$OS" == "alpine" ]]; then
		apk add --no-cache google-cloud-sdk-gke-gcloud-auth-plugin
	else
		gcloud components install gke-gcloud-auth-plugin
	fi
	;;
"azure")
	if ! command_exists az; then
		install_azure_cli
	fi
	;;
esac

# Modify version check to only show relevant versions
check_versions() {
	echo -e "\n${YELLOW}Installed versions:${NC}"
	echo -e "${GREEN}Terraform version: $(terraform version | head -n1)${NC}"
	echo -e "${GREEN}kubectl version: $(kubectl version --client)${NC}"
	echo -e "${GREEN}Helm version: $(helm version)${NC}"

	case $cloud_provider in
	"aws")
		if command_exists aws; then
			echo -e "${GREEN}AWS CLI version: $(aws --version)${NC}"
		fi
		;;
	"gcp")
		if command_exists gcloud; then
			echo -e "${GREEN}Google Cloud SDK version: $(gcloud --version | head -n1)${NC}"
		fi
		;;
	"azure")
		if command_exists az; then
			echo -e "${GREEN}Azure CLI version: $(az --version | head -n1)${NC}"
		fi
		;;
	esac
}

# Check versions at the end
check_versions

echo -e "\n${GREEN}All prerequisites have been checked and installed!${NC}"
echo -e "${YELLOW}Please run 'exec -l $SHELL' to reload your shell if this is the first time installing these tools.${NC}"
