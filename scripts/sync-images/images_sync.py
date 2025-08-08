import sys
import yaml
import shlex
import argparse
import subprocess
import logging


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

def run(cmd):
    logging.info(f"Running: {cmd}")
    proc = subprocess.run(cmd, shell=True)
    if proc.returncode != 0:
        logging.error(f"Command failed with return code {proc.returncode}: {cmd}")
        raise SystemExit(proc.returncode)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--file", default="images.yaml")
    args = p.parse_args()

    with open(args.file, "r") as f:
        data = yaml.safe_load(f) or {}

    images = data.get("images", [])
    if not images:
        logging.warning(f"No images found in ${args.file}.")
        return 0

    for item in images:
        src = item["from"].strip()
        dst = item["to"].strip()

        run(f"skopeo copy --all docker://{shlex.quote(src)} docker://{shlex.quote(dst)}")
    logging.info("Done.")
    return 0

if __name__ == "__main__":
    sys.exit(main())