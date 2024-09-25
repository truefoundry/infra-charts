import docker
import sys
import os
import subprocess
import yaml
import json
import boto3
import logging
import requests

from botocore.exceptions import ClientError
from urllib.parse import urlparse
import random

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# get AWS_PROFILE from environment variable or use default value
AWS_PROFILE = os.getenv('AWS_PROFILE', 'default')

AWS_REGION = os.getenv('AWS_REGION')

# get docker image architecture to use from environment variable or use default value
DOCKER_IMAGE_ARCHITECTURE = os.getenv('CLUSTER_ARCHITECTURE', 'linux/amd64')

tmp_dir = "/tmp/helm_charts"


# function to run shell commands
def run_command(command):
    logging.info(f"Running command: {command}")
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed: {command}\n{result.stderr}")
    return result.stdout


# function to clean up temporary files
def clean_up(temp_dir):
    run_command(f"rm -rf {temp_dir}")


# generic repo functiion, calls other repos
def create_repository(registry_type, destination_registry, repo_name, package_type):
    if registry_type == "ecr":
        create_ecr_repository(repo_name)
    elif registry_type == "jfrog":
        create_jfrog_repository(destination_registry, package_type, "truefoundry")

# function to create a jfrog artifact repository
def create_jfrog_repository(jfrog_destination_registry, package_type, repo_name):
    # get jfrog token
    jfrog_token = os.getenv('JFROG_TOKEN')

    # jfrog doesn't allow multiple layers of repo name
    if package_type == "helm":
        repo_name = "truefoundryhelm"
        package_type = "helmoci"

    if package_type == "image":
        package_type = "docker"

    repo_url = f"https://{jfrog_destination_registry}/artifactory/api/repositories/{repo_name}"

    headers = {
        "Content-Type": "application/json",
    }

    auth = ("", jfrog_token)

    payload = {
        "key": repo_name,
        "rclass": "local",  # repo_type = "local"
        "packageType": package_type,  # package_type = [docker, helmoci]
    }

    response = requests.put(repo_url, auth=auth, headers=headers, data=json.dumps(payload))

    if response.status_code == 409 or response.status_code == 400:
        return "Repository already exists."
    elif response.status_code == 201 or response.status_code == 200:
        return "Repository created successfully."
    else:
        return f"Failed to create repository. Status code: {response.status_code}, Response: {response.text}"


# function to create ECR repository if it does not exist
def create_ecr_repository(repository_name):
    session = boto3.Session(profile_name=AWS_PROFILE)
    client = session.client('ecr', region_name=AWS_REGION)
    try:
        response = client.create_repository(repositoryName=repository_name)
        logging.info(f"Successfully created ECR repository: {repository_name}")
        return response
    except ClientError as e:
        if e.response['Error']['Code'] == 'RepositoryAlreadyExistsException':
            logging.info(f"{repository_name} repository already exists. Skipping.....")
        else:
            logging.error(f"Failed to create ECR repository: {repository_name}. Error: {e}")
        return None


# function to create ECR public repository if it does not exist
def create_public_ecr_repository(repository_name):
    session = boto3.Session(profile_name=AWS_PROFILE)
    client = session.client('ecr-public', region_name=AWS_REGION)
    try:
        response = client.create_repository(repositoryName=repository_name)
        logging.info(f"Successfully created ECR repository: {repository_name}")
        return response
    except ClientError as e:
        if e.response['Error']['Code'] == 'RepositoryAlreadyExistsException':
            logging.info(f"{repository_name} repository already exists. Skipping.....")
        else:
            logging.error(f"Failed to create ECR repository: {repository_name}. Error: {e}")
        return None


# function to parse image URL and extract image name and tag
def parse_image_url(image_url, destination_registry):
    from docker_image import reference
    # Initialize image_name and image_tag
    image_name = ""
    image_tag = ""

    ref = reference.Reference.parse(image_url)
    if not ref['tag']:
        image_tag = ":latest"
    else:
        image_tag = f":{ref['tag']}"

    # if ref['digest']:
    #     image_tag = f"{image_tag}@{ref['digest']}"

    if ref['name'] is None:
        raise ValueError(f"Invalid image URL: {image_url}")
    else:
        image_split = ref['name'].split('/')
        if len(image_split) == 1:
            image_name = image_split[0]
        else:
            if '.' in image_split[0]:
                image_name = "/".join(image_split[1:])
            else:
                image_name = ref['name']

    image_name = f"truefoundry/{image_name}"
    new_image_url = f"{destination_registry}/{image_name}{image_tag}"
    return image_name, new_image_url


