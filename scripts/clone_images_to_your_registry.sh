#!/bin/bash

# Function to show usage
show_usage() {
    echo "Usage: $0 --input <input_file> --source-user <source_username> --source-pass <source_password> --destination <destination_registry> --dest-user <dest_username> --dest-pass <dest_password>"
    echo ""
    echo "Arguments:"
    echo "  --input, -i              Input file containing Docker images (required)"
    echo "  --source-user, -su       Source registry username (required)"
    echo "  --source-pass, -sp       Source registry password (required)"
    echo "  --destination, -d        Destination registry URL (required)"
    echo "  --dest-user, -du         Destination registry username (required)"
    echo "  --dest-pass, -dp         Destination registry password (required)"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --input images.txt --source-user srcuser --source-pass srcpass --destination my-registry.com --dest-user destuser --dest-pass destpass"
    echo "  $0 -i images.txt -su myuser -sp mypass -d my-registry.com -du myuser -dp mypass"
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
    
    image_name=$image_name
    local new_image_url="$destination_registry/$image_name$image_tag"
    
    echo "$image_name"
    echo "$new_image_url"
}

# Parse command line arguments
input_file=""
source_registry_username=""
source_registry_password=""
destination_registry=""
destination_registry_username=""
destination_registry_password=""

show_usage() {
    echo "Usage: $0 --input <input_file> --src-username <source_username> --src-password <source_password> --dest-registry <destination_registry> --dest-username <dest_username> --dest-password <dest_password>"
    echo ""
    echo "Arguments:"
    echo "  --input, -i              Input file containing Docker images (required)"
    echo "  --src-username, -su       Source registry username (optional)"
    echo "  --src-password, -sp       Source registry password (optional)"
    echo "  --dest-registry, -d        Destination registry URL (required)"
    echo "  --dest-username, -du         Destination registry username (optional)"
    echo "  --dest-password, -dp         Destination registry password (optional)"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
}

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
        --dest-username|-du)
            destination_registry_username="$2"
            shift 2
            ;;
        --dest-password|-dp)
            destination_registry_password="$2"
            shift 2
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

# Validate required arguments
if [ -z "$input_file" ] || [ -z "$source_registry_username" ] || [ -z "$source_registry_password" ] || [ -z "$destination_registry" ] || [ -z "$destination_registry_username" ] || [ -z "$destination_registry_password" ]; then
    echo "ERROR: Missing required arguments"
    show_usage
    exit 1
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

# get list of images from input file
images=$(cat "$input_file" | grep -v '^#' | grep -v '^$' | sort -u)

echo "Found $(echo "$images" | wc -l) images to clone"

# Process each image from input file
for image_url in $images; do
    # Remove leading/trailing whitespace
    image_url=$(echo "$image_url" | xargs)
    
    echo "Processing image: $image_url"
    
    # Parse image URL to get new destination
    parsed_result=$(parse_image_url "$image_url" "$destination_registry")
    image_name=$(echo "$parsed_result" | head -n1)
    new_image_url=$(echo "$parsed_result" | tail -n1)
    
    echo "Checking if image exists: $new_image_url"

    # Check if the new_image_url already exists
    if docker manifest inspect "$new_image_url" >/dev/null 2>&1; then
        echo "Image $new_image_url already exists. Skipping push..."
        continue
    else
        echo "Image $new_image_url does not exist. Pushing..."
    fi
    
    echo "Pushing image: $new_image_url"

    skopeo_cmd="skopeo copy"
    if [ -n "$source_creds" ]; then
        skopeo_cmd="$skopeo_cmd --src-creds=$source_creds"
    fi

    if [ -n "$destination_creds" ]; then
        skopeo_cmd="$skopeo_cmd --dest-creds=$destination_creds"
    fi

    skopeo_cmd="$skopeo_cmd docker://$image_url docker://$new_image_url"
    
    echo "Running command: $skopeo_cmd"

    # Copy image using skopeo
    if $skopeo_cmd; then
        echo "Successfully pushed image: $new_image_url"
    else
        echo "ERROR: Failed to push image: $new_image_url"
    fi
done