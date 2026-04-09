#!/usr/bin/env python3
import argparse
import json
import os
import pathlib
import subprocess
import sys
import tarfile
import tempfile
from typing import Dict, Iterable, List, Set, Tuple

SUPPORTED_CHARTS = {"truefoundry", "tfy-llm-gateway", "tfy-otel-collector"}
SOURCE_HELM_REPO = "oci://tfy.jfrog.io/tfy-helm"
TARGET_HELM_REPO = "oci://quay.io/tfy-helm"


def get_env_or_raise(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def run(cmd: List[str], cwd: str | None = None, check: bool = True) -> subprocess.CompletedProcess:
    print(f"+ {' '.join(cmd)}")
    proc = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    if proc.stdout:
        print(proc.stdout, end="")
    if proc.stderr:
        print(proc.stderr, end="", file=sys.stderr)
    if check and proc.returncode != 0:
        raise RuntimeError(f"Command failed ({proc.returncode}): {' '.join(cmd)}")
    return proc


def get_quay_destination_creds(image: str) -> Tuple[str, str]:
    if not image.startswith("quay.io/"):
        raise ValueError(f"Unsupported destination image registry: {image}")
    parts = image.split("/")
    if len(parts) < 2:
        raise ValueError(f"Invalid destination image path: {image}")

    org = parts[1]
    if org == "tfy-private-images":
        return get_env_or_raise("QUAY_PRIVATE_IMAGES_USERNAME"), get_env_or_raise("QUAY_PRIVATE_IMAGES_PASSWORD")
    if org == "tfy-images":
        return get_env_or_raise("QUAY_IMAGES_USERNAME"), get_env_or_raise("QUAY_IMAGES_PASSWORD")
    if org == "tfy-mirror":
        return get_env_or_raise("QUAY_MIRROR_USERNAME"), get_env_or_raise("QUAY_MIRROR_PASSWORD")
    if org == "tfy-helm":
        return get_env_or_raise("QUAY_HELM_USERNAME"), get_env_or_raise("QUAY_HELM_PASSWORD")

    return get_env_or_raise("QUAY_HELM_USERNAME"), get_env_or_raise("QUAY_HELM_PASSWORD")


def parse_manifest(path: str) -> Tuple[Set[str], Dict[str, Set[str]]]:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    images: Set[str] = set()
    chart_versions: Dict[str, Set[str]] = {chart: set() for chart in SUPPORTED_CHARTS}
    for item in data:
        if item.get("type") != "helm":
            continue
        details = item.get("details", {})
        chart_name = details.get("chart")
        if chart_name not in SUPPORTED_CHARTS:
            continue

        version = str(details.get("targetRevision", "")).strip()
        if version:
            chart_versions[chart_name].add(version)

        for image in details.get("images", []):
            if isinstance(image, str) and image.startswith("tfy.jfrog.io/"):
                images.add(image.strip())

    return images, chart_versions


def get_image_mappings(images: Iterable[str]) -> List[Tuple[str, str]]:
    src_images = sorted({img.strip() for img in images if img.startswith("tfy.jfrog.io/")})
    return [(src, src.replace("tfy.jfrog.io/", "quay.io/", 1)) for src in src_images]


def image_exists_on_quay(image: str) -> bool:
    username, password = get_quay_destination_creds(image)
    proc = run(
        ["skopeo", "inspect", "--creds", f"{username}:{password}", f"docker://{image}"],
        check=False,
    )
    return proc.returncode == 0


def mirror_images(images: Iterable[str]) -> int:
    src_user = get_env_or_raise("JFROG_IMAGES_USERNAME")
    src_pass = get_env_or_raise("JFROG_IMAGES_PASSWORD")

    mappings = get_image_mappings(images)
    mirrored = 0
    for src, dst in mappings:
        if image_exists_on_quay(dst):
            print(f"[SKIP] Image already exists: {dst}")
            continue

        dst_user, dst_pass = get_quay_destination_creds(dst)
        run(
            [
                "skopeo",
                "copy",
                "--all",
                "--retry-times",
                "3",
                "--src-creds",
                f"{src_user}:{src_pass}",
                "--dest-creds",
                f"{dst_user}:{dst_pass}",
                f"docker://{src}",
                f"docker://{dst}",
            ]
        )
        print(f"[PUSH] Image pushed: {dst}")
        mirrored += 1
    return mirrored


def helm_chart_exists_on_target(chart_name: str, version: str) -> bool:
    target_ref = f"{TARGET_HELM_REPO}/{chart_name}"
    proc = run(
        ["helm", "pull", target_ref, "--version", version, "--destination", tempfile.gettempdir()],
        check=False,
    )
    return proc.returncode == 0


def pull_chart(chart_name: str, version: str, destination: str) -> pathlib.Path:
    source_ref = f"{SOURCE_HELM_REPO}/{chart_name}"
    run(["helm", "pull", source_ref, "--version", version, "--destination", destination])
    archive = pathlib.Path(destination) / f"{chart_name}-{version}.tgz"
    if not archive.exists():
        raise FileNotFoundError(f"Pulled chart archive not found: {archive}")
    return archive


def rewrite_helm_repo_refs(chart_root: pathlib.Path) -> int:
    replacements = {
        "oci://tfy.jfrog.io/tfy-helm/truefoundry": "oci://quay.io/tfy-helm/truefoundry",
        "oci://tfy.jfrog.io/tfy-helm/tfy-llm-gateway": "oci://quay.io/tfy-helm/tfy-llm-gateway",
        "oci://tfy.jfrog.io/tfy-helm/tfy-otel-collector": "oci://quay.io/tfy-helm/tfy-otel-collector",
    }
    files_touched = 0
    for path in chart_root.rglob("*"):
        if not path.is_file():
            continue
        try:
            original = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        updated = original
        for src, dst in replacements.items():
            updated = updated.replace(src, dst)

        if updated != original:
            path.write_text(updated, encoding="utf-8")
            files_touched += 1
    return files_touched


def package_and_push(chart_root: pathlib.Path, chart_name: str, version: str) -> None:
    run(["helm", "package", "."], cwd=str(chart_root))
    package = chart_root / f"{chart_name}-{version}.tgz"
    if not package.exists():
        raise FileNotFoundError(f"Chart package missing: {package}")
    run(["helm", "push", str(package), TARGET_HELM_REPO])


def sync_helm_charts(chart_versions: Dict[str, Set[str]], dry_run: bool) -> None:
    for chart_name in sorted(SUPPORTED_CHARTS):
        for version in sorted(chart_versions.get(chart_name, set())):
            source_ref = f"{SOURCE_HELM_REPO}/{chart_name}:{version}"
            target_ref = f"{TARGET_HELM_REPO}/{chart_name}:{version}"
            print(f"Helm chart mapping {source_ref} -> {target_ref}")
            if dry_run:
                continue
            if helm_chart_exists_on_target(chart_name=chart_name, version=version):
                print(f"[SKIP] Helm chart already exists: {target_ref}")
                continue

            with tempfile.TemporaryDirectory(prefix=f"{chart_name}-sync-") as tmp:
                archive = pull_chart(chart_name=chart_name, version=version, destination=tmp)
                extracted = pathlib.Path(tmp) / "chart"
                extracted.mkdir(parents=True, exist_ok=True)
                with tarfile.open(archive, "r:gz") as tf:
                    tf.extractall(path=extracted)

                chart_root = extracted / chart_name
                if not chart_root.exists():
                    raise FileNotFoundError(f"Extracted chart directory missing: {chart_root}")

                touched = rewrite_helm_repo_refs(chart_root)
                print(f"Updated {touched} files for {chart_name}:{version}")
                package_and_push(chart_root=chart_root, chart_name=chart_name, version=version)
                print(f"[PUSH] Helm chart pushed: {target_ref}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Mirror images and sync helm charts for truefoundry and tfy-llm-gateway from JFrog to Quay."
    )
    parser.add_argument("--manifests", nargs="+", required=True, help="artifacts-manifest.json paths")
    parser.add_argument("--dry-run", action="store_true", help="Print mappings only; skip skopeo and helm push")
    parser.add_argument("--skip-image-mirroring", action="store_true", help="Skip image mirroring")
    parser.add_argument("--skip-helm-sync", action="store_true", help="Skip helm chart sync")
    args = parser.parse_args()

    all_images: Set[str] = set()
    chart_versions: Dict[str, Set[str]] = {chart: set() for chart in SUPPORTED_CHARTS}

    for manifest in args.manifests:
        manifest_images, manifest_chart_versions = parse_manifest(manifest)
        all_images.update(manifest_images)
        for chart_name, versions in manifest_chart_versions.items():
            chart_versions[chart_name].update(versions)
        print(
            f"Collected {len(manifest_images)} images and "
            f"{sum(len(v) for v in manifest_chart_versions.values())} chart versions from {manifest}"
        )

    image_mappings = get_image_mappings(all_images)
    if image_mappings:
        print("Source -> Destination image mappings")
        for src, dst in image_mappings:
            print(f"{src} -> {dst}")
    else:
        print("No tfy.jfrog.io images found for truefoundry/tfy-llm-gateway.")

    if not args.skip_image_mirroring and not args.dry_run and image_mappings:
        mirrored = mirror_images(all_images)
        print(f"Mirrored {mirrored} images.")
    elif args.skip_image_mirroring:
        print("Skipping image mirroring by flag.")
    elif args.dry_run:
        print("Dry run enabled: skipping skopeo copy.")

    if not args.skip_helm_sync:
        sync_helm_charts(chart_versions=chart_versions, dry_run=args.dry_run)
    else:
        print("Skipping helm sync by flag.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
