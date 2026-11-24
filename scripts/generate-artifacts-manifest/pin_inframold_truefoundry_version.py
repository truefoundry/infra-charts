#!/usr/bin/env python3
"""Pin inframold truefoundry targetRevision and sync artifacts-manifest images.

When cutting ``release/truefoundry-X.Y.Z``, the branch is forked from main and
only the truefoundry chart is bumped. Inframold would otherwise keep main's
latest ``targetRevision`` and ``artifacts-manifest.json`` (wrong CP images for
airgap/upgrade tooling that reads inframold manifests from the release branch).

This script:
  1. Sets ``targetRevision: X.Y.Z`` in every inframold ``templates/truefoundry.yaml``
  2. Replaces the truefoundry helm entry + its top-level image rows in each
     inframold ``artifacts-manifest.json`` with images from the local
     ``charts/truefoundry/artifacts-manifest.json``

It does **not** bump inframold ``Chart.yaml`` versions — published inframold
charts stay released from main; only the git tree on the release branch is
corrected for version-X lookups.

Usage:
  # Apply pin using charts/truefoundry/Chart.yaml version
  python pin_inframold_truefoundry_version.py

  # Apply pin for an explicit version
  python pin_inframold_truefoundry_version.py --version 0.179.30

  # Exit non-zero if already mismatched (CI guardrail)
  python pin_inframold_truefoundry_version.py --check
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

INFRAMOLD_CHARTS = (
    "tfy-k8s-aws-eks-inframold",
    "tfy-k8s-azure-aks-inframold",
    "tfy-k8s-civo-talos-inframold",
    "tfy-k8s-gcp-gke-standard-inframold",
    "tfy-k8s-generic-inframold",
)

_TARGET_REVISION_RE = re.compile(
    r"^(\s*targetRevision:\s*)\S+(\s*)$",
    re.MULTILINE,
)
_CHART_VERSION_RE = re.compile(r"^version:\s*[\"']?([^\"'\s#]+)", re.MULTILINE)


def _repo_root(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit).resolve()
    # scripts/generate-artifacts-manifest/<this file> → repo root
    return Path(__file__).resolve().parents[2]


def read_truefoundry_version(root: Path) -> str:
    chart_yaml = root / "charts" / "truefoundry" / "Chart.yaml"
    text = chart_yaml.read_text()
    match = _CHART_VERSION_RE.search(text)
    if not match:
        raise RuntimeError(f"could not parse version from {chart_yaml}")
    return match.group(1).strip()


def read_truefoundry_images(root: Path) -> tuple[list[str], list[dict]]:
    """Return (image_urls, image_entries) from charts/truefoundry/artifacts-manifest.json."""
    path = root / "charts" / "truefoundry" / "artifacts-manifest.json"
    data = json.loads(path.read_text())
    urls: list[str] = []
    entries: list[dict] = []
    seen: set[str] = set()

    # Prefer the helm entry's images list (canonical order), then fill gaps
    # from top-level image rows (which carry platforms).
    helm_urls: list[str] = []
    for item in data:
        if item.get("type") == "helm" and item.get("details", {}).get("chart") == "truefoundry":
            helm_urls = list(item["details"].get("images") or [])
            break

    by_url: dict[str, dict] = {}
    for item in data:
        if item.get("type") != "image":
            continue
        url = item.get("details", {}).get("registryURL")
        if isinstance(url, str) and url:
            by_url[url] = item

    ordered = helm_urls or list(by_url.keys())
    for url in ordered:
        if url in seen:
            continue
        seen.add(url)
        urls.append(url)
        if url in by_url:
            entries.append(by_url[url])
        else:
            entries.append(
                {
                    "type": "image",
                    "details": {"registryURL": url, "platforms": []},
                }
            )

    # Any image rows not listed on the helm entry (should be rare)
    for url, item in by_url.items():
        if url not in seen:
            seen.add(url)
            urls.append(url)
            entries.append(item)

    if not urls:
        raise RuntimeError(f"no images found in {path}")
    return urls, entries


def pin_template(path: Path, version: str) -> bool:
    text = path.read_text()
    new_text, count = _TARGET_REVISION_RE.subn(rf"\g<1>{version}\2", text, count=1)
    if count != 1:
        raise RuntimeError(f"{path}: expected exactly one targetRevision line, found {count}")
    if new_text == text:
        return False
    path.write_text(new_text)
    return True


def _truefoundry_helm_entry(manifest: list) -> dict:
    for item in manifest:
        if item.get("type") == "helm" and item.get("details", {}).get("chart") == "truefoundry":
            return item
    raise RuntimeError("artifacts-manifest.json missing helm entry for chart 'truefoundry'")


def sync_artifacts_manifest(
    path: Path,
    version: str,
    image_urls: list[str],
    image_entries: list[dict],
) -> bool:
    manifest = json.loads(path.read_text())
    helm = _truefoundry_helm_entry(manifest)
    old_urls = set(helm.get("details", {}).get("images") or [])
    new_urls = set(image_urls)

    # Drop top-level image rows that belonged only to the previous truefoundry set
    referenced_elsewhere: set[str] = set()
    for item in manifest:
        if item.get("type") != "helm":
            continue
        if item.get("details", {}).get("chart") == "truefoundry":
            continue
        for url in item.get("details", {}).get("images") or []:
            referenced_elsewhere.add(url)

    kept: list = []
    for item in manifest:
        if item.get("type") != "image":
            kept.append(item)
            continue
        url = item.get("details", {}).get("registryURL")
        if url in old_urls and url not in new_urls and url not in referenced_elsewhere:
            continue
        kept.append(item)

    # Ensure every new truefoundry image has a top-level row (preserve platforms)
    existing_urls = {
        item.get("details", {}).get("registryURL")
        for item in kept
        if item.get("type") == "image"
    }
    entry_by_url = {
        e["details"]["registryURL"]: e for e in image_entries if e.get("type") == "image"
    }
    for url in image_urls:
        if url in existing_urls:
            continue
        kept.append(entry_by_url.get(url) or {
            "type": "image",
            "details": {"registryURL": url, "platforms": []},
        })

    helm["details"]["targetRevision"] = version
    helm["details"]["images"] = list(image_urls)

    new_blob = json.dumps(kept, indent=4) + "\n"
    old_blob = path.read_text()
    # Normalize prior file to compare structurally via reload
    if json.loads(old_blob) == kept:
        return False
    path.write_text(new_blob)
    return True


def collect_mismatches(
    root: Path,
    version: str,
    image_urls: list[str],
) -> list[str]:
    problems: list[str] = []
    expected_sfy = None
    for url in image_urls:
        if "servicefoundry-server:" in url:
            expected_sfy = url
            break

    for chart in INFRAMOLD_CHARTS:
        template = root / "charts" / chart / "templates" / "truefoundry.yaml"
        if not template.exists():
            problems.append(f"missing {template.relative_to(root)}")
            continue
        match = _TARGET_REVISION_RE.search(template.read_text())
        if not match:
            problems.append(f"{template.relative_to(root)}: no targetRevision")
        else:
            # group 0 is full match; extract value
            current = re.search(r"targetRevision:\s*(\S+)", match.group(0))
            cur_ver = current.group(1) if current else ""
            if cur_ver != version:
                problems.append(
                    f"{template.relative_to(root)}: targetRevision={cur_ver!r}, want {version!r}"
                )

        manifest_path = root / "charts" / chart / "artifacts-manifest.json"
        if not manifest_path.exists():
            problems.append(f"missing {manifest_path.relative_to(root)}")
            continue
        manifest = json.loads(manifest_path.read_text())
        try:
            helm = _truefoundry_helm_entry(manifest)
        except RuntimeError as exc:
            problems.append(f"{manifest_path.relative_to(root)}: {exc}")
            continue
        got_rev = helm.get("details", {}).get("targetRevision")
        if got_rev != version:
            problems.append(
                f"{manifest_path.relative_to(root)}: truefoundry targetRevision="
                f"{got_rev!r}, want {version!r}"
            )
        got_images = list(helm.get("details", {}).get("images") or [])
        if got_images != list(image_urls):
            problems.append(
                f"{manifest_path.relative_to(root)}: truefoundry images differ from "
                f"charts/truefoundry/artifacts-manifest.json "
                f"(manifest has {len(got_images)}, truefoundry chart has {len(image_urls)})"
            )
        if expected_sfy:
            top_level = {
                i.get("details", {}).get("registryURL")
                for i in manifest
                if i.get("type") == "image"
            }
            if expected_sfy not in top_level and expected_sfy not in got_images:
                problems.append(
                    f"{manifest_path.relative_to(root)}: missing {expected_sfy}"
                )
            # Fail loudly if a different servicefoundry-server tag is present
            for url in top_level | set(got_images):
                if isinstance(url, str) and "servicefoundry-server:" in url and url != expected_sfy:
                    problems.append(
                        f"{manifest_path.relative_to(root)}: unexpected {url}, want {expected_sfy}"
                    )
    return problems


def apply(root: Path, version: str) -> list[str]:
    image_urls, image_entries = read_truefoundry_images(root)
    changed: list[str] = []
    for chart in INFRAMOLD_CHARTS:
        template = root / "charts" / chart / "templates" / "truefoundry.yaml"
        if pin_template(template, version):
            changed.append(str(template.relative_to(root)))
        manifest_path = root / "charts" / chart / "artifacts-manifest.json"
        if sync_artifacts_manifest(manifest_path, version, image_urls, image_entries):
            changed.append(str(manifest_path.relative_to(root)))
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=None, help="infra-charts repo root")
    parser.add_argument(
        "--version",
        default=None,
        help="truefoundry chart version to pin (default: charts/truefoundry/Chart.yaml)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="only verify; exit 1 if inframold is not pinned to the truefoundry version",
    )
    args = parser.parse_args()
    root = _repo_root(args.root)
    version = (args.version or read_truefoundry_version(root)).strip().lstrip("v")
    if not version or re.search(r"\s", version):
        print(f"error: refusing version {version!r}", file=sys.stderr)
        return 1

    image_urls, _ = read_truefoundry_images(root)

    if args.check:
        problems = collect_mismatches(root, version, image_urls)
        if problems:
            print(
                f"inframold is not pinned to truefoundry {version}:",
                file=sys.stderr,
            )
            for problem in problems:
                print(f"  - {problem}", file=sys.stderr)
            return 1
        print(f"ok: inframold pinned to truefoundry {version}")
        return 0

    changed = apply(root, version)
    if changed:
        print(f"pinned inframold to truefoundry {version} ({len(changed)} files):")
        for path in changed:
            print(f"  {path}")
    else:
        print(f"already pinned to truefoundry {version}")

    # Re-check after apply so CI can rely on a single script
    problems = collect_mismatches(root, version, image_urls)
    if problems:
        print("error: pin completed but verification failed:", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
