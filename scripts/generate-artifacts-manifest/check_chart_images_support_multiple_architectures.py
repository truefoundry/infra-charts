import json
import sys
import logging
from pathlib import Path


# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def load_json_file(file_path: str):
    """Load and return the contents of a JSON file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        logging.error(f"File not found at {file_path}")
        sys.exit(1)
    except json.JSONDecodeError:
        logging.error(f"Failed to decode JSON from {file_path}")
        sys.exit(1)


def parse_args(args):
    """Parse and validate command-line arguments."""
    if len(args) < 3:
        logging.error("Usage: python check_images_support_multi_architectures.py <artifacts_manifest_path> <whitelisted_images_path>")
        sys.exit(1)

    artifacts_manifest_path = args[1]
    whitelisted_images_path = args[2]

    # Validate that files exist
    if not Path(artifacts_manifest_path).is_file():
        logging.error(f"Artifacts manifest file not found at {artifacts_manifest_path}")
        sys.exit(1)
    if not Path(whitelisted_images_path).is_file():
        logging.error(f"Whitelisted images file not found at {whitelisted_images_path}")
        sys.exit(1)

    return artifacts_manifest_path, whitelisted_images_path


def get_truefoundry_chart_images(artifacts_manifest):
    """Extract the list of images associated with the 'truefoundry' chart."""
    for artifact in artifacts_manifest:
        if artifact.get("details", {}).get("chart") == "truefoundry":
            return artifact["details"].get("images", [])
    return []


def check_image_architectures(artifacts_manifest, truefoundry_chart_images, whitelisted_images):
    whitelisted_set = set(whitelisted_images)

    for artifact_image in artifacts_manifest:
        if artifact_image.get("type") == "image":
            image_url = artifact_image.get("details", {}).get("registryURL")

            # Skip images not in the truefoundry chart images list
            if image_url not in truefoundry_chart_images:
                continue

            platforms = artifact_image.get("details", {}).get("platforms", [])
            architectures = [p.get("architecture") for p in platforms if "architecture" in p]

            # Check architectures
            has_amd64 = "amd64" in architectures
            has_arm64 = "arm64" in architectures
            is_whitelisted = image_url in whitelisted_set

            if has_amd64 and has_arm64:
                pass
            else:
                # If the image is not multi-arch and not whitelisted
                if not is_whitelisted:
                    if not has_amd64:
                        logging.error(f"Image {image_url} does not support amd64 architecture. Exiting ...")
                    if not has_arm64:
                        logging.error(f"Image {image_url} does not support arm64 architecture. Exiting ...")
                    sys.exit(1)


def main():
    artifacts_manifest_path, whitelisted_images_path = parse_args(sys.argv)

    artifacts_manifest = load_json_file(artifacts_manifest_path)
    whitelisted_images = load_json_file(whitelisted_images_path)

    truefoundry_chart_images = get_truefoundry_chart_images(artifacts_manifest)
    check_image_architectures(artifacts_manifest, truefoundry_chart_images, whitelisted_images)

    logging.info("All images in the truefoundry chart support both arm64 and amd64 architectures.")


if __name__ == "__main__":
    main()
