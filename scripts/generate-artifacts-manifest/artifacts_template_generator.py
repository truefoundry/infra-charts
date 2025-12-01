from urllib.parse import urlparse
import yaml
import sys
import json
import subprocess
import os
import logging
import argparse

# Configure logging
temp_dir = "/tmp/helm_charts"
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Mode as environment variable
mode = os.getenv("MODE", "remote")
logging.info(f"Mode: {mode}")
if mode not in ["local", "remote"]:
    raise ValueError(f"Invalid MODE: {mode}. Must be 'local' or 'remote'.")

# Helper to run shell commands
def run_command(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        logging.error(f"Command failed: {command}\n{result.stderr}")
        sys.exit(1)
    return result.stdout

# Ensure list uniqueness
def make_image_list_unique(image_list):
    unique_images = []
    for image in image_list:
        if image not in unique_images:
            unique_images.append(image)
    return unique_images

# Normalize repo URL
def normalize_repo_url(repo_url):
    parsed = urlparse(repo_url)
    return repo_url if parsed.scheme else f"oci://{repo_url}"

# Extract Helm chart info from manifest
def extract_chart_info(manifest_file):
    chart_info_list = []
    with open(manifest_file) as f:
        manifest = yaml.safe_load_all(f)
        for doc in manifest:
            if isinstance(doc, dict) and 'spec' in doc:
                source = doc['spec'].get('source', {})
                if source:
                    chart_info_list.append({
                        "type": "helm",
                        "details": {
                            "chart": source.get('chart', ''),
                            "repoURL": normalize_repo_url(source.get('repoURL', '')),
                            "targetRevision": source.get('targetRevision', ''),
                            "values": source.get('helm', {}).get('values', '')
                        }
                    })
    return chart_info_list

# function to save final chart information to a file
def save_chart_info(chart_info_list, output_file):
    with open(output_file, 'w') as f:
        json.dump(chart_info_list, f, indent=4)
    logging.info(f"Chart information saved to {output_file}")

# Globals for skip logic
previously_processed_image_urls = set()
previous_platform_data = {}

# function to inspect image to get supported architectures and os
# returns a dictionary with image information e.g. {"architecture": "amd64", "os": "linux"}
# use cache to avoid repeated calls to docker manifest inspect
def get_image_details(image_name):
    """
   Retrieves the supported platforms of a Docker image and formats the output into a JSON object.
   Args:
       image_name (str): The name of the Docker image (e.g., 'quay.io/prometheus-operator/prometheus-operator:v0.70.0').
   Returns:
       dict: A JSON-formatted dictionary containing the image type, details, and supported platforms.
   """
    global previously_processed_image_urls, previous_platform_data
    
    if image_name in previously_processed_image_urls:
        logging.info(f"[skip] using cached platforms for {image_name}")
        return previous_platform_data.get(image_name, [])
    
    if image_name.startswith(('auto', 'cos-nvidia-installer', '602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/')):
        logging.info(f"Skipping image {image_name}")
        return []
    
    logging.info(f"Inspecting image manifest for {image_name}")
    try:
        result = run_command(f'docker manifest inspect {image_name}')
    except Exception as e:
        logging.error(f"Error inspecting image {image_name}: {e}")
        return []
    
    try:
        manifest = json.loads(result)
    except json.JSONDecodeError as e:
        logging.error(f"Failed to parse JSON from manifest inspect for {image_name}: {e}")
        return []
    
    platforms = []
    if 'manifests' in manifest:
        for manifest_entry in manifest['manifests']:
            platform = manifest_entry.get('platform', {})
            image_os = platform.get('os')
            architecture = platform.get('architecture')
            if image_os and architecture and image_os != 'unknown' and architecture != 'unknown':
                platforms.append({"os": image_os, "architecture": architecture})
    else:
        image_os = manifest.get('os')
        architecture = manifest.get('architecture')
        if image_os and architecture:
            platforms.append({"os": image_os, "architecture": architecture})
    
    return platforms

# function to extract images from Kubernetes manifests
def extract_images_from_k8s_manifests(yaml_content):
    resources_with_containers = ['Deployment','StatefulSet','DaemonSet','Job','CronJob','Pod','ReplicaSet']
    image_info_list = []
    
    try:
        manifests = yaml.safe_load_all(yaml_content)
        for doc in manifests:
            if not doc or 'kind' not in doc or 'spec' not in doc:
                continue
            kind = doc['kind']; spec = doc['spec']
            if kind in ['Alertmanager','Prometheus']:
                image = spec.get('image','')
                
                # Check if image is already known before calling get_image_details
                if image in previous_platform_data:
                    platforms = previous_platform_data[image]
                    image_info_list.append({"type":"image","details":{"registryURL":image,"platforms":platforms}})
                else:
                    image_info_list.append({"type":"image","details":{"registryURL":image,"platforms":[]}})
            elif kind in resources_with_containers:
                target = spec['jobTemplate']['spec']['template']['spec'] if kind=='CronJob' and 'jobTemplate' in spec else spec.get('template',{}).get('spec',spec)
                containers = target.get('containers',[]) or []
                inits = target.get('initContainers',[]) or []
                for container in containers + inits:
                    container_image = container.get('image','')
                    
                    # Check if container image is already known before calling get_image_details
                    if container_image in previous_platform_data:
                        platforms = previous_platform_data[container_image]
                        image_info_list.append({"type":"image","details":{"registryURL":container_image,"platforms":platforms}})
                    else:
                        image_info_list.append({"type":"image","details":{"registryURL":container_image,"platforms":[]}})
    except yaml.YAMLError as yaml_error:
        logging.error(f"YAML parsing error: {yaml_error}")
    return image_info_list

# Generate manifests for remote repo
def generate_manifests(chart_name, repo_url, version, values_file):
    parsed_url = urlparse(repo_url)
    chart_dir_path = os.path.join(temp_dir, chart_name)
    
    if parsed_url.scheme == 'oci':
        logging.info(f"OCI registry for {chart_name}")
        run_command(f"helm pull {repo_url}/{chart_name} --version {version} --untar --untardir {temp_dir}")
    else:
        run_command(f"helm repo add --force-update {chart_name} {repo_url}")
        run_command("helm repo update")
        run_command(f"helm pull {chart_name}/{chart_name} --version {version} --untar --untardir {temp_dir}")
    
    # Update dependencies to ensure we process all dependent charts and their images
    logging.info(f"Updating dependencies for {chart_name}")
    run_command(f"helm dependency update {chart_dir_path}")
    
    manifest_file_path = os.path.join(temp_dir,'generated-manifest.yaml')
    run_command(f"helm template my-release -f {values_file} {os.path.join(temp_dir,chart_name)} > {manifest_file_path}")
    return manifest_file_path

# Generate manifests for local chart
def generate_manifests_local(chart_name, values_file):
    chart_dir_path = f"charts/{chart_name}"
    
    # Update dependencies to ensure we process all dependent charts and their images
    logging.info(f"Updating dependencies for {chart_name}")
    run_command(f"helm dependency update {chart_dir_path}")
    
    manifest_file_path = os.path.join(temp_dir,'generated-manifest.yaml')
    run_command(f"helm template {chart_name} -f {values_file} {chart_dir_path} > {manifest_file_path}")
    return manifest_file_path

# Process charts and gather images
def process_and_generate_chart_manifests(chart_info_list):
    all_processed_images = []
    
    known_image_registry_urls = set(previous_platform_data.keys())
    
    logging.info(f"Total known images: {len(known_image_registry_urls)} (including {len(previously_processed_image_urls)} with platforms)")
    
    for chart_info in chart_info_list:
        chart_details = chart_info['details']
        chart_name = chart_details['chart']
        chart_version = chart_details['targetRevision']
        chart_values = chart_details.get('values','')

        logging.info(f"Processing chart {chart_name}@{chart_version}")

        if chart_name == 'aws-load-balancer-controller':
            chart_values = chart_values.replace('clusterName: ""','clusterName: "my-cluster"')

        values_file_path = f"{temp_dir}/charts/{chart_name}-values.yaml"
        os.makedirs(os.path.dirname(values_file_path), exist_ok=True)
        with open(values_file_path,'w') as f:
            f.write(chart_values)
        template_command = f"helm template {chart_name}/{chart_name}" if urlparse(chart_details['repoURL']).scheme!='oci' else f"helm template {chart_details['repoURL']}/{chart_name}"

        run_command(f"helm repo add --force-update {chart_name} {chart_details['repoURL']}" if urlparse(chart_details['repoURL']).scheme!='oci' else '')
        run_command(f"{template_command} --version {chart_version} -f {values_file_path} > {temp_dir}/charts/{chart_name}.yaml")

        # Get raw images from the manifest
        chart_raw_images = make_image_list_unique(extract_images_from_k8s_manifests(open(f"{temp_dir}/charts/{chart_name}.yaml").read()))
        
        # Process each image, setting platform info from previous_platform_data if already known
        chart_processed_images = []
        for image_entry in chart_raw_images:
            image_registry_url = image_entry['details']['registryURL']
            
            if image_registry_url.startswith(('auto', 'cos-nvidia-installer')):
                chart_processed_images.append(image_entry)
                continue
                
            # If the image is already seen before, use that platform info even if empty
            if image_registry_url in known_image_registry_urls:
                # Reuse the existing platform info, even if empty
                image_entry['details']['platforms'] = previous_platform_data[image_registry_url]
                chart_processed_images.append(image_entry)
            else:
                # This is truly a new image, add it to be processed
                chart_processed_images.append(image_entry)
        
        # Log a summary
        image_urls = [img['details']['registryURL'] for img in chart_processed_images]
        previously_known_count = len([url for url in image_urls if url in known_image_registry_urls])
        new_image_count = len(image_urls) - previously_known_count
        
        logging.info(f"Chart {chart_name}@{chart_version} images: {len(image_urls)}")
        logging.info(f" -> {previously_known_count} already-known images")
        logging.info(f" -> {new_image_count} new images to inspect")
        
        # Store the list of image URLs in the chart details
        chart_info['details']['images'] = image_urls
        
        # Add all processed images to the result list
        all_processed_images.extend(chart_processed_images)
        
    return all_processed_images

# Cleanup and tmp dir

def clean_up(directory): run_command(f"rm -rf {directory}")

def create_tmp_dir(): os.makedirs(temp_dir,exist_ok=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('chart_name')
    parser.add_argument('chart_repo_url')
    parser.add_argument('chart_version')
    parser.add_argument('values_file_path')
    parser.add_argument('output_file_path')
    parser.add_argument('extra_file_path', nargs='?', default=None)
    args = parser.parse_args()

    create_tmp_dir()

    # Load existing image entries for skip logic and cache details
    existing_images = []
    
    # First load from output_file to prioritize its platform info
    if args.output_file_path and os.path.exists(args.output_file_path):
        logging.info(f"Loading images from output file: {args.output_file_path}")
        try:
            output_file_data = json.load(open(args.output_file_path))
            before_count = len(existing_images)
            for image_item in output_file_data:
                if image_item.get('type') == 'image':
                    registry_url = image_item['details']['registryURL']
                    platform_info = image_item['details'].get('platforms', [])
                    
                    # Add to existing_images
                    existing_images.append(image_item)
                    
                    # Cache platform info (even if empty)
                    previous_platform_data[registry_url] = platform_info
            
            logging.info(f"Loaded {len(existing_images)-before_count} images from output file")
        except Exception as e:
            logging.warning(f"Could not load images from output file: {e}")
    
    # Then load from extra_file, but don't overwrite platform info that came from output_file
    if args.extra_file_path and os.path.exists(args.extra_file_path):
        logging.info(f"Loading images from extra file: {args.extra_file_path}")
        try:
            extra_file_data = json.load(open(args.extra_file_path))
            before_count = len(existing_images)
            for image_item in extra_file_data:
                if image_item.get('type') == 'image':
                    registry_url = image_item['details']['registryURL']
                    extra_platform_info = image_item['details'].get('platforms', [])
                    
                    # Check if we already have this image from output_file
                    existing_image = None
                    for idx, img in enumerate(existing_images):
                        if img['details']['registryURL'] == registry_url:
                            existing_image = img
                            break
                    
                    if existing_image is None:
                        # Image not found in existing_images, add it
                        image_item['details']['platforms'] = extra_platform_info  # Ensure platforms array exists
                        existing_images.append(image_item)
                        
                        # Only add to previous_platform_data if not already there from output_file
                        if registry_url not in previous_platform_data:
                            previous_platform_data[registry_url] = extra_platform_info
            
            logging.info(f"Loaded {len(existing_images)-before_count} additional images from extra file")
        except Exception as e:
            logging.warning(f"Could not load images from extra file: {e}")
    
    # Build previously_processed_image_urls set
    previously_processed_image_urls = {
        registry_url for registry_url, platform_info in previous_platform_data.items()
        if platform_info
    }
    
    logging.info(f"Total previously_processed_image_urls: {len(previously_processed_image_urls)}; sample: {list(previously_processed_image_urls)[:10]}{'...' if len(previously_processed_image_urls)>10 else ''}")

    # Manifest generation
    if mode == 'local':
        manifest_file_path = generate_manifests_local(args.chart_name, args.values_file_path)
    else:
        manifest_file_path = generate_manifests(args.chart_name, args.chart_repo_url, args.chart_version, args.values_file_path)

    chart_list = extract_chart_info(manifest_file_path)
    new_chart_images = process_and_generate_chart_manifests(chart_list) if chart_list else make_image_list_unique(extract_images_from_k8s_manifests(open(manifest_file_path).read()))

    # Inject images with empty platforms from output_file into new_images
    images_to_inject = []
    logging.info("Checking for images with empty platforms to inject")
    
    # First build a map of all images in output_file with their platform info
    output_file_image_map = {}
    if args.output_file_path and os.path.exists(args.output_file_path):
        try:
            data = json.load(open(args.output_file_path))
            for itm in data:
                if itm.get('type') == 'image':
                    reg_url = itm['details']['registryURL']
                    platforms = itm['details'].get('platforms', [])
                    output_file_image_map[reg_url] = platforms
        except Exception as e:
            logging.warning(f"Could not load images from output file for mapping: {e}")
    
    # Build a map of images from extra file - we'll use this to avoid redundant inspections
    extra_file_image_urls = set()
    if args.extra_file_path and os.path.exists(args.extra_file_path):
        try:
            data = json.load(open(args.extra_file_path))
            for itm in data:
                if itm.get('type') == 'image':
                    reg_url = itm['details']['registryURL']
                    extra_file_image_urls.add(reg_url)
        except Exception as e:
            logging.warning(f"Could not load images from extra file for mapping: {e}")
    
    # Find images that need inspection - only inject images that:
    # 1. Have empty platforms in output file
    # 2. Are NOT present in extra file (to avoid re-inspecting them)
    for src in [args.extra_file_path]:  # Only consider extra_file for injection
        if src and os.path.exists(src):
            try:
                data = json.load(open(src))
                for itm in data:
                    if itm.get('type') == 'image':
                        reg_url = itm['details']['registryURL']
                        
                        # Skip auto or cos-nvidia-installer images
                        if reg_url.startswith(('auto', 'cos-nvidia-installer')):
                            logging.info(f"Skipping special image: {reg_url}")
                            continue
                        
                        # Skip if image is both in output file and extra file
                        # Only inject if it's new (not in output file)
                        if reg_url in output_file_image_map:
                            # Image is in both files - don't reinspect even if platforms are empty
                            # logging.info(f"Skipping image already in both files: {reg_url}")
                            continue
                            
                        # Check if the image has platforms in output file
                        output_platforms = output_file_image_map.get(reg_url, [])
                        
                        # If image is not in output file, inject it
                        already_in_new = False
                        for img in new_chart_images:
                            if img['details']['registryURL'] == reg_url:
                                already_in_new = True
                                break
                        
                        if not already_in_new:
                            logging.info(f"Adding image with empty platforms to be inspected: {reg_url}")
                            images_to_inject.append({
                                "type": "image",
                                "details": {
                                    "registryURL": reg_url,
                                    "platforms": []
                                }
                            })
            except Exception as e:
                logging.warning(f"Could not load images from {src} for injection: {e}")
    
    # Add injected images to new_images list
    if images_to_inject:
        logging.info(f"Injecting {len(images_to_inject)} images with empty platforms into new_images")
        new_chart_images.extend(images_to_inject)
    else:
        logging.info("No images to inject")

    # Post-process new images - ensure known images aren't re-inspected

    # Skip inspection for ALL known images, even with empty platforms
    # First, explicitly update platform info for any image from the output file or extra file
    # Do this BEFORE the main post-processing loop
    for image_entry in new_chart_images:
        image_registry_url = image_entry['details']['registryURL']
        if image_registry_url in previous_platform_data:
            # Explicitly set to the known platform info, even if empty
            image_entry['details']['platforms'] = previous_platform_data[image_registry_url]
    
    # Now continue with regular post-processing
    logging.info(f"Post-processing {len(new_chart_images)} new images")
    
    # Track which images are actually inspected in this run
    newly_inspected_count = 0
    
    for image_entry in new_chart_images:
        image_registry_url = image_entry['details']['registryURL']
        
        # Skip if already has platforms (from output file or otherwise)
        if image_entry['details'].get('platforms') or image_registry_url in previous_platform_data:
            continue
        
        # Only inspect truly new images
        logging.info(f"[post‐extra] inspecting {image_registry_url}")
        image_entry['details']['platforms'] = get_image_details(image_registry_url)
        newly_inspected_count += 1
    
    if newly_inspected_count > 0:
        logging.info(f"Inspected {newly_inspected_count} new images in this run")
    else:
        logging.info("No new images needed inspection")

    # Strip values
    for chart_info in chart_list:
        chart_info['details'].pop('values', None)

    # Create a set of all current images (from charts and extra.json)
    # These are the only images that should be in the final output
    current_extra_image_urls = set()
    if args.extra_file_path and os.path.exists(args.extra_file_path):
        try:
            data = json.load(open(args.extra_file_path))
            for item in data:
                if item.get('type') == 'image':
                    registry_url = item['details']['registryURL']
                    current_extra_image_urls.add(registry_url)
        except Exception as e:
            logging.warning(f"Could not load current extra images: {e}")
    
    # Get all images from current charts
    current_chart_image_urls = set()
    for chart in chart_list:
        chart_images = chart['details'].get('images', [])
        current_chart_image_urls.update(chart_images)
    
    # All current valid images are either from charts or extra.json
    all_current_valid_image_urls = current_chart_image_urls.union(current_extra_image_urls)
    
    # Log image counts
    logging.info(f"Current chart images: {len(current_chart_image_urls)}")
    logging.info(f"Current extra images: {len(current_extra_image_urls)}")
    logging.info(f"Total current images: {len(all_current_valid_image_urls)}")

    # Deduplicate image entries by registryURL and only keep current images
    logging.info(f"Starting deduplication process with {len(existing_images)} existing and {len(new_chart_images)} new images")
    deduplicated_image_map = {}
    
    # First process new images (so chart info takes precedence)
    for image_entry in new_chart_images:
        registry_url = image_entry['details']['registryURL']
        # Only include images that are in the current set
        if registry_url in all_current_valid_image_urls:
            deduplicated_image_map[registry_url] = image_entry
    
    # Then add existing images if they're not already in the map and are in the current set
    for image_entry in existing_images:
        registry_url = image_entry['details']['registryURL']
        if registry_url in all_current_valid_image_urls and registry_url not in deduplicated_image_map:
            deduplicated_image_map[registry_url] = image_entry
    
    # Create final list of images
    deduplicated_images = list(deduplicated_image_map.values())
    logging.info(f"Final image count after deduplication: {len(deduplicated_images)}")
    
    # Check if any images were removed
    removed_image_count = len(all_current_valid_image_urls) - len(deduplicated_images)
    if removed_image_count > 0:
        logging.info(f"Removed {removed_image_count} images that are no longer in current charts or extra.json")

    # Assemble final output
    final_output = chart_list + deduplicated_images
    save_chart_info(final_output, args.output_file_path)
    clean_up(temp_dir)
