#!/usr/bin/env bash
# Render-checks for the gateway Vector name.
# Usage: from charts/truefoundry — ./ci/test-vector-sandbox.sh
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

VEC=(--set truefoundryMonitoring.enabled=true --set tags.llmGateway=true
     --set tfy-llm-gateway.vector.enabled=true --set global.controlPlaneURL=https://cp.example.com)

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

# 1) release "truefoundry": the log collector is truefoundry-vector, the gateway Vector tfy-vector (default kept)
helm template truefoundry . -n truefoundry "${VEC[@]}" >"$TMP/v1.yaml" 2>"$TMP/v1.err" \
  || { echo "FAIL: render release truefoundry"; grep -v coalesce "$TMP/v1.err" | head -5; fail=1; }
check "vector names, release truefoundry" "$NODUPS" "$TMP/v1.yaml" \
  "DaemonSet/truefoundry-vector StatefulSet/tfy-vector ServiceAccount/tfy-vector Service/tfy-vector-headless" \
  "release truefoundry: log collector truefoundry-vector, gateway Vector tfy-vector, no duplicates"

# 2) release "tfy": both would be tfy-vector, so render fails and names both fixes
if helm template tfy . -n truefoundry "${VEC[@]}" >/dev/null 2>"$TMP/v2.err"; then
  echo "FAIL: expected render failure when both Vectors are named tfy-vector"; fail=1
elif grep -q 'both render as "tfy-vector" in namespace "truefoundry"' "$TMP/v2.err" \
    && grep -q "tfy-llm-gateway.vector.fullnameOverride" "$TMP/v2.err" \
    && grep -q "truefoundryMonitoring.logs.victoria-logs-single.vector.fullnameOverride" "$TMP/v2.err"; then
  echo "ok: release tfy with both Vectors fails render with the rename options"
else
  echo "FAIL: unexpected error for the Vector collision"; grep -v coalesce "$TMP/v2.err" | head -5; fail=1
fi

# 3) either override resolves it; the gateway's OTLP exporter follows its Vector's name
helm template tfy . -n truefoundry "${VEC[@]}" --set tfy-llm-gateway.vector.fullnameOverride=tfy-llm-gateway-vector \
  >"$TMP/v3.yaml" 2>"$TMP/v3.err" || { echo "FAIL: render with gateway Vector override"; grep -v coalesce "$TMP/v3.err" | head -5; fail=1; }
check "gateway Vector override" "$NODUPS" "$TMP/v3.yaml" \
  "DaemonSet/tfy-vector StatefulSet/tfy-llm-gateway-vector Service/tfy-llm-gateway-vector Service/tfy-llm-gateway-vector-headless" \
  "release tfy + tfy-llm-gateway.vector.fullnameOverride: no duplicates"
check "gateway exporter endpoint" '
import sys, yaml
dep = next(d for d in yaml.safe_load_all(open(sys.argv[1])) if d and d["kind"] == "Deployment" and d["metadata"]["name"] == "tfy-tfy-llm-gateway")
env = {e["name"]: e.get("value") for c in dep["spec"]["template"]["spec"]["containers"] for e in c.get("env") or []}
url = env.get("TFY_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "")
assert url.startswith("http://tfy-llm-gateway-vector.truefoundry.svc.cluster.local:4318/"), url
sts = next(d for d in yaml.safe_load_all(open(sys.argv[1])) if d and d["kind"] == "StatefulSet" and d["metadata"]["name"] == "tfy-llm-gateway-vector")
assert sts["spec"]["serviceName"] == "tfy-llm-gateway-vector-headless", sts["spec"]["serviceName"]
assert [c["metadata"]["name"] for c in sts["spec"]["volumeClaimTemplates"]] == ["data"]
print("ok: gateway exports to the renamed Vector Service")
' "$TMP/v3.yaml"
helm template tfy . -n truefoundry "${VEC[@]}" --set truefoundryMonitoring.logs.victoria-logs-single.vector.fullnameOverride=tfy-log-collector \
  >"$TMP/v4.yaml" 2>"$TMP/v4.err" || { echo "FAIL: render with log collector override"; grep -v coalesce "$TMP/v4.err" | head -5; fail=1; }
check "log collector override" "$NODUPS" "$TMP/v4.yaml" \
  "DaemonSet/tfy-log-collector StatefulSet/tfy-vector ServiceAccount/tfy-log-collector" \
  "release tfy + log collector fullnameOverride: no duplicates, gateway Vector keeps tfy-vector"

# 4) no check when only one Vector renders
for args in "--set truefoundryMonitoring.logs.enabled=false" "--set tfy-llm-gateway.vector.enabled=false" "--set tfy-llm-gateway.enabled=false"; do
  # shellcheck disable=SC2086
  if helm template tfy . -n truefoundry "${VEC[@]}" $args >/dev/null 2>"$TMP/v5.err"; then
    echo "ok: release tfy renders with $args"
  else
    echo "FAIL: release tfy with $args"; grep -v coalesce "$TMP/v5.err" | head -5; fail=1
  fi
done

exit "$fail"
