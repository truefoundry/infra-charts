#!/bin/bash

# Global variable to track if we're in the middle of an operation
in_operation=false

# Global variable to cache ECR check result
is_destination_ecr=false

# Error tracking variables
total_images=0
skipped_images=0
copied_images=0
failed_images=0
error_messages=()
successfully_copied_images=()

# Function to handle cleanup on exit
cleanup() {
    if [ "$in_operation" = true ]; then
        err_echo ""
        err_echo "Received interrupt signal. Cleaning up..."
        err_echo "Script interrupted by user."
    fi
    exit 130  # Standard exit code for SIGINT
}

# Helper function to echo to stderr
err_echo() {
    echo "$@" >&2
}

# Function to show Helm repository error message
show_helm_repo_error() {
    err_echo ""
    err_echo "Please add the Helm repository first:"
    err_echo "  helm repo add truefoundry https://truefoundry.github.io/infra-charts"
    err_echo "  helm repo update"
    err_echo ""
}

# Function to log messages with appropriate prefix based on run_mode
log_msg() {
    local message="$1"
    if [ "$run_mode" = false ]; then
        err_echo "[DRY-RUN] $message"
    else
        err_echo "$message"
    fi
}

# Function to track errors
track_error() {
    local image="$1"
    local error="$2"
    error_messages+=("$image: $error")
    ((failed_images++))
}

# Function to detect authentication errors in skopeo output
is_auth_error() {
    local output="$1"
    # Check for common authentication error patterns
    if [[ "$output" =~ (unauthorized|authentication|login|credential|token|access.*denied|forbidden) ]]; then
        return 0  # Auth error detected
    fi
    return 1  # No auth error
}

# Function to display summary statistics
display_summary() {
    err_echo ""
    err_echo "Summary:"
    err_echo "  Total images processed: $total_images"
    err_echo "  Images skipped (already exist): $skipped_images"
    err_echo "  Images successfully copied: $copied_images"
    err_echo "  Images failed to copy: $failed_images"
}

# Function to handle authentication error and exit
handle_auth_error() {
    local image="$1"
    local output="$2"
    local context="$3"  # "inspect" or "copy"
    
    log_msg "✗ Authentication error detected during $context. Exiting script..."
    log_msg "Auth error: $output"
    track_error "$image" "Authentication error: $output"
    err_echo ""
    err_echo "========================================"
    err_echo "Script terminated due to authentication error."
    err_echo "========================================"
    display_summary
    err_echo ""
    err_echo "Exit code: 1 (authentication error)"
    exit 1
}

# Function to build complete skopeo command with credentials
build_skopeo_command() {
    local source_image="$1"
    local dest_image="$2"
    
    # Build base skopeo command based on registry type
    local skopeo_cmd="skopeo copy"
    
    if [ "$is_destination_ecr" = "true" ]; then
        skopeo_cmd="$skopeo_cmd --all"
    else
        skopeo_cmd="$skopeo_cmd --multi-arch all"
        # skopeo_cmd="$skopeo_cmd --multi-arch index-only"
    fi
    
    # Add source credentials if provided
    if [ -n "$source_creds" ]; then
        skopeo_cmd="$skopeo_cmd --src-creds=$source_creds"
    fi

    # Add destination credentials if provided
    if [ -n "$destination_creds" ]; then
        skopeo_cmd="$skopeo_cmd --dest-creds=$destination_creds"
    fi

    # Add source and destination images
    skopeo_cmd="$skopeo_cmd docker://$source_image docker://$dest_image"
    
    echo "$skopeo_cmd"
}

