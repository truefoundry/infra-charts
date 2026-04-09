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

SOURCE_TRUEFOUNDRY_CHART_REF = "oci://tfy.jfrog.io/tfy-helm/truefoundry"


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


def run_secret(cmd: List[str], check: bool = True) -> subprocess.CompletedProcess:
    proc = subprocess.run(cmd, text=True, capture_output=True)
    if check and proc.returncode != 0:
        if proc.stdout:
            print(proc.stdout, end="")
        if proc.stderr:
            print(proc.stderr, end="", file=sys.stderr)
        raise RuntimeError(f"Sensitive command failed ({proc.returncode}): {cmd[0]}")
    return proc


def parse_manifest(path: str) -> Tuple[str, Set[str]]:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for item in data:
        if item.get("type") != "helm":
            continue
        details = item.get("details", {})
        if details.get("chart") != "truefoundry":
            continue

        version = details.get("targetRevision", "").strip()
        images = {img for img in details.get("images", []) if isinstance(img, str) and img.strip()}
        if not version:
            raise ValueError(f"Invalid truefoundry entry in {path}: missing targetRevision")
        return version, images

    raise ValueError(f"No truefoundry helm entry found in {path}")


def chart_exists_on_quay(version: str, quay_repo: str) -> bool:
    chart_ref = f"oci://{quay_repo}/truefoundry"
    proc = run(
        ["helm", "pull", chart_ref, "--version", version, "--destination", tempfile.gettempdir()],
        check=False,
    )
    return proc.returncode == 0


def get_env_or_raise(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


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


def get_images_to_mirror(images_from_manifest: Iterable[str]) -> List[Tuple[str, str]]:
    src_images = sorted({img.strip() for img in images_from_manifest if img.startswith("tfy.jfrog.io/")})
    return [(src, src.replace("tfy.jfrog.io/", "quay.io/", 1)) for src in src_images]


def mirror_images(images_from_manifest: Iterable[str]) -> int:
    src_user = get_env_or_raise("JFROG_IMAGES_USERNAME")
    src_pass = get_env_or_raise("JFROG_IMAGES_PASSWORD")

    to_mirror = get_images_to_mirror(images_from_manifest)
    if not to_mirror:
        print("No tfy.jfrog.io images found in manifest for mirroring.")
        return 0

    mirrored = 0
    for src, dst in to_mirror:
        dst_user, dst_pass = get_quay_destination_creds(dst)
        print(f"Mirroring image {src} -> {dst}")
        run_secret(
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
        mirrored += 1
    return mirrored


def pull_chart(version: str, chart_name: str, destination: str) -> pathlib.Path:
    run(["helm", "pull", SOURCE_TRUEFOUNDRY_CHART_REF, "--version", version, "--destination", destination])

    archive = pathlib.Path(destination) / f"{chart_name}-{version}.tgz"
    if not archive.exists():
        raise FileNotFoundError(f"Pulled chart archive not found: {archive}")
    return archive


def replace_content(chart_root: pathlib.Path, images_from_manifest: Iterable[str]) -> int:
    replacements: Dict[str, str] = {}
    for image in images_from_manifest:
        if "tfy.jfrog.io/" in image:
            replacements[image] = image.replace("tfy.jfrog.io/", "quay.io/", 1)

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
        updated = updated.replace("tfy.jfrog.io/", "quay.io/")

        if updated != original:
            path.write_text(updated, encoding="utf-8")
            files_touched += 1

    return files_touched


def package_and_push(chart_root: pathlib.Path, quay_repo: str) -> None:
    run(["helm", "package", "."], cwd=str(chart_root))

    chart_yaml = chart_root / "Chart.yaml"
    with chart_yaml.open("r", encoding="utf-8") as f:
        lines = f.readlines()
    name = ""
    version = ""
    for line in lines:
        if line.startswith("name:"):
            name = line.split(":", 1)[1].strip()
        if line.startswith("version:"):
            version = line.split(":", 1)[1].strip()
    if not name or not version:
        raise RuntimeError("Unable to parse chart name/version from Chart.yaml")

    pkg = chart_root / f"{name}-{version}.tgz"
    if not pkg.exists():
        raise FileNotFoundError(f"Chart package missing: {pkg}")

    run(["helm", "push", str(pkg), f"oci://{quay_repo}"])


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Pull truefoundry chart from changed manifests, rewrite tfy.jfrog.io->quay.io, and push to quay."
    )
    parser.add_argument("--manifests", nargs="+", required=True, help="Changed artifacts-manifest.json file paths")
    parser.add_argument("--quay-repo", default="quay.io/tfy-helm", help="Target OCI repo for helm push")
    parser.add_argument(
        "--skip-image-mirroring",
        action="store_true",
        help="Skip mirroring tfy.jfrog.io images to quay.io",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print source and destination image mappings only; do not mirror or push charts.",
    )
    args = parser.parse_args()

    work_items: Set[str] = set()
    images_by_item: Dict[str, Set[str]] = {}
    all_images: Set[str] = set()

    for manifest in args.manifests:
        version, images = parse_manifest(manifest)
        work_items.add(version)
        images_by_item.setdefault(version, set()).update(images)
        all_images.update(images)
        print(f"Found truefoundry chart in {manifest}: source={SOURCE_TRUEFOUNDRY_CHART_REF}, version={version}")

    if args.dry_run:
        mappings = get_images_to_mirror(all_images)
        if not mappings:
            print("No tfy.jfrog.io images found in manifests.")
            return 0
        print("Dry run mode: source -> destination image mappings")
        for src, dst in mappings:
            print(f"{src} -> {dst}")
        return 0

    if not args.skip_image_mirroring:
        mirrored = mirror_images(all_images)
        print(f"Mirrored {mirrored} images to quay.io")

    for version in sorted(work_items):
        if chart_exists_on_quay(version=version, quay_repo=args.quay_repo):
            print(f"truefoundry:{version} already exists in {args.quay_repo}, skipping")
            continue

        with tempfile.TemporaryDirectory(prefix="tfy-quay-release-") as tmp:
            archive = pull_chart(version=version, chart_name="truefoundry", destination=tmp)
            extracted = pathlib.Path(tmp) / "chart"
            extracted.mkdir(parents=True, exist_ok=True)
            with tarfile.open(archive, "r:gz") as tf:
                tf.extractall(path=extracted)

            chart_root = extracted / "truefoundry"
            if not chart_root.exists():
                raise FileNotFoundError(f"Extracted chart directory missing: {chart_root}")

            files_touched = replace_content(
                chart_root=chart_root,
                images_from_manifest=images_by_item.get(version, set()),
            )
            print(f"Updated {files_touched} files for truefoundry:{version}")
            package_and_push(chart_root=chart_root, quay_repo=args.quay_repo)
            print(f"Pushed truefoundry:{version} to oci://{args.quay_repo}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
