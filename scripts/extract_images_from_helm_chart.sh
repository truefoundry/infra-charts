#!/bin/bash

# Function to show usage
show_usage() {
    echo "Usage: $0 --repo <repo_url|repo_name> --chart <chart_name> --version <version> [--values <values_file>]"
    echo ""
    echo "Arguments:"
    echo "  --repo, -r     Repository URL or name (required)"
    echo "  --chart, -c    Chart name (required)"
    echo "  --version, -v  Chart version (required)"
    echo "  --values, -f   Values file path (optional)"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --repo oci://tfy.jfrog.io/tfy-helm --chart truefoundry --version 1.0.0 --values values.yaml"
    echo "  $0 -r infra-charts -c tfy-agent -v 1.0.0 -f values.yaml"
    echo "  $0 --repo infra-charts --chart tfy-agent --version 1.0.0"
}

# Parse command line arguments
repo=""
chart_name=""
version=""
values_file=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --repo|-r)
            repo="$2"
            shift 2
            ;;
        --chart|-c)
            chart_name="$2"
            shift 2
            ;;
        --version|-v)
            version="$2"
            shift 2
            ;;
        --values|-f)
            values_file="$2"
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
if [ -z "$repo" ] || [ -z "$chart_name" ] || [ -z "$version" ]; then
    echo "ERROR: Missing required arguments"
    show_usage
    exit 1
fi

echo "Pulling chart $repo/$chart_name --version $version"
if helm pull "$repo/$chart_name" --version "$version"; then
    echo "Chart pulled successfully"
else
    echo "ERROR: Failed to pull chart"
    exit 1
fi

echo "extracting images..."

if [ -n "$values_file" ] && [ -f "$values_file" ]; then
    echo "Using provided values file: $values_file"
    helm template "$chart_name" -f "$values_file" "$chart_name-$version.tgz" --version "$version" > tmp_rendered_k8s_manifest.yaml
else
    echo "No values file provided, using default values"
    helm template "$chart_name" "$chart_name-$version.tgz" --version "$version" > tmp_rendered_k8s_manifest.yaml
fi

images=$(cat tmp_rendered_k8s_manifest.yaml | grep -E '^\s*[-]?\s*image:\s*[^ ]' | awk -F': ' '{print $2}' | sort -u)

blacklist_images=('python:3.11.9-bullseye')
echo "filtering images..."

filtered_images=()
for image in $images; do
    # Check if image is in blacklist_images
    if [[ ! " ${blacklist_images[@]} " =~ " $image " ]]; then
        filtered_images+=("$image")
    fi
done
# Remove quotes from filtered images
filtered_images=("${filtered_images[@]//\"/}")

# Write filtered images to $chart_name-images-$version file
printf "%s\n" "${filtered_images[@]}" > $chart_name-images-$version
echo "dumped images to $chart_name-images-$version."
echo "cleaning up..."

rm -f $chart_name-$version.tgz
rm -f tmp_rendered_k8s_manifest.yaml