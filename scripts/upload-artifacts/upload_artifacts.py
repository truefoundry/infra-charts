import argparse
import json
import logging
import subprocess
from urllib.parse import urlparse

import yaml

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


# function to run shell commands
def run_command(command):
    logging.info(f"Running command: {command}")
    result = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    if result.returncode != 0:
        raise RuntimeError(f"Command failed: {command}\n{result.stderr}")
    return result.stdout


def parse_image_url(image_url, destination_registry):
    from docker_image import reference

    # Initialize image_name and image_tag
    ref = reference.Reference.parse(image_url)
    image_tag = ref["tag"] if ref["tag"] else "latest"

    image_name = ""
    if ref["name"] is None:
        raise ValueError(f"Invalid image URL: {image_url}")
    else:
        image_split = ref["name"].split("/")
        if len(image_split) == 1:
            image_name = image_split[0]
        else:
            if "." in image_split[0]:
                image_name = "/".join(image_split[1:])
            else:
                image_name = ref["name"]

    new_image_url = f"{destination_registry}/{image_name}:{image_tag}"
    return new_image_url


# Helper function to check if image exists and has both arm64 and amd64 architectures
def check_image_exists_and_architectures(image_url):
    try:
        manifest_data = json.loads(run_command(f"docker manifest inspect {image_url}"))

        architectures = [
            layer["platform"]["architecture"] for layer in manifest_data["manifests"]
        ]

        if "amd64" in architectures and "arm64" in architectures:
            logging.info(f"Image {image_url} has both arm64 and amd64 architectures.")
            return True, True
        else:
            if "amd64" not in architectures:
                logging.info(
                    f"Image {image_url} exists but does not have amd64 architecture."
                )
            if "arm64" not in architectures:
                logging.info(
                    f"Image {image_url} exists but does not have arm64 architecture."
                )
            return True, False
    except Exception:
        logging.info(f"Image {image_url} does not exist or cannot be inspected.")
        return False, False


# function to pull and push images


def pull_and_push_images(image_list, destination_registry, excluded_registries=[]):
    for image in image_list:
        image_url = image["details"]["registryURL"].strip()
        # Skip if image URL is in excluded registries
        image_exclude = False
        for registry in excluded_registries:
            if image_url.startswith(registry):
                logging.info(
                    f"Skipping image: {image_url} as it is in excluded registries"
                )
                image_exclude = True
                break
        if image_exclude:
            continue

        # Skip if image URL is empty
        if not image_url:
            continue
        # These images can only be pulled within an EC2 machine - hence skipping it
        elif "/eks/" in image_url or "/eks-distro/" in image_url:
            logging.info(f"Skipping system EKS image: {image_url}")
            continue
        elif image_url == "auto":
            logging.info("Skipping auto")
            continue

        new_image_url = parse_image_url(image_url, destination_registry)

        # Check if the new_image_url already exists and has both architectures
        image_exists, _ = check_image_exists_and_architectures(new_image_url)

        if image_exists:
            logging.info(f"Image {new_image_url} already exists Skipping push...")
            continue

        try:
            # Use buildx imagetool create for multi-arch support
            logging.info(f"Creating multi-arch image: {new_image_url}")
            logging.info(
                f"docker buildx imagetools create -t {new_image_url} {image_url}"
            )
            run_command(
                f"docker buildx imagetools create -t {new_image_url} {image_url}"
            )
            logging.info(f"Successfully created multi-arch image: {new_image_url}")
        except Exception as e:
            logging.error(
                f"Failed to create multi-arch image: {new_image_url}. Error: {e}"
            )


# function to download and push Helm charts


def download_and_push_helm_charts(helm_list, destination_registry):
    for helm in helm_list:
        chart = helm["details"]["chart"]
        repo_url = helm["details"]["repoURL"]
        target_revision = helm["details"]["targetRevision"]

        registry_path = urlparse(repo_url).path.strip("/")
        chart_package = f"{chart}-{target_revision}.tgz"
        new_chart_url = f"oci://{destination_registry}"
        if registry_path:
            new_chart_url = f"oci://{destination_registry}/{registry_path}"
        # Check if chart exists in destination repo
        try:
            run_command(
                f"helm show chart {new_chart_url}/{chart} --version {target_revision}"
            )
            logging.info("Chart already exists in destination repo")
            continue
        except Exception as e:
            logging.error(f"Failed to download Helm chart: {chart}. Error: {e}")

        # Download chart from source repo
        logging.info(f"Downloading Helm chart: {chart} from source repo: {repo_url}")
        try:
            # Absence of scheme indicates OCI registry https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#declarative
            if urlparse(repo_url).scheme == "oci":
                logging.info(
                    f"OCI registry detected for {chart}. Skipping helm repo add and update."
                )
                run_command(f"helm pull {repo_url}/{chart} --version {target_revision}")
            else:
                run_command(f"helm repo add {chart} {repo_url}")
                run_command("helm repo update")
                run_command(f"helm pull {chart}/{chart} --version {target_revision}")
            logging.info(f"Successfully downloaded Helm chart: {chart}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to download Helm chart: {chart}. Error: {e}")
            continue

        # Push chart to destination repo
        logging.info(f"Pushing Helm chart: {new_chart_url}")
        try:
            run_command(f"helm push {chart_package} {new_chart_url}")
        except Exception as e:
            logging.error(f"Failed to push Helm chart: {chart_package}. Error: {e}")
            exit("Cannot push helm chart to destination repo")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Upload artifacts to a destination registry."
    )
    parser.add_argument(
        "artifact_type",
        choices=["image", "helm"],
        help="Type of artifact to upload (image or helm)",
    )
    parser.add_argument("file_path", help="Path to the manifest file")
    parser.add_argument("destination_registry", help="Destination registry URL")
    parser.add_argument(
        "--exclude-registries",
        nargs="*",
        default=[],
        help="List of registries to exclude from pushing",
    )

    args = parser.parse_args()

    artifact_type = args.artifact_type
    file_path = args.file_path
    destination_registry = args.destination_registry
    excluded_registries = args.exclude_registries
    logging.info(
        f"Artifact type: {artifact_type}, File path: {file_path}, Destination registry: {destination_registry}, Excluded registries: {excluded_registries}"
    )

    # Remove trailing slash from destination_registry if present
    destination_registry = destination_registry.rstrip("/")

    manifest = None

    try:
        with open(file_path, "r") as file:
            manifest = yaml.safe_load(file)
    except Exception as e:
        logging.error(f"Error reading manifest file: {e}")

    if manifest is None:
        logging.error("Manifest processing aborted due to errors")
        exit()

    if artifact_type == "image":
        image_list = [item for item in manifest if item["type"] == "image"]
        if image_list:
            pull_and_push_images(image_list, destination_registry, excluded_registries)
    elif artifact_type == "helm":
        helm_list = [item for item in manifest if item["type"] == "helm"]
        if helm_list:
            download_and_push_helm_charts(helm_list, destination_registry)