# Function to show usage
show_usage() {
    err_echo "Usage: $0 --helm-chart <helm_chart> --helm-version <helm_version> --dest-registry <destination_registry> --dest-user <dest_username> --dest-pass <dest_password> [--helm-repo <helm_repo>] [--helm-values <values_file>] [--source-user <source_username>] [--source-pass <source_password>] [--ecr-tags <tags>] [--dry-run]"
    err_echo ""
    err_echo "Arguments:"
    err_echo "  --helm-repo, -hr         Helm repository URL or name (default: truefoundry)"
    err_echo "  --helm-chart, -hc        Helm chart name (required)"
    err_echo "  --helm-version, -hv      Helm chart version (required)"
    err_echo "  --helm-values, -hvf      Helm chart values file (optional)"
    err_echo "  --source-user, -su       Source registry username (optional)"
    err_echo "  --source-pass, -sp       Source registry password (optional)"
    err_echo "  --dest-registry, -d      Destination registry URL with optional path prefix (required unless --list-only)"
    err_echo "                           Examples: my-registry.com or my-registry.com/myapp"
    err_echo "  --dest-user, -du         Destination registry username (required unless --list-only)"
    err_echo "  --dest-pass, -dp         Destination registry password (required unless --list-only)"
    err_echo "  --ecr-tags, -et          Tags for ECR repositories in format Key1=Value1,Key2=Value2 (optional, AWS ECR only)"
    err_echo "  --dry-run                Preview mode - shows what would be done without performing operations"
    err_echo "  --force-copy             Skip existence check and force copy all images"
    err_echo "  --list-only              Only list images from helm chart without copying (no destination registry required)"
    err_echo "  --output-file, -o        Write image list to specified file (works with both --list-only and copy modes)"
    err_echo "  --help, -h               Show this help message"
    err_echo ""
    err_echo "Output Streams:"
    err_echo "  This script separates output for automation-friendly usage:"
    err_echo "    - stdout: Image list only (in --list-only mode)"
    err_echo "    - stderr: All progress messages, warnings, and status updates"
    err_echo ""
    err_echo "  This allows you to:"
    err_echo "    - Pipe images to other commands: | grep nginx"
    err_echo "    - Redirect to file while seeing progress: > images.txt"
    err_echo "    - Silence progress if needed: 2>/dev/null"
    err_echo "    - Save progress separately: 2>progress.log"
    err_echo ""
    err_echo "Examples:"
    err_echo "  # Actually perform the operations (default)"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 -d my-registry.com -du myuser -dp mypass"
    err_echo ""
    err_echo "  # Preview mode - shows what would be done"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 -d my-registry.com -du myuser -dp mypass --dry-run"
    err_echo ""
    err_echo "  # List images only"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 --list-only"
    err_echo ""
    err_echo "  # List images and save to file"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 --list-only -o images.txt"
    err_echo ""
    err_echo "  # List images to stdout (redirect to file, progress still visible)"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 --list-only > images.txt"
    err_echo ""
    err_echo "  # Pipe images to another command (grep, awk, etc.)"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 --list-only | grep nginx"
    err_echo ""
    err_echo "  # Copy images and save list of copied images to file"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 -d my-registry.com -du myuser -dp mypass -o copied-images.txt"
    err_echo ""
    err_echo "  # Using ECR with prefix in registry path"
    err_echo "  $0 -hc truefoundry -hv 0.89.4 -d 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp -du AWS -dp mypass"
    err_echo ""
    err_echo "  # Full example with all options"
    err_echo "  $0 -hr truefoundry -hc truefoundry -hv 0.89.4 -hvf values.yaml -d 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp -du AWS -dp mypass --ecr-tags \"Environment=Production,Team=Platform\""
}

