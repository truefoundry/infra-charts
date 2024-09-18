import yaml
import sys
import json
import subprocess
import os
import logging
import time
import requests
from requests.exceptions import ConnectionError


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

def post_payload(url, payload, retries=3, delay=10):
    headers = {
        "accept": "*/*",
        "Content-Type": "application/json"
    }
    for i in range(retries):
        try:
            response = requests.post(url, headers=headers, data=json.dumps(payload))
            response.raise_for_status() # If response was successful, no Exception will be raised
            return response
        except ConnectionError as e:
            print(f'Connection error: {e}. Attempt {i+1} of {retries}. Retrying in {delay} seconds...')
            time.sleep(delay)
        except Exception as e:
            print(f'An error occurred: {e}. Attempt {i+1} of {retries}. Retrying in {delay} seconds...')
            time.sleep(delay)
    return None

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
                            "chart": source.get('chart', 'Not found'),
                            "repoURL": source.get('repoURL', 'Not found'),
                            "targetRevision": source.get('targetRevision', 'Not found'),
                            "values": source.get('helm', {}).get('values', 'Not found')
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
def process_chart_info(chart_info_list):
    chart_detail_list = []
    for chart_info in chart_info_list:
        details = chart_info["details"]
        chart = details["chart"]
        repoURL = details["repoURL"]
        targetRevision = details["targetRevision"]
        values = details["values"] if details["values"] else ""

        if chart == "aws-load-balancer-controller":
            values = values.replace("clusterName: \"\"", "clusterName: \"my-cluster\"")

        run_command(f"helm repo add {chart} {repoURL}")

        values_file = f"{temp_dir}/charts/{chart}-values.yaml"
        os.makedirs(os.path.dirname(values_file), exist_ok=True)
        with open(values_file, "w") as f:
            f.write(values)

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

# function to generate manifests for the chart
def generate_manifests(chart_name, chart_repo_url, chart_version, values_file):
    run_command(f"helm repo add {chart_name} {chart_repo_url}")
    run_command("helm repo update")
    run_command(f"helm search repo {chart_name}/{chart_name}")

    logging.info(f"Downloading the chart {chart_name} version {chart_version} from the repository {chart_repo_url}")
    logging.info(f"helm pull {chart_name}/{chart_name} --version {chart_version} --untar --untardir {temp_dir}")
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

                    for container in containers + init_containers:
                        container_image_info = {
                            "type": "image",
                            "details": {
                                "registryURL": container.get('image', '')
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

"""
This function is used to generate the summary of the components along with the versions in the inframold
charts.
"""
def save_inframold_summary(parent_chart_name, parent_chart_version, chart_info_list):
    inframold_summary = {
        "inframoldChartName": parent_chart_name,
        "inframoldChartVersion": parent_chart_version,
        "componentCharts": []
    }
    for chart_info in chart_info_list:
        if chart_info["type"] == "helm":
            inframold_summary["componentCharts"].append({
                "chartName": chart_info["details"]["chart"],
                "repoUrl": chart_info["details"]["repoURL"],
                "minChartVersion": chart_info["details"]["targetRevision"],
                "maxChartVersion": chart_info["details"]["targetRevision"]
            })

    print("Saving the inframold summary to migration-server: ", inframold_summary)
    post_payload("https://migration-server.truefoundry.com/v1/inframold", inframold_summary)

    

if __name__ == "__main__":
    if len(sys.argv) < 6:
        print("Usage: python artifacts_template_generator.py <chart-name> <chart-repo-url> <chart-version> <values.yaml> <output.json> <extra.json>")
        sys.exit(1)

    chart_name = sys.argv[1]
    chart_repo_url = sys.argv[2]
    chart_version = sys.argv[3]
    values_file = sys.argv[4]
    output_file = sys.argv[5]
    extra_file = sys.argv[6]

    # Create a temporary directory to store the chart and generated manifests
    create_tmp_dir()

    # Generate manifests based on the mode
    if mode == "local":
        manifest_file = generate_manifests_local(chart_name, values_file)
    else:
        manifest_file = generate_manifests(chart_name, chart_repo_url, chart_version, values_file)

    chart_info_list = extract_chart_info(manifest_file)
    if chart_info_list:
        image_info_list = process_chart_info(chart_info_list)
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

    save_inframold_summary(chart_name, chart_version, chart_info_list)

    clean_up(temp_dir)
