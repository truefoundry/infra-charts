#!/bin/bash

# Global variable to track if we're in the middle of an operation
in_operation=false

# Global variable to cache ECR check result
is_destination_ecr=false

# Function to handle cleanup on exit
cleanup() {
    if [ "$in_operation" = true ]; then
        echo ""
        echo "Received interrupt signal. Cleaning up..."
        echo "Script interrupted by user."
    fi
    exit 130  # Standard exit code for SIGINT
}

# Function to show Helm repository error message
show_helm_repo_error() {
    echo ""
    echo "Please add the Helm repository first:"
    echo "  helm repo add truefoundry https://truefoundry.github.io/infra-charts"
    echo "  helm repo update"
    echo ""
}

# Function to get skopeo command based on destination registry type and mode
get_skopeo_command() {
    local mode="$1"  # "dry-run" or "copy"
    
    if [ "$is_destination_ecr" = "true" ]; then
        if [ "$mode" = "dry-run" ]; then
            echo "skopeo copy --multi-arch"
        else
            echo "skopeo copy --all"
        fi
    else
        echo "skopeo copy --multi-arch index-only"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 --helm-chart <helm_chart> --helm-version <helm_version> --dest-registry <destination_registry> --dest-user <dest_username> --dest-pass <dest_password> [--helm-repo <helm_repo>] [--helm-values <values_file>] [--source-user <source_username>] [--source-pass <source_password>] [--dest-prefix <ecr_prefix>] [--ecr-tags <tags>] [--dry-run]"
    echo ""
    echo "Arguments:"
    echo "  --helm-repo, -hr         Helm repository URL or name (default: truefoundry)"
    echo "  --helm-chart, -hc        Helm chart name (required)"
    echo "  --helm-version, -hv      Helm chart version (required)"
    echo "  --helm-values, -hvf      Helm chart values file (optional)"
    echo "  --source-user, -su       Source registry username (optional)"
    echo "  --source-pass, -sp       Source registry password (optional)"
    echo "  --dest-registry, -d      Destination registry URL (required)"
    echo "  --dest-user, -du         Destination registry username (required)"
    echo "  --dest-pass, -dp         Destination registry password (required)"
    echo "  --dest-prefix, -dpf      ECR repository prefix (required when destination is AWS ECR)"
    echo "  --ecr-tags, -et          Tags for ECR repositories in format Key1=Value1,Key2=Value2 (optional, AWS ECR only)"
    echo "  --dry-run                Show what would be done without actually doing it"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Using default helm-repo"
    echo "  $0 -hc truefoundry -hv 0.89.4 -d my-registry.com -du myuser -dp mypass"
    echo ""
    echo "  # Using default helm-repo with ECR"
    echo "  $0 -hc truefoundry -hv 0.89.4 -d 123456789012.dkr.ecr.us-west-2.amazonaws.com -du AWS -dp mypass -dpf myapp"
    echo ""
    echo "  # Using a different chart"
    echo "  $0 -hc tfy-agent -hv 0.2.81-rc.2 -hvf values.yaml -d 123456789012.dkr.ecr.us-west-2.amazonaws.com -du AWS -dp mypass -dpf myapp"
    echo ""
    echo "  # Full example with all options"
    echo "  $0 -hr truefoundry -hc truefoundry -hv 0.89.4 -hvf values.yaml -d 123456789012.dkr.ecr.us-west-2.amazonaws.com -du AWS -dp mypass -dpf myapp --ecr-tags \"Environment=Production,Team=Platform\""
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
    local region=$(echo "$registry" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
    
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
    local region=$(echo "$registry" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
    
    if [ -z "$region" ]; then
        echo "ERROR: Could not extract AWS region from ECR registry URL"
        return 1
    fi
    
    echo "Creating ECR repository: $repo_name in region: $region"
    
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
                echo "WARNING: Skipping invalid tag pair (no '=' found): '$tag_pair'"
            fi
        done
        
        if [ -n "$tag_array" ]; then
            # Format as proper JSON array
            local json_tags="[${tag_array}]"
            aws_cmd="$aws_cmd --tags '$json_tags'"
        else
            echo "WARNING: No valid tags found after parsing"
        fi
    fi
    
    # Execute the command
    local aws_output
    local aws_exit_code
    
    if aws_output=$(eval "$aws_cmd" 2>&1); then
        aws_exit_code=0
    else
        aws_exit_code=$?
        echo "ERROR: Failed to create ECR repository"
        echo "AWS CLI Error: $aws_output"
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
    echo ""
    echo "========================================"
    echo "Verifying Helm repository..."
    echo "========================================"

    echo "Checking if Helm repository is added..."
    
    # Get list of existing repos
    local existing_repos=$(helm repo list -o json 2>/dev/null)
    local helm_exit_code=$?
    
    if [ $helm_exit_code -ne 0 ] || [ -z "$existing_repos" ] || [ "$existing_repos" = "null" ]; then
        # No repos exist yet
        echo ""
        echo "✗ ERROR: No Helm repositories found!"
        show_helm_repo_error
        return 1
    fi
    
    # Check if the repository name exists
    local repo_exists=$(echo "$existing_repos" | jq -r ".[] | select(.name == \"$repo_name\") | .name" 2>/dev/null)
    
    if [ -n "$repo_exists" ]; then
        local existing_url=$(echo "$existing_repos" | jq -r ".[] | select(.name == \"$repo_name\") | .url" 2>/dev/null)
        if [ -n "$existing_url" ] && [ "$existing_url" != "null" ]; then
            echo "✓ Helm repository found: $repo_name -> $existing_url"
        else
            echo "✗ ERROR: Helm repository '$repo_name' found but URL is invalid!"
            return 1
        fi
    else
        echo "✗ ERROR: Helm repository '$repo_name' not found!"
        show_helm_repo_error
        echo "Available repositories:"
        helm repo list 2>/dev/null
        echo ""
        return 1
    fi

    local chart_with_version=$(helm search repo "$repo_name/$chart_name" --version "$version" -o json | jq -r ".[] | select(.version == \"$version\") | .version" 2>/dev/null)
    if [ -z "$chart_with_version" ]; then
        echo "✗ ERROR: Chart $chart_name with version $version not found!"
        show_helm_repo_error
        echo "For available chart versions:"
        echo "  helm search repo "$repo_name/$chart_name" --versions"
        echo ""
        return 1
    fi

    echo "✓ Chart $chart_name with version $version found!"

    # Extract the default global.image.registry value from the chart using helm
    echo "Getting default global.image.registry from chart..."
    default_registry=$(helm show values "$repo_name/$chart_name" --version "$version" --jsonpath "{.global.image.registry}")
    
    if [ -z "$default_registry" ] || [ "$default_registry" = "null" ]; then
        default_registry="tfy.jfrog.io"
        echo "Using fallback default registry: $default_registry"
    else
        echo "Found default registry in chart: $default_registry"
    fi

    if [ -n "$values_file" ] && [ -f "$values_file" ]; then
        echo "Using provided values file: $values_file with default global.image.registry=$default_registry"
        helm template "$repo_name/$chart_name" --version "$version" -f "$values_file" --set global.image.registry="$default_registry" > tmp_rendered_k8s_manifest.yaml
    else
        echo "No values file provided, using default values with global.image.registry=$default_registry"
        helm template "$repo_name/$chart_name" --version "$version" --set global.image.registry="$default_registry" > tmp_rendered_k8s_manifest.yaml
    fi

    # Extract all image references from the rendered YAML
    images=$(grep -E '^\s*image:\s*' tmp_rendered_k8s_manifest.yaml | awk '{print $2}' | tr -d '"' | tr -d "'" | sort -u)
    
    echo "Found $(echo "$images" | wc -l) total images"

    blacklist_images=('python:3.11.9-bullseye')
    echo "Filtering images to only include those from registry: $default_registry"

    filtered_images=()
    for image in $images; do
        # Remove quotes from image
        image=$(echo "$image" | tr -d '"')
        
        # Check if image is in blacklist_images
        if [[ " ${blacklist_images[@]} " =~ " $image " ]]; then
            echo "  Skipping blacklisted image: $image"
            continue
        fi
        
        # Check if image belongs to TrueFoundry registry
        if [[ "$image" == "$default_registry"* ]]; then
            echo "  Including image from TrueFoundry registry: $image"
            filtered_images+=("$image")
        else
            echo "  Skipping external image: $image"
        fi
    done
    
    echo "Final filtered images count: ${#filtered_images[@]}"

    # Write filtered images to output file
    printf "%s\n" "${filtered_images[@]}" > "$output_file"
    echo "Dumped images to $output_file."
    echo "Cleaning up..."
    rm -f tmp_rendered_k8s_manifest.yaml
}

# Function to parse image URL and extract image name and tag
parse_image_url() {
    local image_url="$1"
    local destination_registry="$2"
    local dest_prefix="$3"
    
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
        image_name="$clean_url"
        image_tag=":latest"
    fi
    
    # Handle digest if present
    if [[ "$image_tag" == *"@"* ]]; then
        # Keep both tag and digest
        image_tag=":${image_tag#*:}"
    fi
    
    # Extract just the image name without registry
    if [[ "$image_name" == *"/"* ]]; then
        local parts=(${image_name//\// })
        if [[ "${parts[0]}" == *"."* ]]; then
            # Registry contains dots, skip first part
            image_name=$(IFS=/; echo "${parts[*]:1}")
        fi
    fi
    
    # Handle ECR prefix if destination is ECR
    if [ "$is_destination_ecr" = "true" ] && [ -n "$dest_prefix" ]; then
        local ecr_repo_name="${dest_prefix}/${image_name}"
        local new_image_url="$destination_registry/$ecr_repo_name$image_tag"
        echo "$ecr_repo_name"
        echo "$new_image_url"
    else
        local new_image_url="$destination_registry/$image_name$image_tag"
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
dest_prefix=""
ecr_tags=""
dry_run=false

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
        --dest-prefix|-dpf)
            dest_prefix="$2"
            shift 2
            ;;
        --ecr-tags|-et)
            ecr_tags="$2"
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Cache ECR check result to avoid repeated function calls
is_destination_ecr=$(is_aws_ecr "$destination_registry" && echo "true" || echo "false")

# Set up signal handlers for graceful exit
trap cleanup SIGINT SIGTERM

echo ""
echo "========================================"
echo "Clone Images to Your Registry"
echo "========================================"
echo ""
echo "Configuration:"
if [ "$using_default_helm_repo" = true ]; then
    echo "  Helm Repository: $helm_repo (using default)"
else
    echo "  Helm Repository: $helm_repo"
fi
echo "  Helm Chart: $helm_chart"
echo "  Helm Version: $helm_version"
if [ -n "$helm_values" ]; then
    echo "  Helm Values File: $helm_values"
fi
echo "  Destination Registry: $destination_registry"
if [ -n "$dest_prefix" ]; then
    echo "  Destination Prefix: $dest_prefix"
fi
if [ -n "$ecr_tags" ]; then
    echo "  ECR Tags: $ecr_tags"
fi
if [ -n "$source_registry_username" ]; then
    echo "  Source Registry: Authenticated"
else
    echo "  Source Registry: Public (no credentials)"
fi
if [ "$dry_run" = true ]; then
    echo "  Mode: DRY RUN"
else
    echo "  Mode: LIVE"
fi
echo ""
echo "Process Steps:"
echo "  1. Verify Helm repository is added"
echo "  2. Extract default registry from helm chart"
echo "  3. Render helm chart with helm template"
echo "  4. Extract image references from rendered manifests"
echo "  5. Filter images to only include TrueFoundry registry images"
echo "  6. Create ECR repositories if needed (AWS ECR only)"
echo "  7. Copy images to destination registry"
echo ""

# Validate required arguments
if [ -z "$destination_registry" ]; then
    echo "ERROR: Missing required argument: --dest-registry"
    show_usage
    exit 1
fi

if [ -z "$helm_chart" ]; then
    echo "ERROR: Missing required argument: --helm-chart"
    show_usage
    exit 1
fi

if [ -z "$helm_version" ]; then
    echo "ERROR: Missing required argument: --helm-version"
    show_usage
    exit 1
fi

# Check if destination is AWS ECR and validate dest-prefix
if [ "$is_destination_ecr" = "true" ]; then
    if [ -z "$dest_prefix" ]; then
        echo "ERROR: --dest-prefix is required when destination is AWS ECR"
        echo "The dest-prefix will be used as a prefix for ECR repository names"
        show_usage
        exit 1
    fi

    if [[ "$destination_registry" =~ \.com/.* ]]; then
        echo "ERROR: Invalid registry format. Only registry URLs are allowed, not paths."
        echo "Expected format: 123456789012.dkr.ecr.us-west-2.amazonaws.com"
        echo "Got: $destination_registry"
        show_usage
        exit 1
    fi
fi

# Extract images from helm chart
echo ""
echo "========================================"
echo "Extracting images from helm chart..."
echo "========================================"
temp_images_file="temp_${helm_chart}-images-${helm_version}"

if ! extract_images_from_helm_chart "$helm_repo" "$helm_chart" "$helm_version" "$helm_values" "$temp_images_file"; then
    echo "ERROR: Failed to extract images from helm chart"
    exit 1
fi

input_file="$temp_images_file"
echo ""
echo "Extracted images to temporary file: $input_file"

# check if skopeo is installed
if ! command -v skopeo &> /dev/null; then
    echo "ERROR: skopeo could not be found"
    echo "Please install skopeo: https://github.com/containers/skopeo/blob/main/install.md"
    exit 1
fi

# check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq could not be found"
    echo "Please install jq: https://jqlang.github.io/jq/download/"
    exit 1
fi

# Check if AWS CLI is installed for ECR operations
if [ "$is_destination_ecr" = "true" ]; then
    if ! command -v aws &> /dev/null; then
        echo "ERROR: AWS CLI could not be found"
        echo "Please install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS authentication using STS
    echo ""
    echo "Checking AWS authentication..."
    echo "----------------------------------------"
    
    if aws sts get-caller-identity >/dev/null 2>&1; then
        echo "✓ AWS authentication successful"
        caller_identity=$(aws sts get-caller-identity 2>/dev/null)
        account_id=$(echo "$caller_identity" | jq -r '.Account' 2>/dev/null)
        user_arn=$(echo "$caller_identity" | jq -r '.Arn' 2>/dev/null)
        user_id=$(echo "$caller_identity" | jq -r '.UserId' 2>/dev/null)
        
        echo "  Account ID: $account_id"
        echo "  User ARN: $user_arn"
        echo "  User ID: $user_id"
        echo "----------------------------------------"
    else
        echo "✗ AWS authentication failed"
        echo ""
        echo "ERROR: Not authenticated to AWS. Please authenticate using one of the following methods:"
        echo "  1. AWS CLI: aws configure"
        echo "  2. AWS SSO: aws sso login"
        echo "  3. Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_PROFILE"
        echo "  4. IAM roles (if running on EC2)"
        echo ""
        echo "For more information, see: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html"
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

echo ""
echo "========================================"
echo "Starting image cloning process..."
echo "========================================"
echo "Input file: $input_file"
echo "Destination registry: $destination_registry"
if [ "$dry_run" = true ]; then
    echo "DRY RUN MODE: No actual operations will be performed"
fi
echo ""

# get list of images from input file
images=$(cat "$input_file" | grep -v '^#' | grep -v '^$' | sort -u)

image_count=$(echo "$images" | wc -l)
echo "Found $image_count images to clone:"
echo "----------------------------------------"
echo "$images" | while read -r image; do
    echo "  - $image"
done
echo "----------------------------------------"

# Handle ECR repository analysis and creation if destination is ECR
if [ "$is_destination_ecr" = "true" ]; then
    echo ""
    echo "=== AWS ECR Repository Analysis ==="
    echo "Destination: $destination_registry"
    echo "ECR Prefix: $dest_prefix"
    echo ""

    # Analyze required repositories
    repos_to_create=()
    repos_existing=()
    
    echo "Checking for existing ECR repositories..."
    echo "----------------------------------------"
    
    for image_url in $images; do
        # Remove leading/trailing whitespace
        image_url=$(echo "$image_url" | xargs)
        
        # Parse image URL to get repository name
        parsed_result=$(parse_image_url "$image_url" "$destination_registry" "$dest_prefix")
        ecr_repo_name=$(echo "$parsed_result" | head -n1)
        
        echo "  Checking repository: $ecr_repo_name"
        
        # Check if repository exists
        if ecr_repo_exists "$destination_registry" "$ecr_repo_name"; then
            echo "    ✓ Repository exists"
            repos_existing+=("$ecr_repo_name")
        else
            echo "    ✗ Repository does not exist (will be created)"
            repos_to_create+=("$ecr_repo_name")
        fi
    done
    
    echo "----------------------------------------"
    echo "Repository analysis complete."
    echo ""
    
    # Display repository analysis
    echo "Repository Analysis:"
    if [ ${#repos_existing[@]} -gt 0 ]; then
        echo "  Existing repositories:"
        for repo in "${repos_existing[@]}"; do
            echo "    - $repo"
        done
    fi
    
    if [ ${#repos_to_create[@]} -gt 0 ]; then
        echo "  Repositories to be created:"
        for repo in "${repos_to_create[@]}"; do
            echo "    - $repo"
        done
    fi
    
    # Create repositories if needed
    if [ ${#repos_to_create[@]} -gt 0 ]; then
        echo ""
        if [ "$dry_run" = true ]; then
            echo "DRY RUN: The following ECR repositories would be created:"
            for repo in "${repos_to_create[@]}"; do
                echo "  - $repo"
            done
            echo ""
            echo "DRY RUN: Skipping actual repository creation"
        else
            echo "Creating ECR repositories..."
            for repo in "${repos_to_create[@]}"; do
                if create_ecr_repo "$destination_registry" "$repo" "$ecr_tags"; then
                    echo "  ✓ Created repository: $repo"
                else
                    echo "  ✗ Failed to create repository: $repo"
                    echo "Please check AWS permissions and try again"
                    exit 1
                fi
            done
        fi
    else
        echo "All required repositories already exist."
    fi
    
    echo ""
    echo ""
fi

# Process each image from input file
echo ""
echo "========================================"
echo "Processing images..."
echo "========================================"

# Set operation flag to true when we start processing
in_operation=true

for image_url in $images; do
    # Remove leading/trailing whitespace
    image_url=$(echo "$image_url" | xargs)
    
    echo ""
    echo "Processing image: $image_url"
    echo "----------------------------------------"
    
    # Parse image URL to get new destination
    parsed_result=$(parse_image_url "$image_url" "$destination_registry" "$dest_prefix")
    image_name=$(echo "$parsed_result" | head -n1)
    new_image_url=$(echo "$parsed_result" | tail -n1)
    
    echo "  Source: $image_url"
    echo "  Destination: $new_image_url"
    
    if [ "$dry_run" = true ]; then
        echo "  DRY RUN: Would check if image exists: $new_image_url"
        echo "  DRY RUN: Would copy image from $image_url to $new_image_url"
        
        # Get skopeo command for dry-run mode
        skopeo_cmd=$(get_skopeo_command "dry-run")
        
        if [ -n "$source_creds" ]; then
            skopeo_cmd="$skopeo_cmd --src-creds=$source_creds"
        fi

        if [ -n "$destination_creds" ]; then
            skopeo_cmd="$skopeo_cmd --dest-creds=$destination_creds"
        fi

        skopeo_cmd="$skopeo_cmd docker://$image_url docker://$new_image_url"
        
        echo "  DRY RUN: Would run command: $skopeo_cmd"
        echo "  DRY RUN: Skipping actual image copy"
        echo "  ✓ DRY RUN: Image processing complete"
    else
        echo "  Checking if image exists: $new_image_url"

        # Check if the new_image_url already exists
        if docker manifest inspect "$new_image_url" >/dev/null 2>&1; then
            echo "  ✓ Image already exists. Skipping..."
            continue
        else
            echo "  ✗ Image does not exist. Proceeding with copy..."
        fi
        
        echo "  Copying image: $new_image_url"

        # Get skopeo command for copy mode
        skopeo_cmd=$(get_skopeo_command "copy")
        
        if [ -n "$source_creds" ]; then
            skopeo_cmd="$skopeo_cmd --src-creds=$source_creds"
        fi

        if [ -n "$destination_creds" ]; then
            skopeo_cmd="$skopeo_cmd --dest-creds=$destination_creds"
        fi

        skopeo_cmd="$skopeo_cmd docker://$image_url docker://$new_image_url"
        
        echo "  Running command: $skopeo_cmd"

        # Copy image using skopeo with signal handling
        if $skopeo_cmd; then
            echo "  ✓ Successfully copied image: $new_image_url"
        else
            # Check if the failure was due to a signal
            if [ $? -eq 130 ]; then
                echo "  ⚠ Image copy interrupted by user"
                cleanup
            else
                echo "  ✗ ERROR: Failed to copy image: $new_image_url"
            fi
        fi
    fi
done

# Reset operation flag
in_operation=false

# Clean up temporary file
if [ -n "$temp_images_file" ] && [ -f "$temp_images_file" ]; then
    echo ""
    echo "Cleaning up temporary file: $temp_images_file"
    rm -f "$temp_images_file"
fi

echo ""
echo "========================================"
echo "Image cloning process complete."
echo "========================================"