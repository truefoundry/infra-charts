import importlib.util
from pathlib import Path
import unittest


SCRIPT_PATH = Path(__file__).with_name("check_chart_images_support_multiple_architectures.py")
SPEC = importlib.util.spec_from_file_location("multi_arch_check", SCRIPT_PATH)
multi_arch_check = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(multi_arch_check)


class CheckChartImagesSupportMultipleArchitecturesTest(unittest.TestCase):
    def test_collects_tfy_llm_gateway_images(self):
        artifacts_manifest = [
            {
                "type": "helm",
                "details": {
                    "chart": "tfy-llm-gateway",
                    "images": ["example.com/tfy-llm-gateway:v1"],
                },
            }
        ]

        chart_images = multi_arch_check.get_validated_chart_images(artifacts_manifest)

        self.assertEqual(chart_images, ["example.com/tfy-llm-gateway:v1"])

    def test_collects_images_from_all_validated_charts(self):
        artifacts_manifest = [
            {
                "type": "helm",
                "details": {"chart": "elasti", "images": ["example.com/elasti:v1"]},
            },
            {
                "type": "helm",
                "details": {"chart": "truefoundry", "images": ["example.com/truefoundry:v1"]},
            },
            {
                "type": "helm",
                "details": {"chart": "unsupported", "images": ["example.com/unsupported:v1"]},
            },
        ]

        chart_images = multi_arch_check.get_validated_chart_images(artifacts_manifest)

        self.assertEqual(
            chart_images,
            ["example.com/elasti:v1", "example.com/truefoundry:v1"],
        )

    def test_fails_when_gateway_image_missing_arm64(self):
        artifacts_manifest = [
            {
                "type": "helm",
                "details": {
                    "chart": "tfy-llm-gateway",
                    "images": ["example.com/tfy-llm-gateway:v1"],
                },
            },
            {
                "type": "image",
                "details": {
                    "registryURL": "example.com/tfy-llm-gateway:v1",
                    "platforms": [{"os": "linux", "architecture": "amd64"}],
                },
            },
        ]
        chart_images = multi_arch_check.get_validated_chart_images(artifacts_manifest)

        with self.assertRaises(SystemExit) as exit_context:
            multi_arch_check.check_image_architectures(artifacts_manifest, chart_images, [])

        self.assertEqual(exit_context.exception.code, 1)


if __name__ == "__main__":
    unittest.main()
