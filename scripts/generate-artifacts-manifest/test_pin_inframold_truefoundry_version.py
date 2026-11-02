#!/usr/bin/env python3
"""Unit tests for pin_inframold_truefoundry_version.py"""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import pin_inframold_truefoundry_version as pin


def _write(path: Path, content: str | dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(content, dict) or isinstance(content, list):
        path.write_text(json.dumps(content, indent=4) + "\n")
    else:
        path.write_text(content)


def _scaffold(root: Path, *, tf_version: str, infra_version: str, sfy_tag: str) -> None:
    _write(
        root / "charts" / "truefoundry" / "Chart.yaml",
        f"apiVersion: v2\nname: truefoundry\nversion: {tf_version}\n",
    )
    tf_images = [
        f"tfy.jfrog.io/tfy-private-images/servicefoundry-server:{sfy_tag}",
        f"tfy.jfrog.io/tfy-private-images/mlfoundry-server:{sfy_tag}",
    ]
    _write(
        root / "charts" / "truefoundry" / "artifacts-manifest.json",
        [
            {
                "type": "helm",
                "details": {
                    "chart": "truefoundry",
                    "repoURL": "tfy.jfrog.io/tfy-helm",
                    "targetRevision": tf_version,
                    "images": tf_images,
                },
            },
            *[
                {
                    "type": "image",
                    "details": {
                        "registryURL": url,
                        "platforms": [{"os": "linux", "architecture": "amd64"}],
                    },
                }
                for url in tf_images
            ],
        ],
    )

    old_sfy = "tfy.jfrog.io/tfy-private-images/servicefoundry-server:v9.9.9"
    old_ml = "tfy.jfrog.io/tfy-private-images/mlfoundry-server:v9.9.9"
    for chart in pin.INFRAMOLD_CHARTS:
        _write(
            root / "charts" / chart / "templates" / "truefoundry.yaml",
            "apiVersion: argoproj.io/v1alpha1\n"
            "kind: Application\n"
            "spec:\n"
            "  source:\n"
            f"    targetRevision: {infra_version}\n"
            "    chart: truefoundry\n",
        )
        _write(
            root / "charts" / chart / "Chart.yaml",
            f"apiVersion: v2\nname: {chart}\nversion: 0.1.0\n",
        )
        _write(
            root / "charts" / chart / "artifacts-manifest.json",
            [
                {
                    "type": "helm",
                    "details": {
                        "chart": "truefoundry",
                        "repoURL": "tfy.jfrog.io/tfy-helm",
                        "targetRevision": infra_version,
                        "images": [old_sfy, old_ml],
                    },
                },
                {
                    "type": "helm",
                    "details": {
                        "chart": "cert-manager",
                        "repoURL": "https://example.com",
                        "targetRevision": "v1.0.0",
                        "images": ["quay.io/jetstack/cert-manager-controller:v1.0.0"],
                    },
                },
                {
                    "type": "image",
                    "details": {"registryURL": old_sfy, "platforms": []},
                },
                {
                    "type": "image",
                    "details": {"registryURL": old_ml, "platforms": []},
                },
                {
                    "type": "image",
                    "details": {
                        "registryURL": "quay.io/jetstack/cert-manager-controller:v1.0.0",
                        "platforms": [],
                    },
                },
            ],
        )


class PinInframoldTests(unittest.TestCase):
    def test_apply_and_check(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _scaffold(
                root,
                tf_version="0.179.30",
                infra_version="0.180.0",
                sfy_tag="v0.179.17",
            )

            problems = pin.collect_mismatches(
                root,
                "0.179.30",
                pin.read_truefoundry_images(root)[0],
            )
            self.assertTrue(problems)

            changed = pin.apply(root, "0.179.30")
            self.assertTrue(changed)

            problems = pin.collect_mismatches(
                root,
                "0.179.30",
                pin.read_truefoundry_images(root)[0],
            )
            self.assertEqual(problems, [])

            template = (
                root / "charts" / "tfy-k8s-generic-inframold" / "templates" / "truefoundry.yaml"
            ).read_text()
            self.assertIn("targetRevision: 0.179.30", template)

            manifest = json.loads(
                (
                    root
                    / "charts"
                    / "tfy-k8s-generic-inframold"
                    / "artifacts-manifest.json"
                ).read_text()
            )
            helm = pin._truefoundry_helm_entry(manifest)
            self.assertEqual(helm["details"]["targetRevision"], "0.179.30")
            self.assertEqual(
                helm["details"]["images"][0],
                "tfy.jfrog.io/tfy-private-images/servicefoundry-server:v0.179.17",
            )
            urls = {
                i["details"]["registryURL"]
                for i in manifest
                if i.get("type") == "image"
            }
            self.assertIn(
                "tfy.jfrog.io/tfy-private-images/servicefoundry-server:v0.179.17",
                urls,
            )
            self.assertNotIn(
                "tfy.jfrog.io/tfy-private-images/servicefoundry-server:v9.9.9",
                urls,
            )
            # Unrelated addon image retained
            self.assertIn(
                "quay.io/jetstack/cert-manager-controller:v1.0.0",
                urls,
            )


if __name__ == "__main__":
    unittest.main()
