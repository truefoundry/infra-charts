from urllib.parse import urlparse
import yaml
import sys
import json
import subprocess
import os
import logging
import argparse


def normalize_repo_url(repo_url):
    parsed_url = urlparse(repo_url)
    if not parsed_url.scheme:
        return f"oci://{repo_url}"
    return repo_url


# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

temp_dir = "/tmp/helm_charts"

# Mode as environment variable
mode = os.getenv("MODE", "remote")  # Default to "remote" if MODE is not set

logging.info(f"Mode: {mode}")

# Validate the mode
if mode not in ["local", "remote"]:
    raise ValueError(f"Invalid MODE: {mode}. Must be 'local' or 'remote'.")


# function to run shell commands
def run_command(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        logging.error(f"Command failed: {command}\n{result.stderr}")
        sys.exit(1)
    return result.stdout


# function to make image list unique
def make_image_list_unique(image_list):
    unique_images = []
    for image in image_list:
        if image not in unique_images:
            unique_images.append(image)
    return unique_images


# function to extract chart information from the manifest file
def extract_chart_info(manifest_file):
    chart_info_list = []

    with open(manifest_file, 'r') as f:
        manifest = yaml.safe_load_all(f)

        for doc in manifest:
            if isinstance(doc, dict) and 'spec' in doc:
                source = doc['spec'].get('source', {})
                if source:
                    chart_info = {
                        "type": "helm",
                        "details": {
                            "chart": source.get('chart', ''),
                            "repoURL": normalize_repo_url(source.get('repoURL', '')),
                            "targetRevision": source.get('targetRevision', ''),
                            "values": source.get('helm', {}).get('values', '')
                        }
                    }
                    chart_info_list.append(chart_info)

    return chart_info_list


# function to save chart information to a file
def save_chart_info(chart_info_list, output_file):
    with open(output_file, 'w') as f:
        json.dump(chart_info_list, f, indent=4)
    logging.info(f"Chart information saved to {output_file}")


# function to process chart information
def process_and_generate_chart_manifests(chart_info_list):
    chart_detail_list = []
    for chart_info in chart_info_list:
        details = chart_info["details"]
        chart = details["chart"]
        repoURL = details["repoURL"]
        targetRevision = details["targetRevision"]
        values = details["values"]

        if chart == "aws-load-balancer-controller":
            values = values.replace("clusterName: \"\"", "clusterName: \"my-cluster\"")

        values_file = f"{temp_dir}/charts/{chart}-values.yaml"
        os.makedirs(os.path.dirname(values_file), exist_ok=True)
        with open(values_file, "w") as f:
            f.write(values)
        if urlparse(repoURL).scheme == "oci":
            logging.info(f"OCI registry detected for {chart}. Skipping helm repo add and update.")
            run_command(f"helm template {repoURL}/{chart} --version {targetRevision} -f {values_file} > {temp_dir}/charts/{chart}.yaml")
        else:
            run_command(f"helm repo add --force-update {chart} {repoURL}")
            logging.info(f"Generating manifests for {chart}/{chart}...")
            run_command(f"helm template {chart}/{chart} --version {targetRevision} -f {values_file} > {temp_dir}/charts/{chart}.yaml")

        images = make_image_list_unique(save_image_info(f"{temp_dir}/charts/{chart}.yaml"))
        logging.info(f"Images for {chart}: {images}")
        chart_info["details"]["images"] = [image["details"]["registryURL"] for image in images]
        chart_detail_list.append(images)

    flattened_list = [item for sublist in chart_detail_list for item in sublist]
    return flattened_list


# function to save image information to a file
def save_image_info(manifest_file):
    with open(manifest_file, "r") as f:
        yaml_content = f.read()
        images = extract_images_from_k8s_manifests(yaml_content)
        return images


# function to inspect image to get supported architectures and os
# returns a dictionary with image information e.g. {"architecture": "amd64", "os": "linux"}
def get_image_details(image_name):
    """
    Retrieves the supported platforms of a Docker image and formats the output into a JSON object.

    Args:
        image_name (str): The name of the Docker image (e.g., 'quay.io/prometheus-operator/prometheus-operator:v0.70.0').

    Returns:
        dict: A JSON-formatted dictionary containing the image type, details, and supported platforms.
    """

    # Run 'docker manifest inspect' command
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
            os = platform.get('os')
            architecture = platform.get('architecture')
            # if os or architecture is unknown, skip
            if os and architecture and os != 'unknown' and architecture != 'unknown':
                platforms.append({"os": os, "architecture": architecture})
    else:
        os = manifest.get('os')
        architecture = manifest.get('architecture')
        if os and architecture:
            platforms.append({"os": os, "architecture": architecture})

    return platforms


# function to generate manifests for the chart
def generate_manifests(chart_name, chart_repo_url, chart_version, values_file):
    parsed_url = urlparse(chart_repo_url)
    print("Chart Repo URL: ", chart_repo_url, "Parsed URL: ", parsed_url)
    if parsed_url.scheme == "oci":
        logging.info(f"OCI registry detected for {chart_name}. Skipping helm repo add and update.")
        run_command(f"helm pull {chart_repo_url}/{chart_name} --version {chart_version} --untar --untardir {temp_dir}")
    else:
        run_command(f"helm repo add --force-update {chart_name} {chart_repo_url}")
        run_command("helm repo update")
        run_command(f"helm search repo {chart_name}/{chart_name}")
        logging.info(f"Downloading the chart {chart_name} version {chart_version} from the repository {chart_repo_url}")
        run_command(f"helm pull {chart_name}/{chart_name} --version {chart_version} --untar --untardir {temp_dir}")

    chart_dir = os.path.join(temp_dir, chart_name)
    manifest_file = os.path.join(temp_dir, 'generated-manifest.yaml')
    logging.info(f"Generating the manifests for the chart {chart_name} using the values file {values_file}")
    run_command(f"helm template my-release -f {values_file} {chart_dir} > {manifest_file}")

    return manifest_file


# function to generate manifest from local chart
def generate_manifests_local(chart_name, values_file):
    chart_dir = os.path.join("charts", chart_name)
    manifest_file = os.path.join(temp_dir, 'generated-manifest.yaml')
    logging.info(f"Generating the manifests for the chart {chart_name} using the values file {values_file}")
    run_command(f"helm template {chart_name} -f {values_file} {chart_dir} > {manifest_file}")

    return manifest_file


# function to extract images from Kubernetes manifests
def extract_images_from_k8s_manifests(yaml_content):
    resources_with_containers = ['Deployment', 'StatefulSet', 'DaemonSet', 'Job', 'CronJob', 'Pod', 'ReplicaSet']
    try:
        manifests = yaml.safe_load_all(yaml_content)
        image_info_list = []
        for manifest in manifests:
            if manifest is None:
                continue
            if 'kind' in manifest and 'spec' in manifest:
                kind = manifest['kind']
                if kind in ['Alertmanager', 'Prometheus']:
                    container_image_info = {
                        "type": "image",
                        "details": {
                            "registryURL": manifest['spec']['image']
                        }
                    }
                    image_info_list.append(container_image_info)

                elif kind in resources_with_containers:
                    containers = []
                    init_containers = []
                    if 'template' in manifest['spec']:
                        containers = manifest['spec']['template']['spec'].get('containers', [])
                        init_containers = manifest['spec']['template']['spec'].get('initContainers', [])
                    elif kind == 'CronJob' and 'jobTemplate' in manifest['spec']:
                        containers = manifest['spec']['jobTemplate']['spec']['template']['spec'].get('containers', [])
                        init_containers = manifest['spec']['jobTemplate']['spec']['template']['spec'].get('initContainers', [])
                    else:
                        containers = manifest['spec'].get('containers', [])
                        init_containers = manifest['spec'].get('initContainers', [])

                    if init_containers is None or containers is None:
                        init_containers = init_containers or []
                        containers = containers or []

                    for container in containers + init_containers:
                        container_image_info = {
                            "type": "image",
                            "details": {
                                "registryURL": container.get('image', ''),
                                "platforms": get_image_details(container.get('image', ''))
                            }
                        }
                        image_info_list.append(container_image_info)
    except yaml.YAMLError as e:
        logging.error(f"Error parsing YAML: {e}")
        return None

    return image_info_list


# function to clean up the temporary directory
def clean_up(temp_dir):
    run_command(f"rm -rf {temp_dir}")


# function to create a temporary directory
def create_tmp_dir():
    os.makedirs(temp_dir, exist_ok=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate artifacts manifest from Helm charts.")
    parser.add_argument("chart_name", help="Name of the Helm chart")
    parser.add_argument("chart_repo_url", help="Repository URL of the Helm chart")
    parser.add_argument("chart_version", help="Version of the Helm chart")
    parser.add_argument("values_file", help="Path to the values.yaml file")
    parser.add_argument("output_file", help="Path to the output JSON file")
    parser.add_argument("extra_file", help="Path to the extra JSON file", nargs='?', default=None)

    args = parser.parse_args()

    chart_name = args.chart_name
    chart_repo_url = args.chart_repo_url
    chart_version = args.chart_version
    values_file = args.values_file
    output_file = args.output_file
    extra_file = args.extra_file

    # Create a temporary directory to store the chart and generated manifests
    create_tmp_dir()

    # Generate manifests based on the mode
    if mode == "local":
        manifest_file = generate_manifests_local(chart_name, values_file)
    else:
        manifest_file = generate_manifests(chart_name, chart_repo_url, chart_version, values_file)

    chart_info_list = extract_chart_info(manifest_file)
    if chart_info_list:
        image_info_list = process_and_generate_chart_manifests(chart_info_list)
    else:
        image_info_list = make_image_list_unique(save_image_info(manifest_file))

    for chart_info in chart_info_list:
        chart_info["details"].pop("values", None)

    chart_info_list.extend(image_info_list)

    if extra_file:
        with open(extra_file, 'r') as f:
            extra_info = json.load(f)
            chart_info_list.extend(extra_info)

    save_chart_info(chart_info_list, output_file)

    clean_up(temp_dir)