# Function to check if destination is AWS ECR
is_aws_ecr() {
    local registry="$1"
    if [[ "$registry" =~ \.dkr\.ecr\.[a-z0-9-]+\.amazonaws\.com ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if ECR repository exists
ecr_repo_exists() {
    local registry="$1"
    local repo_name="$2"
    local region
    region=$(echo "$registry" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
    
    if [ -z "$region" ]; then
        return 1
    fi

    aws ecr describe-repositories --region "$region" --repository-names "$repo_name" >/dev/null 2>&1
}

# Function to create ECR repository
create_ecr_repo() {
    local registry="$1"
    local repo_name="$2"
    local tags="$3"
    local region
    region=$(echo "$registry" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
    
    if [ -z "$region" ]; then
        err_echo "ERROR: Could not extract AWS region from ECR registry URL"
        return 1
    fi
    
    err_echo "Creating ECR repository: $repo_name in region: $region"
    
    # Build the AWS CLI command
    local aws_cmd="aws ecr create-repository --region \"$region\" --repository-name \"$repo_name\""
    
    # Add tags if provided
    if [ -n "$tags" ]; then
        # Parse comma-separated tags into AWS CLI format
        local tag_array=""
        IFS=',' read -ra TAG_PAIRS <<< "$tags"
        
        for tag_pair in "${TAG_PAIRS[@]}"; do
            if [[ "$tag_pair" == *"="* ]]; then
                local key="${tag_pair%%=*}"
                local value="${tag_pair#*=}"
                
                # Trim whitespace from key and value
                key=$(echo "$key" | xargs)
                value=$(echo "$value" | xargs)
                
                if [ -n "$tag_array" ]; then
                    tag_array="$tag_array,"
                fi
                tag_array="${tag_array}{\"Key\":\"${key}\",\"Value\":\"${value}\"}"
            else
                err_echo "WARNING: Skipping invalid tag pair (no '=' found): '$tag_pair'"
            fi
        done
        
        if [ -n "$tag_array" ]; then
            # Format as proper JSON array
            local json_tags="[${tag_array}]"
            aws_cmd="$aws_cmd --tags '$json_tags'"
        else
            err_echo "WARNING: No valid tags found after parsing"
        fi
    fi
    
    # Execute the command
    local aws_output
    local aws_exit_code
    
    if aws_output=$(eval "$aws_cmd" 2>&1); then
        aws_exit_code=0
    else
        aws_exit_code=$?
        err_echo "ERROR: Failed to create ECR repository"
        err_echo "AWS CLI Error: $aws_output"
        return $aws_exit_code
    fi
}

# Function to extract images from helm chart
extract_images_from_helm_chart() {
    local repo_name="$1"
    local chart_name="$2"
    local version="$3"
    local values_file="$4"
    local output_file="$5"
    
    # Check if the Helm repository is added
    err_echo ""
    err_echo "========================================"
    err_echo "Verifying Helm repository..."
    err_echo "========================================"

    err_echo "Checking if Helm repository is added..."
    
    # Get list of existing repos
    local existing_repos
    existing_repos=$(helm repo list -o json 2>/dev/null)
    local helm_exit_code=$?
    
    if [ $helm_exit_code -ne 0 ] || [ -z "$existing_repos" ] || [ "$existing_repos" = "null" ]; then
        # No repos exist yet
        err_echo ""
        err_echo "✗ ERROR: No Helm repositories found!"
        show_helm_repo_error
        return 1
    fi
    
    # Check if the repository name exists
    local repo_exists
    repo_exists=$(echo "$existing_repos" | jq -r ".[] | select(.name == \"$repo_name\") | .name" 2>/dev/null)
    
    if [ -n "$repo_exists" ]; then
        local existing_url
        existing_url=$(echo "$existing_repos" | jq -r ".[] | select(.name == \"$repo_name\") | .url" 2>/dev/null)
        if [ -n "$existing_url" ] && [ "$existing_url" != "null" ]; then
            err_echo "✓ Helm repository found: $repo_name -> $existing_url"
        else
            err_echo "✗ ERROR: Helm repository '$repo_name' found but URL is invalid!"
            return 1
        fi
    else
        err_echo "✗ ERROR: Helm repository '$repo_name' not found!"
        show_helm_repo_error
        err_echo "Available repositories:"
        helm repo list 2>&1 >&2
        err_echo ""
        return 1
    fi

    local chart_with_version
    chart_with_version=$(helm search repo "$repo_name/$chart_name" --version "$version" -o json | jq -r ".[] | select(.version == \"$version\") | .version" 2>/dev/null)
    if [ -z "$chart_with_version" ]; then
        err_echo "✗ ERROR: Chart $chart_name with version $version not found!"
        show_helm_repo_error
        err_echo "For available chart versions:"
        err_echo "  helm search repo \"$repo_name/$chart_name\" --versions"
        err_echo ""
        return 1
    fi

    err_echo "✓ Chart $chart_name with version $version found!"

    # Extract the default global.image.registry value from the chart using helm
    err_echo "Getting default global.image.registry from chart..."
    default_registry=$(helm show values "$repo_name/$chart_name" --version "$version" --jsonpath "{.global.image.registry}")
    
    if [ -z "$default_registry" ] || [ "$default_registry" = "null" ]; then
        default_registry="tfy.jfrog.io"
        err_echo "Using fallback default registry: $default_registry"
    else
        err_echo "Found default registry in chart: $default_registry"
    fi

    # Build helm template command
    local helm_cmd="helm template \"$repo_name/$chart_name\" --version \"$version\""
    
    if [ -n "$values_file" ] && [ -f "$values_file" ]; then
        err_echo "Using provided values file: $values_file with default global.image.registry=$default_registry"
        helm_cmd="$helm_cmd -f \"$values_file\""
    else
        err_echo "No values file provided, using default values with global.image.registry=$default_registry"
    fi
    
    helm_cmd="$helm_cmd --set global.image.registry=\"$default_registry\" > tmp_rendered_k8s_manifest.yaml"
    err_echo "Running: $helm_cmd"
    eval "$helm_cmd"

    # Extract all image references from the rendered YAML
    images=$(grep -E '^\s*image:\s*' tmp_rendered_k8s_manifest.yaml | awk '{print $2}' | tr -d '"' | tr -d "'" | sort -u)
    
    err_echo "Found $(echo "$images" | wc -l) total images"

    blacklist_images=('python:3.11.9-bullseye')
    err_echo "Filtering images to only include those from registry: $default_registry"

    filtered_images=()
    for image in $images; do
        # Remove quotes from image
        image=$(echo "$image" | tr -d '"')
        
        # Check if image is in blacklist_images
        if [[ " ${blacklist_images[*]} " =~ $image ]]; then
            err_echo "  Skipping blacklisted image: $image"
            continue
        fi
        
        # Check if image belongs to TrueFoundry registry
        if [[ "$image" == "$default_registry"* ]]; then
            err_echo "  Including image from TrueFoundry registry: $image"
            filtered_images+=("$image")
        else
            err_echo "  Skipping external image: $image"
        fi
    done
    
    err_echo "Final filtered images count: ${#filtered_images[@]}"

    # Write filtered images to output file
    printf "%s\n" "${filtered_images[@]}" > "$output_file"
    err_echo "Dumped images to $output_file."
    err_echo "Cleaning up..."
    rm -f tmp_rendered_k8s_manifest.yaml
}

# Function to parse image URL and extract image name and tag
parse_image_url() {
    local image_url="$1"
    local destination_registry="$2"
    
    # Extract image name and tag using basic string manipulation
    local image_name=""
    local image_tag=""
    
    # Remove protocol if present
    local clean_url="${image_url#*://}"
    
    # Split by colon to separate name from tag
    if [[ "$clean_url" == *":"* ]]; then
        image_name="${clean_url%:*}"
        image_tag=":${clean_url#*:}"
    else
        # No tag specified - this is not allowed
        err_echo "ERROR: Image '$image_url' has no tag or digest specified"
        return 1
    fi
    
    # Handle digest if present
    if [[ "$image_tag" == *"@"* ]]; then
        # Keep both tag and digest
        image_tag=":${image_tag#*:}"
    fi
    
    # Extract just the image name without registry
    if [[ "$image_name" == *"/"* ]]; then
        local parts
        IFS='/' read -ra parts <<< "$image_name"
        if [[ "${parts[0]}" == *"."* ]]; then
            # Registry contains dots, skip first part
            image_name=$(IFS=/; echo "${parts[*]:1}")
        fi
    fi
    
    # Extract registry domain and optional prefix from destination_registry
    local registry_domain=""
    local dest_prefix=""
    
    # Check if destination_registry contains a path (prefix)
    if [[ "$destination_registry" == *"/"* ]]; then
        # Split into domain and prefix
        registry_domain="${destination_registry%%/*}"
        dest_prefix="${destination_registry#*/}"
    else
        # No prefix, just the registry domain
        registry_domain="$destination_registry"
        dest_prefix=""
    fi
    
    # Build the destination image URL
    if [ -n "$dest_prefix" ]; then
        local repo_name="${dest_prefix}/${image_name}"
        local new_image_url="$registry_domain/$repo_name$image_tag"
        echo "$repo_name"
        echo "$new_image_url"
    else
        local new_image_url="$registry_domain/$image_name$image_tag"
        echo "$image_name"
        echo "$new_image_url"
    fi
}

# Parse command line arguments
helm_repo="truefoundry"
helm_chart=""
helm_version=""
helm_values=""
source_registry_username=""
source_registry_password=""
destination_registry=""
destination_registry_username=""
destination_registry_password=""
ecr_tags=""
run_mode=true
force_copy=false
list_only=false
output_file=""

# Track if defaults are being used
using_default_helm_repo=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --helm-repo|-hr)
            helm_repo="$2"
            using_default_helm_repo=false
            shift 2
            ;;
        --helm-chart|-hc)
            helm_chart="$2"
            shift 2
            ;;
        --helm-version|-hv)
            helm_version="$2"
            shift 2
            ;;
        --helm-values|-hvf)
            helm_values="$2"
            shift 2
            ;;
        --source-user|-su)
            source_registry_username="$2"
            shift 2
            ;;
        --source-pass|-sp)
            source_registry_password="$2"
            shift 2
            ;;
        --dest-registry|-d)
            destination_registry="$2"
            shift 2
            ;;
        --dest-user|-du)
            destination_registry_username="$2"
            shift 2
            ;;
        --dest-pass|-dp)
            destination_registry_password="$2"
            shift 2
            ;;
        --ecr-tags|-et)
            ecr_tags="$2"
            shift 2
            ;;
        --dry-run)
            run_mode=false
            shift
            ;;
        --force-copy)
            force_copy=true
            shift
            ;;
        --list-only)
            list_only=true
            shift
            ;;
        --output-file|-o)
            output_file="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            err_echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set up signal handlers for graceful exit
