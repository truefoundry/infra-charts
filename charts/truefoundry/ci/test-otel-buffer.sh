#!/usr/bin/env bash
# Render-checks for the gateway's tfy-otel-buffer subchart.
# Usage: from charts/truefoundry — ./ci/test-otel-buffer.sh
set -euo pipefail
export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ ! -d charts ]] || ! ls charts/*.tgz >/dev/null 2>&1; then
  helm dependency build . >/dev/null
fi

fail=0
check() { # label, python script, files...
  local label=$1 script=$2; shift 2
  if python3 - "$@" <<<"$script"; then :; else echo "FAIL: $label"; fail=1; fi
}

BUF=(--set truefoundryMonitoring.enabled=true --set tags.llmGateway=true
     --set tfy-llm-gateway.enableOtelBuffer=true --set global.controlPlaneURL=https://cp.example.com)

NODUPS='
import sys, yaml, collections
docs = [d for d in yaml.safe_load_all(open(sys.argv[1])) if d]
seen = collections.Counter((d["kind"], d["metadata"].get("namespace"), d["metadata"]["name"]) for d in docs)
dups = [k for k, n in seen.items() if n > 1]
assert not dups, f"duplicate objects: {dups}"
names = {(d["kind"], d["metadata"]["name"]) for d in docs}
for kind, name in [tuple(x.split("/")) for x in sys.argv[2].split()]:
    assert (kind, name) in names, f"{kind}/{name} missing"
print(f"ok: {sys.argv[3]}")
'

# Gateway Deployment name, expected buffer name, then the rendered file.
ENDPOINT='
import sys, yaml
gateway, buffer = sys.argv[1], sys.argv[2]
docs = [d for d in yaml.safe_load_all(open(sys.argv[3])) if d]
dep = next(d for d in docs if d["kind"] == "Deployment" and d["metadata"]["name"] == gateway)
env = {e["name"]: e.get("value") for c in dep["spec"]["template"]["spec"]["containers"] for e in c.get("env") or []}
url = env.get("TFY_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "")
want = f"http://{buffer}.truefoundry.svc.cluster.local:4318/v1/traces"
assert url == want, f"{url!r} != {want!r}"
sts = next(d for d in docs if d["kind"] == "StatefulSet" and d["metadata"]["name"] == buffer)
assert sts["spec"]["serviceName"] == f"{buffer}-headless", sts["spec"]["serviceName"]
assert [c["metadata"]["name"] for c in sts["spec"]["volumeClaimTemplates"]] == ["data"]
print(f"ok: gateway exports to {want}")
'

# 1) release "tfy" with the log collector on: the log collector is tfy-vector and the buffer
#    tfy-otel-buffer, so nothing collides (the old gateway Vector was also tfy-vector)
helm template tfy . -n truefoundry "${BUF[@]}" >"$TMP/b1.yaml" 2>"$TMP/b1.err" \
  || { echo "FAIL: render release tfy"; grep -v coalesce "$TMP/b1.err" | head -5; fail=1; }
check "buffer names, release tfy" "$NODUPS" "$TMP/b1.yaml" \
  "DaemonSet/tfy-vector StatefulSet/tfy-otel-buffer ServiceAccount/tfy-otel-buffer Service/tfy-otel-buffer Service/tfy-otel-buffer-headless ConfigMap/tfy-otel-buffer-config" \
  "release tfy: log collector tfy-vector, buffer tfy-otel-buffer, no duplicates"
check "gateway exporter endpoint" "$ENDPOINT" tfy-tfy-llm-gateway tfy-otel-buffer "$TMP/b1.yaml"

# 2) the gateway's exporter follows tfy-otel-buffer.fullnameOverride
helm template tfy . -n truefoundry "${BUF[@]}" --set tfy-llm-gateway.tfy-otel-buffer.fullnameOverride=tfy-llm-gateway-otel-buffer \
  >"$TMP/b2.yaml" 2>"$TMP/b2.err" || { echo "FAIL: render with buffer fullnameOverride"; grep -v coalesce "$TMP/b2.err" | head -5; fail=1; }
check "buffer fullnameOverride" "$NODUPS" "$TMP/b2.yaml" \
  "StatefulSet/tfy-llm-gateway-otel-buffer Service/tfy-llm-gateway-otel-buffer Service/tfy-llm-gateway-otel-buffer-headless" \
  "release tfy + tfy-otel-buffer.fullnameOverride: no duplicates"
check "gateway exporter endpoint (override)" "$ENDPOINT" tfy-tfy-llm-gateway tfy-llm-gateway-otel-buffer "$TMP/b2.yaml"

# 3) buffer off: no buffer objects, and the gateway keeps its default exporter
helm template tfy . -n truefoundry --set truefoundryMonitoring.enabled=true --set tags.llmGateway=true \
  --set tfy-llm-gateway.enableOtelBuffer=false --set global.controlPlaneURL=https://cp.example.com \
  >"$TMP/b3.yaml" 2>"$TMP/b3.err" \
  || { echo "FAIL: render with the buffer off"; grep -v coalesce "$TMP/b3.err" | head -5; fail=1; }
check "buffer off" '
import sys, yaml
docs = [d for d in yaml.safe_load_all(open(sys.argv[1])) if d]
left = [f"{d['kind']}/{d['metadata']['name']}" for d in docs if "tfy-otel-buffer" in d["metadata"]["name"]]
assert not left, f"buffer objects rendered with enableOtelBuffer off: {left}"
dep = next(d for d in docs if d["kind"] == "Deployment" and d["metadata"]["name"] == "tfy-tfy-llm-gateway")
env = {e["name"]: e.get("value") for c in dep["spec"]["template"]["spec"]["containers"] for e in c.get("env") or []}
assert "tfy-otel-buffer" not in (env.get("TFY_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT") or ""), env["TFY_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"]
print("ok: buffer off renders no buffer objects")
' "$TMP/b3.yaml"

exit "$fail"
