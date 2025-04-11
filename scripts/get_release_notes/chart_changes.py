import os
import re
import requests
import sys

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
OWNER = "truefoundry"
REPO = "infra-charts"
TARGET_FILE = "charts/tfy-k8s-aws-eks-inframold/artifacts-manifest.json"

def extract_target_revision(diff_path):
    with open(diff_path, "r") as f:
        lines = f.readlines()

    is_truefoundry = False
    old_version, new_version = None, None

    for line in lines:
        line = line.strip()

        if '"chart": "truefoundry"' in line:
            is_truefoundry = True
            continue

        if is_truefoundry and '"chart":' in line and '"chart": "truefoundry"' not in line:
            is_truefoundry = False

        if is_truefoundry and "targetRevision" in line:
            if line.startswith("-"):
                match = re.search(r'"targetRevision":\s*"([^"]+)"', line)
                if match:
                    old_version = match.group(1)
            elif line.startswith("+"):
                match = re.search(r'"targetRevision":\s*"([^"]+)"', line)
                if match:
                    new_version = match.group(1)

    if old_version and new_version and old_version != new_version:
        print(f"::set-output name=changed::true")
        print(f"::set-output name=old_version::{old_version}")
        print(f"::set-output name=new_version::{new_version}")
        return old_version, new_version
    else:
        print(f"::set-output name=changed::false")
        return None, None

def fetch_diff_from_github(base, head):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/compare/truefoundry-{base}...truefoundry-{head}"
    headers = {"Authorization": f"Bearer {GITHUB_TOKEN}"}

    response = requests.get(url, headers=headers)
    response.raise_for_status()
    data = response.json()

    for file in data.get("files", []):
        if file["filename"] == TARGET_FILE:
            return file["patch"]

    print("No diff found for artifacts-manifest.")
    return ""

def parse_image_changes(diff):
    image_changes = {}
    old_images = {}
    new_images = {}

    for line in diff.splitlines():
        line = line.strip()
        if line.startswith("-") and "registryURL" in line:
            match = re.search(r'"registryURL":\s*"([^"]+)"', line)
            if match:
                image = match.group(1)
                path, old_tag = image.rsplit(":", 1)
                name = path.split("/")[-1]
                old_images[name] = old_tag

        if line.startswith("+") and "registryURL" in line:
            match = re.search(r'"registryURL":\s*"([^"]+)"', line)
            if match:
                image = match.group(1)
                path, new_tag = image.rsplit(":", 1)
                name = path.split("/")[-1]
                new_images[name] = new_tag

    for name in new_images:
        if name in old_images and old_images[name] != new_images[name]:
            image_changes[name] = {
                "old_tag": old_images[name],
                "new_tag": new_images[name]
            }

    result = [{"image": name, **tags} for name, tags in image_changes.items()]
    print("Changed images:")
    print(result)
    return result

if __name__ == "__main__":
    diff_path = sys.argv[1] if len(sys.argv) > 1 else "diff.patch"
    base, head = extract_target_revision(diff_path)

    if base and head:
        print(f"Comparing {base} to {head}")
        diff = fetch_diff_from_github(base, head)
        parse_image_changes(diff)