trap cleanup SIGINT SIGTERM

err_echo ""
err_echo "========================================"
if [ "$list_only" = true ]; then
    err_echo "List Images from Helm Chart"
else
    err_echo "Clone Images to Your Registry"
fi
err_echo "========================================"
err_echo ""
# Warning if no values file is provided
if [ -z "$helm_values" ]; then
    err_echo "⚠ WARNING: No values file provided (--helm-values)"
    err_echo "  Using chart default values, which may not include all required images."
    err_echo "  To extract all images for your specific configuration, provide a values file with --helm-values"
    err_echo ""
fi
err_echo "Configuration:"
if [ "$using_default_helm_repo" = true ]; then
    err_echo "  Helm Repository: $helm_repo (using default)"
else
    err_echo "  Helm Repository: $helm_repo"
fi
err_echo "  Helm Chart: $helm_chart"
err_echo "  Helm Version: $helm_version"
if [ -n "$helm_values" ]; then
    err_echo "  Helm Values File: $helm_values"
else
    err_echo "  Helm Values File: (none - using chart defaults)"
fi
if [ "$list_only" = true ]; then
    err_echo "  Mode: LIST-ONLY (no copying will be performed)"
else
    err_echo "  Destination Registry: $destination_registry"
    if [ -n "$ecr_tags" ]; then
        err_echo "  ECR Tags: $ecr_tags"
    fi
    if [ -n "$source_registry_username" ]; then
        err_echo "  Source Registry: Authenticated"
    else
        err_echo "  Source Registry: Public (no credentials)"
    fi
    if [ "$run_mode" = false ]; then
        err_echo "  Mode: DRY-RUN (no operations will be performed)"
    else
        err_echo "  Mode: LIVE (operations will be performed)"
    fi
    if [ "$force_copy" = true ]; then
        err_echo "  Force Copy: Enabled (skipping existence checks)"
    fi
