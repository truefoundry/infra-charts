import argparse, subprocess, sys, yaml, shlex

def run(cmd):
    print(f"+ {cmd}", flush=True)
    proc = subprocess.run(cmd, shell=True)
    if proc.returncode != 0:
        raise SystemExit(proc.returncode)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--file", default="images.yaml")
    args = p.parse_args()

    with open(args.file, "r") as f:
        data = yaml.safe_load(f) or {}

    images = data.get("images", [])
    if not images:
        print("No images found in images.yaml", file=sys.stderr)
        return 0

    for item in images:
        src = item["from"].strip()
        dst = item["to"].strip()

        # # 1) Copy all platforms/variants with skopeo
        #    (ensures blobs exist at destination)
        run(f"skopeo copy --all docker://{shlex.quote(src)} docker://{shlex.quote(dst)}")

        # 2) Recreate a multi-arch manifest tag using buildx imagetools
        #    new_tag = dst, old_tag = src  (as requested)
        # run(f"docker buildx imagetools create -t {shlex.quote(dst)} {shlex.quote(src)}")

    print("Done.")
    return 0

if __name__ == "__main__":
    sys.exit(main())