import yaml
import sys
import json
import subprocess
import os

def run_command(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        print(f"Command failed: {command}")
        print(result.stderr)
        sys.exit(1)
    return result.stdout

def extract_chart_info(manifest_file):
    chart_info_list = []

    with open(manifest_file, 'r') as f:
        manifest = yaml.safe_load_all(f)

        for doc in manifest:
            if isinstance(doc, dict) and 'spec' in doc:
                source = doc['spec'].get('source', {})
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

    print(f"Chart information saved to {output_file}")

def process_chart_info(chart_info_list):
    chart_detail_list = []
    for chart_info in chart_info_list:
        details = chart_info["details"]
        chart = details["chart"]
        repoURL = details["repoURL"]
        targetRevision = details["targetRevision"]
        values = details["values"]

        #
        if chart in ["keda", "cost-analyzer", "argo-cd"]:
            print(f"Skipping chart {chart}")
            continue

        # if chart is aws-load-balancer-controller then update the values to include the clusterName
        if chart == "aws-load-balancer-controller":
            values = values.replace("clusterName: \"\"", "clusterName: \"my-cluster\"")

        run_command(f"helm repo add {chart} {repoURL}")

        values_file = f"charts/{chart}-values.yaml"
        with open(values_file, "w") as f:
            f.write(values)

        run_command(f"helm template {chart}/{chart} --version {targetRevision} -f {values_file} > charts/{chart}.yaml")

        with open(f"charts/{chart}.yaml", "r") as f:
            yaml_content = f.read()
            images = extract_images_from_k8s_manifests(yaml_content)

            print(f"Images: {images}")

            chart_detail_list.append(images)

    return chart_detail_list

def generate_manifests(chart_name, chart_repo_url, values_file):
    temp_dir = "temp"

    run_command(f"helm repo add temp-repo {chart_repo_url}")
    run_command("helm repo update")
    run_command(f"helm search repo temp-repo/{chart_name}")

    print(f"Downloading the chart {chart_name} from the repository {chart_repo_url}")
    run_command(f"helm pull temp-repo/{chart_name} --untar --untardir {temp_dir}")

    chart_dir = os.path.join(temp_dir, chart_name)
    manifest_file = os.path.join(temp_dir, 'generated-manifest.yaml')
    print(f"Generating the manifests for the chart {chart_name} using the values file {values_file}")
    run_command(f"helm template my-release -f {values_file} {chart_dir} > {manifest_file}")

    return manifest_file

def extract_images_from_k8s_manifests(yaml_content):
    # list of k8s resources that can have images
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
                    if 'template' in manifest['spec']:
                        containers = manifest['spec']['template']['spec'].get('containers', [])
                    elif kind == 'CronJob' and 'jobTemplate' in manifest['spec']:
                        containers = manifest['spec']['jobTemplate']['spec']['template']['spec'].get('containers', [])
                    else:
                        containers = manifest['spec'].get('containers', [])

                    for container in containers:
                        container_image_info = {
                            "type": "image",
                            "details": {
                                "registryURL": container.get('image', '')
                            }
                        }
                        image_info_list.append(container_image_info)

    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        return None

    return image_info_list

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python extract_and_process_chart_info.py <chart-name> <chart-repo-url> <values.yaml> <output.json>")
        sys.exit(1)

    chart_name = sys.argv[1]
    chart_repo_url = sys.argv[2]
    values_file = sys.argv[3]
    output_file = sys.argv[4]

    manifest_file = generate_manifests(chart_name, chart_repo_url, values_file)

    chart_info_list = extract_chart_info(manifest_file)
    image_info_list = process_chart_info(chart_info_list)

    for chart_info in chart_info_list:
        chart_info["details"].pop("values", None)

    chart_info_list.extend(image_info_list)

    save_chart_info(chart_info_list, output_file)
