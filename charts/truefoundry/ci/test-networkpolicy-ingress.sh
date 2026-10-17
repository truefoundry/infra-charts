#!/usr/bin/env bash
# Render-checks for the per-component NetworkPolicy ingress model (networkPolicy.mode: perComponent).
# Usage: from charts/truefoundry — ./ci/test-networkpolicy-ingress.sh
set -euo pipefail
export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ -z "$(ls charts/*.tgz 2>/dev/null || true)" ]]; then
  helm dependency build . >/dev/null
fi

# These checks cover the per-component model; networkPolicy.mode defaults to legacy.
helm() {
  if [[ $1 == template ]]; then command helm "$@" --set networkPolicy.mode=perComponent; else command helm "$@"; fi
}

fail=0

# 1) networkPolicy.enabled renders default-deny-ingress, one ing-<component> per component and
#    allow-all-egress, and no egress allow-lists
if helm template tfy . -n truefoundry --set networkPolicy.enabled=true >"$TMP/default-np.yaml" 2>"$TMP/default-np.err"; then
  if python3 - "$TMP/default-np.yaml" <<'PY'
import sys, yaml
names = [d["metadata"]["name"] for d in yaml.safe_load_all(open(sys.argv[1])) if d and d.get("kind") == "NetworkPolicy"]
egress = [n for n in names if "-np-egr-" in n or n.endswith(("-np-default-deny-egress", "-np-allow-dns"))]
assert any(n.endswith("-np-allow-all-egress") for n in names), names
assert any(n.endswith("-np-default-deny-ingress") for n in names), names
assert any("-np-ing-" in n for n in names), names
assert not egress, f"egress policies rendered: {egress}"
print(f"ok: allow-all-egress, {sum('-np-ing-' in n for n in names)} ingress policies, no egress allow-lists")
PY
  then
    :
  else
    fail=1
  fi
else
  echo "FAIL: networkPolicy.enabled=true must render"
  grep -v coalesce "$TMP/default-np.err" | head -5 || true
  fail=1
fi

# 2) rendered call edges (service URLs in env / config, with real ports) are admitted by the
#    ingress policies; catches port mismatches as well as missing callers
cat > "$TMP/flows.yaml" <<'EOF'
tags: {llmGateway: true, llmGatewayRequestLogging: true, tracing: true}
devMode: {enabled: true}
s3proxy: {enabled: true}
sparkHistoryServer: {enabled: true}
tfyWorkflowAdmin: {enabled: true}
redis: {enabled: true}
trueforge: {enabled: true}
truefoundryMonitoring: {enabled: true}
networkPolicy:
  enabled: true
EOF
if helm template tfy . -n truefoundry -f "$TMP/flows.yaml" >"$TMP/flows-out.yaml" 2>"$TMP/flows.err"; then
  python3 "$ROOT/ci/check-networkpolicy-flows.py" "$TMP/flows-out.yaml" || fail=1
else
  echo "FAIL: render for rendered-flow check"; grep -v coalesce "$TMP/flows.err" | head -5 || true; fail=1
fi

# 3) a release workload without a networkPolicy.components entry is reported by the flow check
if helm template tfy . -n truefoundry -f "$TMP/flows.yaml" --set networkPolicy.components.tfyProxy=null >"$TMP/flows-nocomp.yaml" 2>/dev/null \
  && ! python3 "$ROOT/ci/check-networkpolicy-flows.py" "$TMP/flows-nocomp.yaml" >"$TMP/flows-nocomp.txt" 2>&1 \
  && grep -q "coverage: tfy-proxy .* has no networkPolicy.components entry" "$TMP/flows-nocomp.txt"; then
  echo "ok: workload without a component entry fails the flow check"
else
  echo "FAIL: missing component entry for tfy-proxy not reported"; grep -E "coverage|error" "$TMP/flows-nocomp.txt" | head -5 || true; fail=1
fi

# 4) sidecarMetricsPorts opened to metricsFromNamespaces
cat > "$TMP/sidecar.yaml" <<'EOF'
networkPolicy:
  enabled: true
  metricsFromNamespaces:
    - namespace: prometheus
  sidecarMetricsPorts: [15020]
EOF
helm template tfy . -n truefoundry -f "$TMP/sidecar.yaml" >"$TMP/sidecar-out.yaml" 2>/dev/null || true
if python3 - "$TMP/sidecar-out.yaml" <<'PY'
import sys, yaml
pol = next((d for d in yaml.safe_load_all(open(sys.argv[1]))
            if d and d.get("kind") == "NetworkPolicy" and d["metadata"]["name"].endswith("ing-servicefoundry-server")), None)
