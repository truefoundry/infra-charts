from urllib.parse import urlparse
import yaml, sys, json, subprocess, os, logging, argparse

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
                            "target_revision": source.get('targetRevision', ''),
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
skip_images = set()
skip_image_details = {}

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
    global skip_images, skip_image_details
    if image_name in skip_images:
        logging.info(f"[skip] using cached platforms for {image_name}")
        return skip_image_details.get(image_name, [])
    if image_name.startswith(('auto', 'cos-nvidia-installer')):
        logging.info(f"Skipping auth image {image_name}")
        return []
    logging.info(f"Inspecting image manifest for {image_name}")
    try:
        result = run_command(f'docker manifest inspect {image_name}')
    except Exception as e:
        logging.error(f"Error inspecting image {image_name}: {e}")
        return []
    manifest = json.loads(result)
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
                image_info_list.append({"type":"image","details":{"registryURL":image,"platforms":get_image_details(image)}})
            elif kind in resources_with_containers:
                target = spec['jobTemplate']['spec']['template']['spec'] if kind=='CronJob' and 'jobTemplate' in spec else spec.get('template',{}).get('spec',spec)
                containers = target.get('containers',[]) or []
                inits = target.get('initContainers',[]) or []
                for c in containers + inits:
                    image = c.get('image','')
                    image_info_list.append({"type":"image","details":{"registryURL":image,"platforms":get_image_details(image)}})
    except yaml.YAMLError as yaml_error:
        logging.error(f"YAML parsing error: {yaml_error}")
    return image_info_list

# Generate manifests for remote repo
def generate_manifests(chart_name, repo_url, version, values_file):
    parsed = urlparse(repo_url)
    if parsed.scheme == 'oci':
        logging.info(f"OCI registry for {chart_name}")
        run_command(f"helm pull {repo_url}/{chart_name} --version {version} --untar --untardir {temp_dir}")
    else:
        run_command(f"helm repo add --force-update {chart_name} {repo_url}")
        run_command("helm repo update")
        run_command(f"helm pull {chart_name}/{chart_name} --version {version} --untar --untardir {temp_dir}")
    out = os.path.join(temp_dir,'generated-manifest.yaml')
    run_command(f"helm template my-release -f {values_file} {os.path.join(temp_dir,chart_name)} > {out}")
    return out

# Generate manifests for local chart
def generate_manifests_local(chart_name, values_file):
    out = os.path.join(temp_dir,'generated-manifest.yaml')
    run_command(f"helm template {chart_name} -f {values_file} charts/{chart_name} > {out}")
    return out

# Process charts and gather images
def process_and_generate_chart_manifests(chart_info_list):
    all_images = []
    for chart_info in chart_info_list:
        details = chart_info['details']
        chart = details['chart']
        target_revision = details['target_revision']
        values = details.get('values','')

        logging.info(f"Processing chart {chart}@{target_revision}. skip_images size={len(skip_images)}")

        if chart == 'aws-load-balancer-controller':
            values = values.replace('clusterName: ""','clusterName: "my-cluster"')

        values_file = f"{temp_dir}/charts/{chart}-values.yaml"
        os.makedirs(os.path.dirname(values_file), exist_ok=True)
        with open(values_file,'w') as f:
            f.write(values)
        tmpl = f"helm template {chart}/{chart}" if urlparse(details['repoURL']).scheme!='oci' else f"helm template {details['repoURL']}/{chart}"

        run_command(f"helm repo add --force-update {chart} {details['repoURL']}" if urlparse(details['repoURL']).scheme!='oci' else '')
        run_command(f"{tmpl} --version {target_revision} -f {values_file} > {temp_dir}/charts/{chart}.yaml")

        images = make_image_list_unique(extract_images_from_k8s_manifests(open(f"{temp_dir}/charts/{chart}.yaml").read()))
        urls = [i['details']['registryURL'] for i in images]
        known = [u for u in urls if u in skip_images]
        new = [u for u in urls if u not in skip_images]
        logging.info(f"Chart {chart}@{target_revision} images: {urls}")
        logging.info(f" -> {len(known)} already-known: {known}")
        logging.info(f" -> {len(new)} new to inspect: {new}")
        chart_info['details']['images'] = urls
        for image in images:
            reg = image['details']['registryURL']
            if reg in skip_images:
                image['details']['platforms'] = skip_image_details.get(reg, [])
        all_images.extend(images)
    return all_images

# Cleanup and tmp dir

def clean_up(directory): run_command(f"rm -rf {directory}")

def create_tmp_dir(): os.makedirs(temp_dir,exist_ok=True)

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('chart_name'); p.add_argument('chart_repo_url')
    p.add_argument('chart_version'); p.add_argument('values_file')
    p.add_argument('output_file'); p.add_argument('extra_file', nargs='?', default=None)
    args = p.parse_args()

    create_tmp_dir()

    # Load existing image entries for skip logic and cache details
    existing_images = []
    for src in [args.output_file, args.extra_file]:
        if src and os.path.exists(src):
            try:
                data = json.load(open(src))
                before = len(existing_images)
                for itm in data:
                    if itm.get('type') == 'image':
                        existing_images.append(itm)
                        skip_image_details[itm['details']['registryURL']] = itm['details'].get('platforms', [])
                logging.info(f"Loaded {len(existing_images)-before} images from {src}")
            except Exception as e:
                logging.warning(f"Could not load images from {src}: {e}")
    skip_images = set(skip_image_details.keys())
    logging.info(f"Total skip_images: {len(skip_images)}; sample: {list(skip_images)[:10]}{'...' if len(skip_images)>10 else ''}")

    # Manifest generation
    if mode == 'local':
        manifest = generate_manifests_local(args.chart_name, args.values_file)
    else:
        manifest = generate_manifests(args.chart_name, args.chart_repo_url, args.chart_version, args.values_file)

    charts = extract_chart_info(manifest)
    new_images = process_and_generate_chart_manifests(charts) if charts else make_image_list_unique(extract_images_from_k8s_manifests(open(manifest).read()))

    # Strip values
    for chart_info in charts:
        chart_info['details'].pop('values', None)

    # Deduplicate image entries by registryURL
    image_map = {}
    for image in existing_images:
        image_map[image['details']['registryURL']] = image
    for image in new_images:
        reg = image['details']['registryURL']
        if reg in image_map:
            exist_pf = image_map[reg]['details'].get('platforms', [])
            new_pf = image['details'].get('platforms', [])
            if not exist_pf and new_pf:
                image_map[reg]['details']['platforms'] = new_pf
        else:
            image_map[reg] = image
    dedup_images = list(image_map.values())

    # Assemble final output
    final_output = charts + dedup_images
    save_chart_info(final_output, args.output_file)
    clean_up(temp_dir)