fi
err_echo ""
if [ "$list_only" = true ]; then
    err_echo "Process Steps:"
    err_echo "  1. Verify Helm repository is added"
    err_echo "  2. Extract default registry from helm chart"
    err_echo "  3. Render helm chart with helm template"
    err_echo "  4. Extract image references from rendered manifests"
    err_echo "  5. Filter images to only include TrueFoundry registry images"
    err_echo "  6. Output image list"
else
    err_echo "Process Steps:"
    err_echo "  1. Verify Helm repository is added"
    err_echo "  2. Extract default registry from helm chart"
    err_echo "  3. Render helm chart with helm template"
    err_echo "  4. Extract image references from rendered manifests"
    err_echo "  5. Filter images to only include TrueFoundry registry images"
    err_echo "  6. Create ECR repositories if needed (AWS ECR only)"
    err_echo "  7. Copy images to destination registry"
fi
err_echo ""

# Validate required arguments
if [ -z "$helm_chart" ]; then
    err_echo "ERROR: Missing required argument: --helm-chart"
    show_usage
    exit 1
fi

if [ -z "$helm_version" ]; then
    err_echo "ERROR: Missing required argument: --helm-version"
    show_usage
    exit 1
fi

# Destination registry only required if not in list-only mode
if [ "$list_only" = false ]; then
    if [ -z "$destination_registry" ]; then
        err_echo "ERROR: Missing required argument: --dest-registry (or use --list-only to skip copying)"
        show_usage
        exit 1
    fi
    
    # Cache ECR check result to avoid repeated function calls
    is_destination_ecr=$(is_aws_ecr "$destination_registry" && echo "true" || echo "false")