if pol is None:
    raise SystemExit("ing-servicefoundry-server missing")
rules = pol["spec"].get("ingress") or []
assert any(
    15020 in {p["port"] for p in r.get("ports") or []}
    and any((f.get("namespaceSelector") or {}).get("matchLabels", {}).get("kubernetes.io/metadata.name") == "prometheus"
            for f in r.get("from") or [])
    for r in rules
), rules
print("ok: sidecarMetricsPorts 15020 for metrics scrapers")
PY
then
  :
else
  fail=1
fi

# 5) default component graph is consistent: every `from` caller is a component
if python3 - values.yaml <<'PY'
import sys, yaml
comps = {c["name"]: c for c in yaml.safe_load(open(sys.argv[1]))["networkPolicy"]["components"].values()
         if isinstance(c, dict) and c.get("name")}
errs = [f"{dst} ingress <- {f}: no component entry"
        for dst, c in comps.items() for r in c.get("rules") or [] for f in r.get("from") or [] if f not in comps]
if errs:
    raise SystemExit("component graph errors:\n  " + "\n  ".join(errs))
print(f"ok: component graph consistent ({len(comps)} components)")
PY
then
  :
else
  fail=1
fi

# 6) NetworkPolicy names stay unique when the release fullname is long (63-char truncation)
for fn in truefoundry truefoundry-control-plane tfy-control-plane-truefoundry-prod-us-east-1-x; do
  helm template rel . -n truefoundry --set networkPolicy.enabled=true \
    --set truefoundryMonitoring.enabled=true --set fullnameOverride="$fn" >"$TMP/names.yaml" 2>/dev/null || true
  if python3 - "$TMP/names.yaml" "$fn" <<'PY'
import sys, yaml, collections
names = [d["metadata"]["name"] for d in yaml.safe_load_all(open(sys.argv[1])) if d and d.get("kind") == "NetworkPolicy"]
assert names, "no NetworkPolicies rendered"
dups = [n for n, c in collections.Counter(names).items() if c > 1]
long = [n for n in names if len(n) > 63]
assert not dups, f"duplicate NetworkPolicy names: {dups}"
assert not long, f"names over 63 chars: {long}"
print(f"ok: {len(names)} unique NetworkPolicy names (fullname={sys.argv[2]})")
PY
  then
    :
  else
    fail=1
  fi
done

# 7) legacy networkPolicy.allowedIngressFrom / extraIngress fail render in perComponent mode instead of being ignored
for key in allowedIngressFrom extraIngress; do
  if helm template tfy . -n truefoundry --set networkPolicy.enabled=true \
      --set "networkPolicy.${key}[0].namespace=ingress-nginx" >/dev/null 2>"$TMP/legacy-err.txt"; then
    echo "FAIL: expected render failure when networkPolicy.${key} is set"
    fail=1
  elif grep -q "networkPolicy.${key} is only read in networkPolicy.mode: legacy" "$TMP/legacy-err.txt"; then
    echo "ok: networkPolicy.${key} fails render"
  else
    echo "FAIL: unexpected error for networkPolicy.${key}"
    grep -v coalesce "$TMP/legacy-err.txt" | head -5 || true
    fail=1
  fi
done

# 8) servicefoundry-server may reach VictoriaLogs :9428
helm template tfy . -n truefoundry --set networkPolicy.enabled=true --set truefoundryMonitoring.enabled=true >"$TMP/vl.yaml" 2>/dev/null || true
if python3 - "$TMP/vl.yaml" <<'PY'
import sys, yaml
vl = next((d for d in yaml.safe_load_all(open(sys.argv[1]))
           if d and d.get("kind") == "NetworkPolicy" and d["metadata"]["name"].endswith("ing-victoria-logs-single")), None)
if vl is None:
    raise SystemExit("ing-victoria-logs-single missing")
assert any(any((f.get("podSelector") or {}).get("matchLabels", {}).get("app.kubernetes.io/name") == "servicefoundry-server"
               for f in r.get("from") or [])
           and any(p.get("port") == 9428 for p in r.get("ports") or [])
           for r in vl["spec"]["ingress"]), vl["spec"]["ingress"]
print("ok: victoria-logs-single admits servicefoundry-server on :9428")
PY
then
  :
else
  fail=1
fi

exit "$fail"
