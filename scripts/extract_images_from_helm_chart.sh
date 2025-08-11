#!/bin/bash
# Get command line arguments
repo=$1
chart_name=$2
version=$3
values_file=$4

if [ -z "$repo" ] || [ -z "$chart_name" ] || [ -z "$version" ]; then
    echo "Usage: $0 <repo_url|repo_name> <chart_name> <version> [values_file]"
    echo "Example: $0 oci://tfy.jfrog.io/tfy-helm truefoundry 1.0.0 values.yaml"
    echo "Example: $0 infra-charts tfy-agent 1.0.0 values.yaml"
    exit 1
fi

echo "Pulling chart $repo/$chart_name --version $version"
helm pull "$repo/$chart_name" --version "$version"

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