fi

# Validate output file path if specified
if [ -n "$output_file" ]; then
    # Check if file already exists and warn
    if [ -f "$output_file" ]; then
        err_echo "⚠ WARNING: Output file already exists and will be overwritten: $output_file"
    fi
    
    # Check if directory is writable
    output_dir=$(dirname "$output_file")
    if [ ! -d "$output_dir" ]; then
        err_echo "ERROR: Output directory does not exist: $output_dir"
        exit 1
    fi
    
    if [ ! -w "$output_dir" ]; then
        err_echo "ERROR: Output directory is not writable: $output_dir"
        exit 1
    fi
fi

temp_images_file="temp_${helm_chart}-images-${helm_version}"

if ! extract_images_from_helm_chart "$helm_repo" "$helm_chart" "$helm_version" "$helm_values" "$temp_images_file"; then
    err_echo "ERROR: Failed to extract images from helm chart"
    exit 1
fi

input_file="$temp_images_file"
err_echo ""
err_echo "Extracted images to temporary file: $input_file"

# If list-only mode, output the images and exit
if [ "$list_only" = true ]; then
    err_echo ""
    err_echo "========================================"
    err_echo "Image List"
    err_echo "========================================"
    
    images=$(cat "$input_file" | grep -v '^#' | grep -v '^$' | sort -u)
    echo "$images"
    
    # Write to output file if specified
    if [ -n "$output_file" ]; then
        echo "$images" > "$output_file"
        err_echo ""
        err_echo "Image list written to: $output_file"
    fi
    
    # Clean up temporary file
    rm -f "$temp_images_file"
    exit 0
fi

# check if skopeo is installed
if ! command -v skopeo &> /dev/null; then
    err_echo "ERROR: skopeo could not be found"
    err_echo "Please install skopeo: https://github.com/containers/skopeo/blob/main/install.md"
    exit 1
fi

# check if jq is installed
if ! command -v jq &> /dev/null; then
    err_echo "ERROR: jq could not be found"
    err_echo "Please install jq: https://jqlang.github.io/jq/download/"
    exit 1
fi

# Check if AWS CLI is installed for ECR operations
if [ "$is_destination_ecr" = "true" ]; then
    if ! command -v aws &> /dev/null; then
        err_echo "ERROR: AWS CLI could not be found"
        err_echo "Please install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS authentication using STS
    err_echo ""
    err_echo "Checking AWS authentication..."
    err_echo "----------------------------------------"
    
    if aws sts get-caller-identity >/dev/null 2>&1; then
        err_echo "✓ AWS authentication successful"
        caller_identity=$(aws sts get-caller-identity 2>/dev/null)
        account_id=$(echo "$caller_identity" | jq -r '.Account' 2>/dev/null)
        user_arn=$(echo "$caller_identity" | jq -r '.Arn' 2>/dev/null)
        user_id=$(echo "$caller_identity" | jq -r '.UserId' 2>/dev/null)
        
        err_echo "  Account ID: $account_id"
        err_echo "  User ARN: $user_arn"
        err_echo "  User ID: $user_id"
        err_echo "----------------------------------------"
    else
        err_echo "✗ AWS authentication failed"
        err_echo ""
        err_echo "ERROR: Not authenticated to AWS. Please authenticate using one of the following methods:"
        err_echo "  1. AWS CLI: aws configure"
        err_echo "  2. AWS SSO: aws sso login"
        err_echo "  3. Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_PROFILE"
        err_echo "  4. IAM roles (if running on EC2)"
        err_echo ""
        err_echo "For more information, see: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html"
        exit 1
    fi
fi