# function to pull and push images
def pull_and_push_images(image_list, destination_registry, registry_type, artifact_type):
    random.shuffle(image_list)
    for image in image_list:

        image_url = image["details"]["registryURL"].strip()
        if not image_url:
            continue
        elif "/eks/" in image_url or "/eks-distro/" in image_url:
            logging.info(f"Skipping system EKS image: {image_url}")
            continue
        elif image_url == 'auto':
            logging.info(f"Skipping auto")
            continue
        image_name, new_image_url = parse_image_url(image_url, destination_registry)
        # Check if the new_image_url already exists
        try:
            run_command(f"docker manifest inspect {new_image_url}")
            logging.info(f"Image {new_image_url} already exists. Skipping push...")
            continue
        except Exception as e:
            # Image does not exist, proceed with pushing
            pass

        run_command(f"docker pull {image_url} --platform {DOCKER_IMAGE_ARCHITECTURE}")

        create_repository(registry_type, destination_registry, image_name, artifact_type)

        run_command(f"docker tag {image_url} {new_image_url}")

        logging.info(f"Pushing image: {new_image_url}")
        try:
            run_command(f"docker push {new_image_url}")
            logging.info(f"Successfully pushed image: {new_image_url}")
        except Exception as e:
            logging.error(f"Failed to push image: {new_image_url}. Error: {e}")


# function to download and push Helm charts
def download_and_push_helm_charts(helm_list, destination_registry, registry_type, artifact_type):
    tmp_dir = "/tmp/helm_charts"
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    for helm in helm_list:
        chart = helm["details"]["chart"]
        repo_url = helm["details"]["repoURL"]
        target_revision = helm["details"]["targetRevision"]

        logging.info(f"Downloading Helm chart: {chart} from {repo_url}")
        try:
            if not urlparse(repo_url).scheme:
                logging.info(f"OCI registry detected for {chart}. Skipping helm repo add and update.")
                run_command(f"helm pull oci://{repo_url}/{chart} --version {target_revision}")
            else:
                run_command(f"helm repo add {chart} {repo_url}")
                run_command(f"helm pull {chart}/{chart} --version {target_revision}")
            logging.info(f"Successfully downloaded Helm chart: {chart}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to download Helm chart: {chart}. Error: {e}")
            continue

        # get registry URL
        registry_path = urlparse(repo_url).path.strip('/')

        chart_package = f"{chart}-{target_revision}.tgz"
        new_chart_url = f"oci://{destination_registry}/truefoundryhelm/{registry_path}/"

        logging.info(f"Pushing Helm chart: {new_chart_url}")
        try:
            if registry_path.startswith("public.ecr.aws"):
                create_public_ecr_repository(f"truefoundryhelm/{registry_path}/{chart}")
            else:
                repo_path = f"truefoundryhelm/{registry_path}/{chart}"
                create_repository(registry_type, destination_registry, repo_path, "helm")
            try:
                logging.info(
                    f"Chart {chart} with version {target_revision} does not exist in the repository. Pushing...")
                run_command(f"helm push {chart_package} {new_chart_url}")
            except Exception as e:
                logging.error(f"Failed to check if chart {chart} with version {target_revision} exists. Error: {e}")
                continue
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to push Helm chart: {chart_package}. Error: {e}")


# function to extract images from Kubernetes manifests
def read_manifest(file_path):
    try:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        logging.error(f"Error reading manifest file: {e}")
        return None


# function to process the manifest
def process_manifest(artifact_type, file_path, destination_registry, registry_type):
    manifest = read_manifest(file_path)
    if manifest is None:
        logging.error("Manifest processing aborted due to previous errors")
        return

    if artifact_type == "image":
        image_list = [item for item in manifest if item["type"] == "image"]
        if image_list:
            pull_and_push_images(image_list, destination_registry, registry_type, artifact_type)
    elif artifact_type == "helm":
        helm_list = [item for item in manifest if item["type"] == "helm"]
        if helm_list:
            download_and_push_helm_charts(helm_list, destination_registry, registry_type, artifact_type)


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python upload_artifacts.py <artifact_type> <file_path> <destination_registry> <registry_type>")
        sys.exit(1)

    artifact_type = sys.argv[1]
    file_path = sys.argv[2]
    destination_registry = sys.argv[3]
    registry_type = sys.argv[4]

    if not os.path.isfile(file_path):
        logging.error(f"File not found: {file_path}")
        sys.exit(1)

    process_manifest(artifact_type, file_path, destination_registry, registry_type)
