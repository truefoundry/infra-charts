import json
import os
import requests

def check_image_architectures(image_url):
    try:
        # Get the manifest list
        headers = {
            'Accept': 'application/vnd.docker.distribution.manifest.list.v2+json'
        }
        response = requests.get(f"https://registry-1.docker.io/v2/{image_url}/manifests/latest", headers=headers)
        response.raise_for_status()
        manifest_list = response.json()

        # Check for AMD64 and ARM64 architectures
        architectures = set(manifest['platform']['architecture'] for manifest in manifest_list['manifests'])
        return 'amd64' in architectures and 'arm64' in architectures
    except Exception as e:
        print(f"Error checking architectures for {image_url}: {str(e)}")
        return False

def main():
    all_pass = True
    for root, dirs, files in os.walk('charts'):
        for file in files:
            if file == 'artifacts-manifest.json':
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    manifest = json.load(f)
                
                for item in manifest:
                    if item['type'] == 'image':
                        image_url = item['details']['registryURL']
                        has_both_architectures = check_image_architectures(image_url)
                        if not has_both_architectures:
                            print(f"Image {image_url} does not have both AMD64 and ARM64 architectures")
                            all_pass = False

    if not all_pass:
        exit(1)

if __name__ == '__main__':
    main()