if [ -n "$destination_registry_username" ] && [ -n "$destination_registry_password" ]; then
    destination_creds="$destination_registry_username:$destination_registry_password"
else
    destination_creds=""
fi

if [ -n "$source_registry_username" ] && [ -n "$source_registry_password" ]; then
    source_creds="$source_registry_username:$source_registry_password"
else
    source_creds=""
fi

err_echo ""
err_echo "========================================"
err_echo "Starting image cloning process..."
err_echo "========================================"
err_echo "Input file: $input_file"
err_echo "Destination registry: $destination_registry"
if [ "$run_mode" = false ]; then
    err_echo "DRY-RUN MODE: No actual operations will be performed"
fi
err_echo ""

# get list of images from input file
images=$(cat "$input_file" | grep -v '^#' | grep -v '^$' | sort -u)

# Count images correctly (handle empty case)
if [ -z "$images" ]; then
    image_count=0
else
    image_count=$(echo "$images" | wc -l | tr -d ' ')
fi
err_echo "Found $image_count images to clone:"

if [ "$image_count" -eq 0 ]; then
    err_echo "No images found to process. Exiting."
    rm -f "$temp_images_file"
    exit 0
fi

err_echo "----------------------------------------"
echo "$images" | while read -r image; do
    err_echo "  - $image"
done
err_echo "----------------------------------------"

