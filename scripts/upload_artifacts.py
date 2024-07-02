import docker
import sys
import os
import subprocess
import yaml
import boto3
import logging

from botocore.exceptions import ClientError
from urllib.parse import urlparse

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# get AWS_PROFILE from environment variable or use default value
AWS_PROFILE = os.getenv('AWS_PROFILE', 'default')

# get docker image architecture to use from environment variable or use default value
DOCKER_IMAGE_ARCHITECTURE = os.getenv('CLUSTER_ARCHITECTURE', 'linux/amd64')

tmp_dir = "/tmp/helm_charts"
# function to run shell commands
def run_command(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        logging.error(f"Command failed: {command}\n{result.stderr}")
        sys.exit(1)
    return result.stdout

# function to clean up temporary files
def clean_up(temp_dir):
    run_command(f"rm -rf {temp_dir}")

# function to create ECR repository if it does not exist
def create_ecr_repository(repository_name, region):
    session = boto3.Session(profile_name=AWS_PROFILE)
    client = session.client('ecr', region_name=region)
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

# function to pull and push images
def pull_and_push_images(image_list, destination_registry, region):
    client = docker.from_env()

    for image in image_list:
        image_url = image["details"]["registryURL"].strip()
        if not image_url:
            continue

        logging.info(f"Pulling image: {image_url}")
        try:
            pulled_image = client.images.pull(image_url, platform=DOCKER_IMAGE_ARCHITECTURE)
            logging.info(f"Successfully pulled image: {image_url}")
        except Exception as e:
            logging.error(f"Failed to pull image: {image_url}. Error: {e}")
            continue


        # Initialize image_name and image_tag
        image_name = ""
        image_tag = ""

        # Handle image name and tag
        image_split = image_url.split('/')

        if '.' not in image_split[0]:
            # Handle case where there is no domain in the image URL eg busybox:latest
            image_name = image_url.split(':')[0]
            image_tag = image_url.split(':')[1] if ':' in image_url else 'latest'
        else:
            image_name_tag = image_split[1:]
            image_name_parts = []

            if len(image_name_tag) == 0:
                # Handle case where there are no parts after the domain eg quay.io/busybox:latest
                image_name = image_url.split(':')[0]
                image_tag = image_url.split(':')[1] if ':' in image_url else 'latest'
            elif len(image_name_tag) == 1:
                # Handle case where there is only one part after the domain eg quay.io/busybox:latest
                if ':' in image_name_tag[0]:
                    image_name = image_name_tag[0].split(':')[0]
                    image_tag = image_name_tag[0].split(':')[1]
                else:
                    image_name = image_name_tag[0]
                    image_tag = 'latest'
            else:
                # Handle case where there are multiple parts after the domain eg quay.io/coreos/etcd:v3.4.13
                image_name_parts = image_name_tag[:-1]
                if image_name_parts:
                    image_name = "/".join(image_name_parts) + "/" + image_name_tag[-1].split(':')[0]
                else:
                    image_name = image_name_tag[-1].split(':')[0]
                image_tag = image_name_tag[-1].split(':')[1] if ':' in image_name_tag[-1] else 'latest'

        new_image_url = f"{destination_registry}/{image_name}:{image_tag}"
        repository_name = destination_registry.split('/')[-1]

        create_ecr_repository(image_name, region)
        pulled_image.tag(new_image_url)

        logging.info(f"Pushing image: {new_image_url}")
        try:
            run_command(f"docker push {new_image_url}")
            logging.info(f"Successfully pushed image: {new_image_url}")
        except Exception as e:
            logging.error(f"Failed to push image: {new_image_url}. Error: {e}")

def download_and_push_helm_charts(helm_list, destination_registry, region):
    tmp_dir = "/tmp/helm_charts"
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    for helm in helm_list:
        chart = helm["details"]["chart"]
        repo_url = helm["details"]["repoURL"]
        target_revision = helm["details"]["targetRevision"]

        logging.info(f"Downloading Helm chart: {chart} from {repo_url}")
        try:
            run_command(f"helm repo add {chart} {repo_url}")
            run_command(f"helm pull {chart}/{chart} --version {target_revision} ")
            logging.info(f"Successfully downloaded Helm chart: {chart}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to download Helm chart: {chart}. Error: {e}")
            continue

        # get registry URL
        registry_path = urlparse(repo_url).path.strip('/')

        chart_package = f"{chart}-{target_revision}.tgz"
        new_chart_url = f"oci://{destination_registry}/{registry_path}/"

        logging.info(f"Pushing Helm chart: {new_chart_url}")
        try:
            create_ecr_repository(f"{registry_path}/{chart}", region)
            run_command(f"helm push {chart_package} {new_chart_url}")
            logging.info(f"Successfully pushed Helm chart: {chart_package}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to push Helm chart: {chart_package}. Error: {e}")

def read_manifest(file_path):
    try:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        logging.error(f"Error reading manifest file: {e}")
        return None

def process_manifest(file_path, destination_registry, region):
    manifest = read_manifest(file_path)
    if manifest is None:
        logging.error("Manifest processing aborted due to previous errors")
        return

    image_list = [item for item in manifest if item["type"] == "image"]
    helm_list = [item for item in manifest if item["type"] == "helm"]

    if image_list:
        pull_and_push_images(image_list, destination_registry, region)

    if helm_list:
        download_and_push_helm_charts(helm_list, destination_registry, region)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <file_path> <destination_registry> <aws_region>")
        sys.exit(1)

    file_path = sys.argv[1]
    destination_registry = sys.argv[2]
    aws_region = sys.argv[3]

    if not os.path.isfile(file_path):
        logging.error(f"File not found: {file_path}")
        sys.exit(1)

    process_manifest(file_path, destination_registry, aws_region)

    clean_up(temp_dir)
