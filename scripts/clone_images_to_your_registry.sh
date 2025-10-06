#!/bin/bash

# Global variable to track if we're in the middle of an operation
in_operation=false

# Function to handle cleanup on exit
cleanup() {
    if [ "$in_operation" = true ]; then
        echo ""
        echo "Received interrupt signal. Cleaning up..."
        echo "Script interrupted by user."
    fi
    exit 130  # Standard exit code for SIGINT
}

# Function to show usage
show_usage() {
    echo "Usage: $0 --input <input_file> --source-user <source_username> --source-pass <source_password> --dest-registry <destination_registry> --dest-user <dest_username> --dest-pass <dest_password> [--dest-prefix <ecr_prefix>] [--dry-run]"
    echo ""
    echo "Arguments:"
    echo "  --input, -i              Input file containing Docker images (required)"
    echo "  --source-user, -su       Source registry username (required)"
    echo "  --source-pass, -sp       Source registry password (required)"
    echo "  --dest-registry, -d      Destination registry URL (required)"
    echo "  --dest-user, -du         Destination registry username (required)"
    echo "  --dest-pass, -dp         Destination registry password (required)"
    echo "  --dest-prefix, -dpf      ECR repository prefix (required when destination is AWS ECR)"
    echo "  --dry-run                Show what would be done without actually doing it"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --input images.txt --source-user srcuser --source-pass srcpass --dest-registry my-registry.com --dest-user destuser --dest-pass destpass"
    echo "  $0 -i images.txt -su myuser -sp mypass -d 123456789012.dkr.ecr.us-west-2.amazonaws.com -du AWS -dp mypass -dpf myapp"
    echo "  $0 -i images.txt -su myuser -sp mypass -d my-registry.com -du myuser -dp mypass"
    echo "  $0 -i images.txt -su myuser -sp mypass -d my-registry.com -du myuser -dp mypass --dry-run"
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
    local region=$(echo "$registry" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
    
    if [ -z "$region" ]; then
        echo "ERROR: Could not extract AWS region from ECR registry URL"
        return 1
    fi
    
    echo "Creating ECR repository: $repo_name in region: $region"
    aws ecr create-repository --region "$region" --repository-name "$repo_name" >/dev/null 2>&1
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
    if is_aws_ecr "$destination_registry" && [ -n "$dest_prefix" ]; then
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
input_file=""
source_registry_username=""
source_registry_password=""
destination_registry=""
destination_registry_username=""
destination_registry_password=""
dest_prefix=""
dry_run=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i)
            input_file="$2"
            shift 2
            ;;
        --src-username|-su)
            source_registry_username="$2"
            shift 2
            ;;
        --src-password|-sp)
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

# Set up signal handlers for graceful exit
trap cleanup SIGINT SIGTERM

# Validate required arguments
if [ -z "$input_file" ] || [ -z "$destination_registry" ]; then
    echo "ERROR: Missing required arguments"
    show_usage
    exit 1
fi

# Check if destination is AWS ECR and validate dest-prefix
if is_aws_ecr "$destination_registry"; then
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

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "ERROR: Input file '$input_file' not found"
    show_usage
    exit 1
fi

# check if skopeo is installed
if ! command -v skopeo &> /dev/null; then
    echo "ERROR: skopeo could not be found"
    echo "Please install skopeo: https://github.com/containers/skopeo/blob/main/install.md"
    exit 1
fi

# Check if AWS CLI is installed for ECR operations
if is_aws_ecr "$destination_registry"; then
    if ! command -v aws &> /dev/null; then
        echo "ERROR: AWS CLI could not be found"
        echo "Please install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS authentication using STS
    echo "Checking AWS authentication..."
    echo "----------------------------------------"
    
    if aws sts get-caller-identity >/dev/null 2>&1; then
        echo "✓ AWS authentication successful"
        caller_identity=$(aws sts get-caller-identity 2>/dev/null)
        account_id=$(echo "$caller_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
        user_arn=$(echo "$caller_identity" | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)
        user_id=$(echo "$caller_identity" | grep -o '"UserId": "[^"]*"' | cut -d'"' -f4)
        
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

echo "Starting image cloning process..."
echo "Input file: $input_file"
echo "Destination registry: $destination_registry"
if [ "$dry_run" = true ]; then
    echo "DRY RUN MODE: No actual operations will be performed"
fi

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
if is_aws_ecr "$destination_registry"; then
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
                if create_ecr_repo "$destination_registry" "$repo"; then
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
echo "Starting image cloning process..."
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
        
        # Use different skopeo command based on destination registry type
        if is_aws_ecr "$destination_registry"; then
            skopeo_cmd="skopeo copy --multi-arch"
        else
            skopeo_cmd="skopeo copy --multi-arch index-only"
        fi
        
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

        # Use different skopeo command based on destination registry type
        if is_aws_ecr "$destination_registry"; then
            skopeo_cmd="skopeo copy --all"
        else
            skopeo_cmd="skopeo copy --multi-arch index-only"
        fi
        
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

echo ""
echo "========================================"
echo "Image cloning process complete."