# Handle ECR repository analysis and creation if destination is ECR
if [ "$is_destination_ecr" = "true" ]; then
    err_echo ""
    err_echo "=== AWS ECR Repository Analysis ==="
    err_echo "Destination: $destination_registry"
    err_echo ""

    # Analyze required repositories
    repos_to_create=()
    repos_existing=()
    
    err_echo "Checking for existing ECR repositories..."
    err_echo "----------------------------------------"
    
    for image_url in $images; do
        # Remove leading/trailing whitespace
        image_url=$(echo "$image_url" | xargs)
        
        # Parse image URL to get repository name
        if ! parsed_result=$(parse_image_url "$image_url" "$destination_registry" 2>&1); then
            err_echo "  ⚠ WARNING: Skipping image '$image_url' - no tag or digest specified"
            continue
        fi
        
        repo_name=$(echo "$parsed_result" | head -n1)
        
        err_echo "  Checking repository: $destination_registry/$repo_name"
        
        # Check if repository exists
        if ecr_repo_exists "$destination_registry" "$repo_name"; then
            err_echo "    ✓ Repository exists"
            repos_existing+=("$repo_name")
        else
            err_echo "    ✗ Repository does not exist (will be created)"
            repos_to_create+=("$repo_name")
        fi
    done
    
    err_echo "----------------------------------------"
    err_echo "Repository analysis complete."
    err_echo ""
    
    # Display repository analysis
    err_echo "Repository Analysis:"
    if [ ${#repos_existing[@]} -gt 0 ]; then
        err_echo "  Existing repositories:"
        for repo in "${repos_existing[@]}"; do
            err_echo "    - $destination_registry/$repo"
        done
    fi
    
    if [ ${#repos_to_create[@]} -gt 0 ]; then
        err_echo "  Repositories to be created:"
        for repo in "${repos_to_create[@]}"; do
            err_echo "    - $destination_registry/$repo"
        done
    fi
    
    # Create repositories if needed
    if [ ${#repos_to_create[@]} -gt 0 ]; then
        err_echo ""
        log_msg "Creating ECR repositories..."
        for repo in "${repos_to_create[@]}"; do
            log_msg "Creating repository: $destination_registry/$repo"
            
            if [ "$run_mode" = false ]; then
                log_msg "Skipping actual repository creation (remove --dry-run to perform operations)"
            else
                if create_ecr_repo "$destination_registry" "$repo" "$ecr_tags"; then
                    log_msg "✓ Created repository: $destination_registry/$repo"
                    err_echo ""
                else
                    log_msg "✗ Failed to create repository: $destination_registry/$repo"
                    err_echo "Please check AWS permissions and try again"
                    exit 1
                fi
            fi
        done
    else
        log_msg "All required repositories already exist."
    fi
    
    err_echo ""
    err_echo ""
fi

# Process each image from input file
err_echo ""
err_echo "========================================"
err_echo "Processing images..."
err_echo "========================================"

# Set operation flag to true when we start processing
in_operation=true

for image_url in $images; do
    # Remove leading/trailing whitespace
    image_url=$(echo "$image_url" | xargs)
    
    # Increment total images counter
    ((total_images++))
    
    err_echo ""
    err_echo "----------------------------------------"
    
    # Parse image URL to get new destination
    if ! parsed_result=$(parse_image_url "$image_url" "$destination_registry" 2>&1); then
        err_echo "  ⚠ WARNING: Skipping image '$image_url' - no tag or digest specified"
        err_echo "  This image will not be copied to the destination registry"
        continue
    fi
    
    image_name=$(echo "$parsed_result" | head -n1)
    new_image_url=$(echo "$parsed_result" | tail -n1)
    
    err_echo "Source: $image_url"
    err_echo "Destination: $new_image_url"
    err_echo ""

    
    
    if [ "$force_copy" = false ]; then
        err_echo "Checking if image exists: $new_image_url"

        # Check if the new_image_url already exists
        inspect_cmd="skopeo inspect --override-os linux docker://$new_image_url"
        if [ -n "$destination_creds" ]; then
            inspect_cmd="$inspect_cmd --creds=$destination_creds"
        fi
        
        # Capture both output and exit code
        inspect_output=$($inspect_cmd 2>&1)
        inspect_exit_code=$?
        
        if [ $inspect_exit_code -eq 0 ]; then
            err_echo "✓ Image already exists. Skipping..."
            ((skipped_images++))
            continue
        else
            # Check if the error is an authentication error
            if is_auth_error "$inspect_output"; then
                handle_auth_error "$new_image_url" "$inspect_output" "inspect"
            else
                log_msg "✗ Image does not exist. Proceeding with copy..."
                # if [ -n "$inspect_output" ]; then
                #     log_msg "Inspect error: $inspect_output"
                # fi
            fi
        fi
    else
        log_msg "Force copy enabled - skipping existence check"
    fi
    
    log_msg "Copying image: $new_image_url"

    # Get skopeo command
    skopeo_cmd=$(build_skopeo_command "$image_url" "$new_image_url")
    
    if [ "$run_mode" = false ]; then
        log_msg "Skipping actual image copy (remove --dry-run to perform operations)"
    else
        # Copy image using skopeo with signal handling
        log_msg "Running command: $skopeo_cmd"
        err_echo ""
        
        # Execute skopeo command and capture exit code
        if $skopeo_cmd; then
            skopeo_exit_code=0
        else
            skopeo_exit_code=$?
        fi
        
        if [ $skopeo_exit_code -eq 0 ]; then
            log_msg "✓ Successfully copied image: $new_image_url"
            ((copied_images++))
            successfully_copied_images+=("$new_image_url")
        else
            # Check if the failure was due to a signal
            if [ $skopeo_exit_code -eq 130 ]; then
                log_msg "⚠ Image copy interrupted by user"
                cleanup
            else
                log_msg "✗ ERROR: Failed to copy image: $new_image_url"
                track_error "$new_image_url" "Copy failed (exit code: $skopeo_exit_code)"
            fi
        fi
    fi
done

# Reset operation flag
in_operation=false

# Clean up temporary file
if [ -n "$temp_images_file" ] && [ -f "$temp_images_file" ]; then
    err_echo ""
    err_echo "Cleaning up temporary file: $temp_images_file"
    rm -f "$temp_images_file"
fi

err_echo ""
err_echo "========================================"
err_echo "Image cloning process complete."
err_echo "========================================"

# Write successfully copied images to output file if specified
if [ -n "$output_file" ] && [ ${#successfully_copied_images[@]} -gt 0 ]; then
    printf "%s\n" "${successfully_copied_images[@]}" > "$output_file"
    err_echo ""
    err_echo "Successfully copied images written to: $output_file"
fi

# Display errors if any
if [ $failed_images -gt 0 ]; then
    err_echo ""
    err_echo "Errors encountered:"
    for error in "${error_messages[@]}"; do
        err_echo "  - $error"
    done
    err_echo ""
    display_summary
    err_echo ""
    err_echo "Exit code: 1 (some images failed to copy)"
    exit 1
else
    err_echo ""
    display_summary
    err_echo ""
    err_echo "Exit code: 0 (all operations completed successfully)"
    exit 0
fi