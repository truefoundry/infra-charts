import argparse
import json
import logging
import os
import re
import subprocess
import time
from urllib.parse import urlparse

import yaml

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

# Global cache for image mappings
_image_cache = None
_cache_file_path = None

# Global cache for failed uploads
_failed_uploads = None
_failed_uploads_file_path = None


def load_image_cache(cache_file_path):
    """Load image cache from file."""
    global _image_cache, _cache_file_path
    _cache_file_path = cache_file_path
    
    if not cache_file_path:
        _image_cache = {}
        return {}
    
    if os.path.exists(cache_file_path):
        try:
            with open(cache_file_path, "r") as f:
                _image_cache = json.load(f)
                logging.info(f"Loaded image cache from {cache_file_path} with {len(_image_cache)} entries")
                return _image_cache
        except Exception as e:
            logging.warning(f"Failed to load image cache: {e}. Starting with empty cache.")
            _image_cache = {}
            return {}
    else:
        _image_cache = {}
        return {}


def save_image_cache():
    """Save image cache to file."""
    global _image_cache, _cache_file_path
    
    if not _cache_file_path or _image_cache is None:
        return
    
    try:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(_cache_file_path) if os.path.dirname(_cache_file_path) else ".", exist_ok=True)
        
        with open(_cache_file_path, "w") as f:
            json.dump(_image_cache, f, indent=2)
        logging.info(f"Saved image cache to {_cache_file_path} with {len(_image_cache)} entries")
    except Exception as e:
        logging.error(f"Failed to save image cache: {e}")


def update_image_cache(source_uri, destination_uri):
    """Update the image cache with a new mapping."""
    global _image_cache
    
    if _image_cache is None:
        _image_cache = {}
    
    if source_uri not in _image_cache:
        _image_cache[source_uri] = []
    
    if destination_uri not in _image_cache[source_uri]:
        _image_cache[source_uri].append(destination_uri)
        logging.info(f"Updated cache: {source_uri} -> {destination_uri}")


def load_failed_uploads(failed_uploads_file_path):
    """Load failed uploads cache from file."""
    global _failed_uploads, _failed_uploads_file_path
    _failed_uploads_file_path = failed_uploads_file_path
    
    if not failed_uploads_file_path:
        _failed_uploads = {}
        return {}
    
    if os.path.exists(failed_uploads_file_path):
        try:
            with open(failed_uploads_file_path, "r") as f:
                _failed_uploads = json.load(f)
                logging.info(f"Loaded failed uploads cache from {failed_uploads_file_path} with {len(_failed_uploads)} entries")
                return _failed_uploads
        except Exception as e:
            logging.warning(f"Failed to load failed uploads cache: {e}. Starting with empty cache.")
            _failed_uploads = {}
            return {}
    else:
        _failed_uploads = {}
        return {}


def save_failed_uploads():
    """Save failed uploads cache to file."""
    global _failed_uploads, _failed_uploads_file_path
    
    if not _failed_uploads_file_path or _failed_uploads is None:
        return
    
    try:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(_failed_uploads_file_path) if os.path.dirname(_failed_uploads_file_path) else ".", exist_ok=True)
        
        with open(_failed_uploads_file_path, "w") as f:
            json.dump(_failed_uploads, f, indent=2)
        logging.info(f"Saved failed uploads cache to {_failed_uploads_file_path} with {len(_failed_uploads)} entries")
    except Exception as e:
        logging.error(f"Failed to save failed uploads cache: {e}")


