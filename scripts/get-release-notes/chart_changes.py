import json
import os
import re
import requests
import argparse
from typing import Dict, List, Optional

# Read GitHub token from env
TFY_GITHUB_TOKEN = os.getenv("TFY_GITHUB_TOKEN", "")
if not TFY_GITHUB_TOKEN:
    raise EnvironmentError("❌ TFY_GITHUB_TOKEN not set in environment variables")

GITHUB_API_HEADERS = {
    "Accept": "application/vnd.github+json",
    "Authorization": f"Bearer {TFY_GITHUB_TOKEN}"
}

image_repo_mapping = {
    "tfy-workflow-admin": "tfy-flyte",
    "spark-history-server": "spark",
}


def extract_truefoundry_images(manifest: List[dict]) -> List[str]:
    for item in manifest:
        if item.get("type") == "helm" and item.get("details", {}).get("chart") == "truefoundry":
            return item["details"].get("images", [])
    return []


def map_images_by_name(images: List[str]) -> Dict[str, str]:
    image_map: Dict[str, str] = {}
    for image in images:
        if ":" not in image:
            print(f"⚠️ Skipping malformed image: {image}")
            continue
        path, tag = image.rsplit(":", 1)
        name = path.split("/")[-1]
        image_map[name] = tag
    return image_map


def compare_image_tags(old_json_path: str, new_json_path: str) -> List[Dict[str, str]]:
    with open(old_json_path) as f1, open(new_json_path) as f2:
        old_manifest = json.load(f1)
        new_manifest = json.load(f2)

    old_images = extract_truefoundry_images(old_manifest)
    new_images = extract_truefoundry_images(new_manifest)

    old_map = map_images_by_name(old_images)
    new_map = map_images_by_name(new_images)

    changes: List[Dict[str, str]] = []
    for name, new_tag in new_map.items():
        old_tag = old_map.get(name)
        if old_tag and old_tag != new_tag:
            changes.append({
                "image": name,
                "old_tag": old_tag,
                "new_tag": new_tag
            })
    return changes


def get_commits(repo: str, old_tag: str, new_tag: str) -> List[dict]:
    url = f"https://api.github.com/repos/truefoundry/{repo}/compare/{old_tag}...{new_tag}"
    try:
        resp = requests.get(url, headers=GITHUB_API_HEADERS)
        resp.raise_for_status()
        return resp.json().get("commits", [])
    except requests.RequestException as e:
        print(f"❌ Failed to get commits for {repo}: {e}")
        return []


def extract_pr_number(message: str) -> Optional[str]:
    match = re.search(r"\(#(\d+)\)|(?:Merge pull request #(\d+) from)", message)
    return match.group(1) or match.group(2) if match else None


def enrich_commit(commit: dict, repo: str) -> Dict:
    commit_info = {
        "author": commit.get("commit", {}).get("author", {}),
        "message": commit.get("commit", {}).get("message", ""),
        "commit_url": commit.get("html_url", ""),
        "pull_request": ""
    }
    pr_num = extract_pr_number(commit_info["message"])
    if pr_num:
        commit_info["pull_request"] = f"https://github.com/truefoundry/{repo}/pull/{pr_num}"
    return commit_info


def generate_changelog(changes: List[Dict[str, str]]) -> Dict[str, List[Dict]]:
    changelog: Dict[str, List[Dict]] = {}
    for entry in changes:
        repo = entry["image"]
        old_tag = entry["old_tag"]
        new_tag = entry["new_tag"]

        if repo in image_repo_mapping:
            repo = image_repo_mapping[repo]

        print(f"🔍 Fetching commits for {repo}: {old_tag} → {new_tag}")
        commits = get_commits(repo, old_tag, new_tag)

        changelog[repo] = [enrich_commit(commit, repo) for commit in commits]

    return changelog


def write_json(data: dict, filename: str) -> None:
    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"✅ Saved changelog to {filename}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Compare image tags and get changelogs from truefoundry manifests."
    )
    parser.add_argument("old_manifest", help="Path to old artifacts-manifest.json")
    parser.add_argument("new_manifest", help="Path to new artifacts-manifest.json")
    parser.add_argument("--output", default="changelog.json", help="Output changelog JSON file (default: changelog.json)")
    parser.add_argument("--version", "-v", required=True, help="Version key to wrap the changelog JSON under")

    args = parser.parse_args()

    image_changes = compare_image_tags(args.old_manifest, args.new_manifest)
    print("📦 Changed images:")
    print(json.dumps(image_changes, indent=2))

    changelog = generate_changelog(image_changes)
    # Wrap the result under the version key
    output_data = {args.version: changelog}
    write_json(output_data, args.output)