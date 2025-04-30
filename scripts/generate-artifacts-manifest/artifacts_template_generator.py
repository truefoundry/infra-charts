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
    unique = []
    for img in image_list:
        if img not in unique:
            unique.append(img)
    return unique

# Normalize repo URL
def normalize_repo_url(repo_url):
    parsed = urlparse(repo_url)
    return repo_url if parsed.scheme else f"oci://{repo_url}"

# Extract Helm chart info from manifest
def extract_chart_info(manifest_file):
    info = []
    with open(manifest_file) as f:
        docs = yaml.safe_load_all(f)
        for d in docs:
            if isinstance(d, dict) and 'spec' in d:
                src = d['spec'].get('source', {})
                if src:
                    info.append({
                        "type": "helm",
                        "details": {
                            "chart": src.get('chart', ''),
                            "repoURL": normalize_repo_url(src.get('repoURL', '')),
                            "targetRevision": src.get('targetRevision', ''),
                            "values": src.get('helm', {}).get('values', '')
                        }
                    })
    return info

# Save final JSON
def save_chart_info(data, output_file):
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=4)
    logging.info(f"Chart information saved to {output_file}")

# Globals for skip logic
skip_images = set()
skip_image_details = {}

# Inspect image manifest or use cached
def get_image_details(image_name):
    global skip_images, skip_image_details
    if image_name in skip_images:
        logging.info(f"[skip] using cached platforms for {image_name}")
        return skip_image_details.get(image_name, [])
    if image_name.startswith(('auto', 'cos-nvidia-installer')):
        logging.info(f"Skipping auth image {image_name}")
        return []
    logging.info(f"Inspecting image manifest for {image_name}")
    try:
        res = run_command(f'docker manifest inspect {image_name}')
    except Exception as e:
        logging.error(f"Error inspecting image {image_name}: {e}")
        return []
    manifest = json.loads(res)
    platforms = []
    if 'manifests' in manifest:
        for entry in manifest['manifests']:
            p = entry.get('platform', {})
            osn = p.get('os'); arch = p.get('architecture')
            if osn and arch and osn != 'unknown' and arch != 'unknown':
                platforms.append({"os": osn, "architecture": arch})
    else:
        osn = manifest.get('os'); arch = manifest.get('architecture')
        if osn and arch:
            platforms.append({"os": osn, "architecture": arch})
    return platforms

# Parse K8s YAML and extract images
def extract_images_from_k8s_manifests(yaml_content):
    kinds = ['Deployment','StatefulSet','DaemonSet','Job','CronJob','Pod','ReplicaSet']
    images = []
    try:
        docs = yaml.safe_load_all(yaml_content)
        for doc in docs:
            if not doc or 'kind' not in doc or 'spec' not in doc:
                continue
            kind = doc['kind']; spec = doc['spec']
            if kind in ['Alertmanager','Prometheus']:
                img = spec.get('image','')
                images.append({"type":"image","details":{"registryURL":img,"platforms":get_image_details(img)}})
            elif kind in kinds:
                target = spec['jobTemplate']['spec']['template']['spec'] if kind=='CronJob' and 'jobTemplate' in spec else spec.get('template',{}).get('spec',spec)
                containers = target.get('containers',[]) or []
                inits = target.get('initContainers',[]) or []
                for c in containers + inits:
                    img = c.get('image','')
                    images.append({"type":"image","details":{"registryURL":img,"platforms":get_image_details(img)}})
    except yaml.YAMLError as e:
        logging.error(f"YAML parsing error: {e}")
    return images

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
def process_and_generate_chart_manifests(charts):
    all_images = []
    for ci in charts:
        d = ci['details']; name = d['chart']; rev = d['targetRevision']
        logging.info(f"Processing chart {name}@{rev}. skip_images size={len(skip_images)}")
        vals = d.get('values','')
        if name == 'aws-load-balancer-controller':
            vals = vals.replace('clusterName: ""','clusterName: "my-cluster"')
        vfile = f"{temp_dir}/charts/{name}-values.yaml"
        os.makedirs(os.path.dirname(vfile), exist_ok=True)
        with open(vfile,'w') as f: f.write(vals)
        tmpl = f"helm template {name}/{name}" if urlparse(d['repoURL']).scheme!='oci' else f"helm template {d['repoURL']}/{name}"
        run_command(f"helm repo add --force-update {name} {d['repoURL']}" if urlparse(d['repoURL']).scheme!='oci' else '')
        run_command(f"{tmpl} --version {rev} -f {vfile} > {temp_dir}/charts/{name}.yaml")
        images = make_image_list_unique(extract_images_from_k8s_manifests(open(f"{temp_dir}/charts/{name}.yaml").read()))
        urls = [i['details']['registryURL'] for i in images]
        known = [u for u in urls if u in skip_images]
        new = [u for u in urls if u not in skip_images]
        logging.info(f"Chart {name}@{rev} images: {urls}")
        logging.info(f" -> {len(known)} already-known: {known}")
        logging.info(f" -> {len(new)} new to inspect: {new}")
        ci['details']['images'] = urls
        for img in images:
            reg = img['details']['registryURL']
            if reg in skip_images:
                img['details']['platforms'] = skip_image_details.get(reg, [])
        all_images.extend(images)
    return all_images

# Cleanup and tmp dir

def clean_up(d): run_command(f"rm -rf {d}")

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
    for ci in charts:
        ci['details'].pop('values', None)

    # Deduplicate image entries by registryURL
    image_map = {}
    for img in existing_images:
        image_map[img['details']['registryURL']] = img
    for img in new_images:
        reg = img['details']['registryURL']
        if reg in image_map:
            exist_pf = image_map[reg]['details'].get('platforms', [])
            new_pf = img['details'].get('platforms', [])
            if not exist_pf and new_pf:
                image_map[reg]['details']['platforms'] = new_pf
        else:
            image_map[reg] = img
    dedup_images = list(image_map.values())

    # Assemble final output
    final_output = charts + dedup_images
    save_chart_info(final_output, args.output_file)
    clean_up(temp_dir)