def record_failed_upload(source_uri, destination_uri, reason):
    """Record a failed upload with the reason."""
    global _failed_uploads
    from datetime import datetime
    
    if _failed_uploads is None:
        _failed_uploads = {}
    
    if source_uri not in _failed_uploads:
        _failed_uploads[source_uri] = []
    
    # Check if this destination already has a failure recorded
    existing_failure = None
    for failure in _failed_uploads[source_uri]:
        if failure.get("destination") == destination_uri:
            existing_failure = failure
            break
    
    failure_entry = {
        "destination": destination_uri,
        "reason": reason,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    
    if existing_failure:
        # Update existing failure
        existing_failure.update(failure_entry)
        logging.info(f"Updated failed upload record: {source_uri} -> {destination_uri}: {reason}")
    else:
        # Add new failure
        _failed_uploads[source_uri].append(failure_entry)
        logging.info(f"Recorded failed upload: {source_uri} -> {destination_uri}: {reason}")


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

    # Handle tfy-images path transformation based on destination registry and source image
    # If source has tfy-images and destination is ECR: remove tfy-images
    # If source has truefoundrycloud and destination is JFrog: remove truefoundrycloud and add tfy-images
    # If source has tfy-images and destination is JFrog (with tfy-images): remove to avoid duplication
    path_parts = image_name.split("/")
    source_has_truefoundrycloud = "truefoundrycloud" in path_parts
    source_has_tfy_images = "tfy-images" in path_parts
    
    if "ecr.aws" in destination_registry or "truefoundrycloud" in destination_registry:
        # For ECR destination, remove tfy-images from the path if it exists
        if source_has_tfy_images:
            path_parts = [part for part in path_parts if part != "tfy-images"]
            image_name = "/".join(path_parts) if path_parts else image_name
    elif "jfrog.io" in destination_registry:
        # For JFrog destination
        if source_has_truefoundrycloud:
            # If source has truefoundrycloud, remove it and ensure tfy-images is present
            path_parts = [part for part in path_parts if part != "truefoundrycloud"]
            # Add tfy-images at the beginning if not already present
            if "tfy-images" not in path_parts:
                path_parts.insert(0, "tfy-images")
            image_name = "/".join(path_parts) if path_parts else image_name
        elif "tfy-images" in destination_registry and path_parts and path_parts[0] == "tfy-images":
            # If destination already has tfy-images and source also starts with tfy-images, remove it to avoid duplication
            path_parts = path_parts[1:]  # Remove the leading tfy-images
            image_name = "/".join(path_parts) if path_parts else image_name

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


# Helper function to check if registry is ECR
def is_ecr_registry(registry_url):
    # ECR URL patterns:
    # Private: <account-id>.dkr.ecr.<region>.amazonaws.com
    # Public: public.ecr.aws
    private_ecr_pattern = r"^\d+\.dkr\.ecr\.[a-z0-9-]+\.amazonaws\.com"
    public_ecr_pattern = r"^public\.ecr\.aws"
    return bool(re.match(private_ecr_pattern, registry_url) or re.match(public_ecr_pattern, registry_url))


# Helper function to check if registry is public ECR
def is_public_ecr_registry(registry_url):
    public_ecr_pattern = r"^public\.ecr\.aws"
    return bool(re.match(public_ecr_pattern, registry_url))


# Helper function to extract region from ECR URL
def get_ecr_region(registry_url):
    # For public ECR, use us-east-1 (required for public ECR API)
    if is_public_ecr_registry(registry_url):
        return "us-east-1"
    # Private ECR URL pattern: <account-id>.dkr.ecr.<region>.amazonaws.com
    match = re.search(r"\.dkr\.ecr\.([a-z0-9-]+)\.amazonaws\.com", registry_url)
    if match:
        return match.group(1)
    return None


# Helper function to ensure ECR repository exists
def ensure_ecr_repository_exists(repository_name, region, registry_url=None):
    try:
        import boto3
        from botocore.exceptions import ClientError

        # Auto-detect if it's public ECR from registry URL, or use region as fallback
        # Public ECR always uses us-east-1 for API calls
        is_public = is_public_ecr_registry(registry_url) if registry_url else (region == "us-east-1")
        
        # Use ecr-public client for public ECR, ecr client for private ECR
        if is_public:
            ecr_client = boto3.client("ecr-public", region_name="us-east-1")
        else:
            ecr_client = boto3.client("ecr", region_name=region)
        
        # Check if repository exists
        try:
            ecr_client.describe_repositories(repositoryNames=[repository_name])
            logging.info(f"ECR repository '{repository_name}' already exists")
            return True
        except ClientError as e:
            if e.response["Error"]["Code"] == "RepositoryNotFoundException":
                # Repository doesn't exist, create it
                logging.info(f"Creating ECR repository: {repository_name} (public: {is_public})")
                try:
                    ecr_client.create_repository(repositoryName=repository_name)
                    logging.info(f"Successfully created ECR repository: {repository_name}")
                    return True
                except ClientError as create_error:
                    error_code = create_error.response.get("Error", {}).get("Code", "Unknown")
                    error_msg = create_error.response.get("Error", {}).get("Message", str(create_error))
                    logging.error(f"Failed to create ECR repository '{repository_name}': {error_code} - {error_msg}")
                    return False
            else:
                error_code = e.response.get("Error", {}).get("Code", "Unknown")
                error_msg = e.response.get("Error", {}).get("Message", str(e))
                logging.error(f"ECR describe_repositories failed for '{repository_name}': {error_code} - {error_msg}")
                raise
    except Exception as e:
        logging.error(f"Failed to ensure ECR repository exists '{repository_name}': {type(e).__name__}: {e}")
        import traceback
        logging.debug(traceback.format_exc())
        return False

# function to get truefoundry chart images from manifest

def get_truefoundry_chart_images(manifest):
    """
    Return a set of image URLs referenced by the `truefoundry` helm chart entry in the manifest json.
    """
    images = set()
    for item in manifest or []:
        if item.get("type") != "helm":
            continue

        details = item.get("details") or {}
        if details.get("chart") != "truefoundry":
            continue

        for img in details.get("images") or []:
            if not img:
                continue
            img = str(img).strip()
            if not img or img == "auto":
                continue
            images.add(img)

    return images

# function to pull and push images to a single destination
def push_image_to_destination(image_url, destination_registry):
    """Push a single image to a destination registry."""
    new_image_url = parse_image_url(image_url, destination_registry)

    # Check if the new_image_url already exists and has both architectures
    image_exists, _ = check_image_exists_and_architectures(new_image_url)

    if image_exists:
        logging.info(f"Image {new_image_url} already exists Skipping push...")
        # Update cache even if image already exists
        update_image_cache(image_url, new_image_url)
        return True

    # Check if destination is ECR and ensure repository exists BEFORE pushing
    if is_ecr_registry(destination_registry):
        region = get_ecr_region(destination_registry)
        
        if region:
            # Extract repository name from new_image_url (without tag)
            # Format: registry/path/to/image:tag -> need path/to/image
            image_url_parts = new_image_url.split(":", 1)[0]  # Remove tag
            registry_and_repo = image_url_parts.split("/", 1)
            if len(registry_and_repo) > 1:
                repo_name = registry_and_repo[1]  # Get everything after registry
                
                is_public = is_public_ecr_registry(destination_registry)
                logging.info(f"Detected ECR registry ({'public' if is_public else 'private'}). Ensuring repository exists: {repo_name}")
                if not ensure_ecr_repository_exists(repo_name, region, registry_url=destination_registry):
                    error_reason = f"Failed to ensure ECR repository exists: {repo_name}"
                    logging.error(error_reason)
                    record_failed_upload(image_url, new_image_url, error_reason)
                    return False
            else:
                error_reason = f"Could not extract repository name from image URL: {new_image_url}"
                logging.warning(error_reason)
                record_failed_upload(image_url, new_image_url, error_reason)
                return False

    # Retry logic for rate limiting (429 errors)
    max_retries = 3
    retry_delay = 5  # Start with 5 seconds
    
    for attempt in range(max_retries):
        try:
            # Use buildx imagetool create for multi-arch support
            logging.info(f"Creating multi-arch image: {new_image_url} (attempt {attempt + 1}/{max_retries})")
            logging.info(
                f"docker buildx imagetools create -t {new_image_url} {image_url}"
            )
            run_command(
                f"docker buildx imagetools create -t {new_image_url} {image_url}"
            )
            logging.info(f"Successfully created multi-arch image: {new_image_url}")
            
            # Update cache with successful push
            update_image_cache(image_url, new_image_url)
            
            return True
        except Exception as e:
            error_str = str(e)
            # Check if it's a rate limit error (429)
            is_rate_limit = "429" in error_str or "Too Many Requests" in error_str or "Rate exceeded" in error_str or "toomanyrequests" in error_str.lower()
            
            if is_rate_limit and attempt < max_retries - 1:
                # Exponential backoff: 5s, 10s, 20s
                wait_time = retry_delay * (2 ** attempt)
                logging.warning(
                    f"Rate limit error (429) when pushing {new_image_url}. "
                    f"Retrying in {wait_time} seconds... (attempt {attempt + 1}/{max_retries})"
                )
                time.sleep(wait_time)
                continue
            else:
                # Determine failure reason
                if is_rate_limit:
                    failure_reason = f"Rate limit exceeded after {max_retries} attempts: {error_str}"
                    logging.error(
                        f"Failed to create multi-arch image: {new_image_url}. {failure_reason}"
                    )
                    logging.error(
                        f"Consider reducing push frequency or checking ECR rate limits."
                    )
                else:
                    failure_reason = f"Failed to push image: {error_str}"
                    logging.error(
                        f"Failed to create multi-arch image: {new_image_url}. Error: {e}"
                    )
                
                record_failed_upload(image_url, new_image_url, failure_reason)
                return False
    
    return False


def pull_and_push_images(image_list, destination_registries, excluded_registries=None, excluded_images=None):
    """
    Push images to multiple destination registries.
    
    Args:
        image_list: List of image items from manifest
        destination_registries: List of destination registry URLs
        excluded_registries: List of registries to exclude from source images
        excluded_images: Set of image URLs to exclude
    """
    if excluded_registries is None:
        excluded_registries = []
    if excluded_images is None:
        excluded_images = set()
    
    # Ensure destination_registries is a list
    if isinstance(destination_registries, str):
        destination_registries = [destination_registries]
    
    # Remove trailing slashes from all destination registries
    destination_registries = [reg.rstrip("/") for reg in destination_registries]

    for image in image_list:
        image_url = image["details"]["registryURL"].strip()

        if image_url in excluded_images:
            logging.info(
                f"Skipping image: {image_url} as it is referenced by the truefoundry chart in the manifest"
            )
            continue

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
        elif image_url == "auto":
            logging.info("Skipping auto")
            continue

        # Push to each destination registry
        for destination_registry in destination_registries:
            logging.info(f"Processing image {image_url} for destination {destination_registry}")
            success = push_image_to_destination(image_url, destination_registry)
            if not success:
                logging.warning(f"Failed to push {image_url} to {destination_registry}, but continuing with other destinations")
            
            # Add a small delay between pushes to avoid rate limiting, especially for ECR
            if is_ecr_registry(destination_registry):
                time.sleep(2)  # 2 second delay for ECR to avoid rate limits
            else:
                time.sleep(0.5)  # Smaller delay for other registries


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
        
        # Check if destination is ECR and ensure repository exists BEFORE pushing
        if is_ecr_registry(destination_registry):
            region = get_ecr_region(destination_registry)
            
            if region:
                # Extract path from destination_registry
                # destination_registry format: account-id.dkr.ecr.region.amazonaws.com/path/to/repo
                # or public.ecr.aws/path/to/repo
                dest_registry_parts = destination_registry.split("/", 1)
                dest_path = dest_registry_parts[1] if len(dest_registry_parts) > 1 else ""
                
                # Construct the full repository path
                # The path includes: dest_path + registry_path (from source) + chart name
                path_parts = []
                if dest_path:
                    path_parts.append(dest_path)
                if registry_path:
                    path_parts.append(registry_path)
                path_parts.append(chart)
                full_repo_path = "/".join(path_parts)
                
                is_public = is_public_ecr_registry(destination_registry)
                logging.info(f"Detected ECR registry ({'public' if is_public else 'private'}). Ensuring repository exists: {full_repo_path}")
                if not ensure_ecr_repository_exists(full_repo_path, region, registry_url=destination_registry):
                    logging.error(f"Failed to ensure ECR repository exists: {full_repo_path}")
                    exit("Cannot ensure ECR repository exists")
        
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
    parser.add_argument(
        "--additional-destinations",
        nargs="*",
        default=[],
        help="Additional destination registries to push images to (only for image artifact type)",
    )
    parser.add_argument(
        "--cache-file",
        default=None,
        help="Path to JSON file for caching image mappings (format: {source_uri: [destination_uri_1, destination_uri_2]})",
    )
    parser.add_argument(
        "--failed-uploads-file",
        default=None,
        help="Path to JSON file for tracking failed uploads (format: {source_uri: [{destination, reason, timestamp}]})",
    )

    args = parser.parse_args()

    artifact_type = args.artifact_type
    file_path = args.file_path
    destination_registry = args.destination_registry
    excluded_registries = args.exclude_registries
    additional_destinations = args.additional_destinations
    cache_file = args.cache_file
    failed_uploads_file = args.failed_uploads_file
    
    # Collect all destination registries for images
    all_destinations = [destination_registry]
    if additional_destinations:
        all_destinations.extend(additional_destinations)
    
    logging.info(
        f"Artifact type: {artifact_type}, File path: {file_path}, Destination registry: {destination_registry}, Additional destinations: {additional_destinations}, Excluded registries: {excluded_registries}"
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

    # Load image cache if cache file is provided
    if cache_file:
        load_image_cache(cache_file)
    
    # Load failed uploads cache if file is provided
    if failed_uploads_file:
        load_failed_uploads(failed_uploads_file)

    truefoundry_chart_images = get_truefoundry_chart_images(manifest)
    if truefoundry_chart_images:
        logging.info(
            f"Found {len(truefoundry_chart_images)} images referenced by the truefoundry chart; these will be skipped during image upload"
        )

    if artifact_type == "image":
        image_list = [item for item in manifest if item["type"] == "image"]
        if image_list:
            pull_and_push_images(image_list, all_destinations, excluded_registries, excluded_images=truefoundry_chart_images)
    elif artifact_type == "helm":
        helm_list = [item for item in manifest if item["type"] == "helm"]
        if helm_list:
            download_and_push_helm_charts(helm_list, destination_registry)
    
    # Save image cache at the end
    if cache_file:
        save_image_cache()
    
    # Save failed uploads cache at the end
    if failed_uploads_file:
        save_failed_uploads()
