import yaml
import sys
import json
import subprocess
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def run_command(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        logging.error(f"Command failed: {command}\n{result.stderr}")
        sys.exit(1)
    return result.stdout

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

def save_chart_info(chart_info_list, output_file):
    with open(output_file, 'w') as f:
        json.dump(chart_info_list, f, indent=4)
    logging.info(f"Chart information saved to {output_file}")

def process_chart_info(chart_info_list):
    chart_detail_list = []
    for chart_info in chart_info_list:
        details = chart_info["details"]
        chart = details["chart"]
        repoURL = details["repoURL"]
        targetRevision = details["targetRevision"]
        values = details["values"]

        if chart == "aws-load-balancer-controller":
            values = values.replace("clusterName: \"\"", "clusterName: \"my-cluster\"")

        run_command(f"helm repo add {chart} {repoURL}")

        values_file = f"charts/{chart}-values.yaml"
        os.makedirs(os.path.dirname(values_file), exist_ok=True)
        with open(values_file, "w") as f:
            f.write(values)

        run_command(f"helm template {chart}/{chart} --version {targetRevision} -f {values_file} > charts/{chart}.yaml")

        with open(f"charts/{chart}.yaml", "r") as f:
            yaml_content = f.read()
            images = extract_images_from_k8s_manifests(yaml_content)

            logging.info(f"Images extracted: {images}")

            chart_detail_list.append(images)

    flattened_list = [item for sublist in chart_detail_list for item in sublist]
    return flattened_list

def generate_manifests(chart_name, chart_repo_url, chart_version, values_file):
    temp_dir = "temp"

    run_command(f"helm repo add temp-repo {chart_repo_url}")
    run_command("helm repo update")
    run_command(f"helm search repo temp-repo/{chart_name}")

    logging.info(f"Downloading the chart {chart_name} version {chart_version} from the repository {chart_repo_url}")
    run_command(f"helm pull temp-repo/{chart_name} --version {chart_version} --untar --untardir {temp_dir}")

    chart_dir = os.path.join(temp_dir, chart_name)
    manifest_file = os.path.join(temp_dir, 'generated-manifest.yaml')
    logging.info(f"Generating the manifests for the chart {chart_name} using the values file {values_file}")
    run_command(f"helm template my-release -f {values_file} {chart_dir} > {manifest_file}")

    return manifest_file

def extract_images_from_k8s_manifests(yaml_content):
    resources_with_images = ['Deployment', 'StatefulSet', 'DaemonSet', 'Job', 'CronJob', 'Pod', 'ReplicaSet']
    try:
        manifests = yaml.safe_load_all(yaml_content)
        image_info_list = []
        for manifest in manifests:
            if manifest is None:
                continue
            if 'kind' in manifest and 'spec' in manifest:
                kind = manifest['kind']
                if kind in resources_with_images:
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

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python extract_and_process_chart_info.py <chart-name> <chart-repo-url> <chart-version> <values.yaml> <output.json>")
        sys.exit(1)

    chart_name = sys.argv[1]
    chart_repo_url = sys.argv[2]
    chart_version = sys.argv[3]
    values_file = sys.argv[4]
    output_file = sys.argv[5]

    manifest_file = generate_manifests(chart_name, chart_repo_url, chart_version, values_file)

    chart_info_list = extract_chart_info(manifest_file)
    image_info_list = process_chart_info(chart_info_list)

    for chart_info in chart_info_list:
        chart_info["details"].pop("values", None)

    chart_info_list.extend(image_info_list)

    save_chart_info(chart_info_list, output_file)
