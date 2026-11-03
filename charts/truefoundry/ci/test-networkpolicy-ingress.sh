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

# 9) routes that bypass tfy-proxy: the chart's VirtualService, Ingress and HTTPRoute reach tfy-workflow-admin
#    directly, and an external VirtualService (auth-server's /mcp/oauth2/callback) reaches servicefoundry-server.
#    By default their extraIngress admits only istio-system pods labelled istio: tfy-istio-ingress, on top of the
#    default rules; extraIngress: [] admits nothing external; a user list replaces the default. tfy-proxy stays
#    open to all.
cat > "$TMP/gw.yaml" <<'EOF'
global:
  virtualservice: {enabled: true, gateways: [istio-system/tfy-wildcard], hosts: [tfy.example.com]}
  ingress: {enabled: true, hosts: [tfy.example.com]}
  httpRoute: {enabled: true, parentRefs: [{name: tfy-gateway, namespace: gateway-system}], hostnames: [tfy.example.com]}
tfyWorkflowAdmin: {enabled: true}
networkPolicy:
  enabled: true
EOF
cat > "$TMP/gw-off.yaml" <<'EOF'
networkPolicy:
  components:
    tfyWorkflowAdmin: {extraIngress: []}
    servicefoundryServer: {extraIngress: []}
EOF
cat > "$TMP/gw-override.yaml" <<'EOF'
networkPolicy:
  components:
    tfyWorkflowAdmin:
      extraIngress:
        - ports: [{port: 8089, protocol: TCP}]
          from:
            - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: ingress-nginx}}
              podSelector: {matchLabels: {app.kubernetes.io/name: ingress-nginx}}
            - ipBlock: {cidr: 10.0.0.0/24}
    servicefoundryServer:
      extraIngress:
        - ports: [{port: 3000, protocol: TCP}]
          from:
            - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: ingress-nginx}}
              podSelector: {matchLabels: {app.kubernetes.io/name: ingress-nginx}}
            - ipBlock: {cidr: 10.0.0.0/24}
EOF
gw_ok=1
helm template tfy . -n truefoundry -f "$TMP/gw.yaml" >"$TMP/gw-default-out.yaml" 2>/dev/null || gw_ok=0
helm template tfy . -n truefoundry -f "$TMP/gw.yaml" -f "$TMP/gw-off.yaml" >"$TMP/gw-off-out.yaml" 2>/dev/null || gw_ok=0
helm template tfy . -n truefoundry -f "$TMP/gw.yaml" -f "$TMP/gw-override.yaml" >"$TMP/gw-override-out.yaml" 2>/dev/null || gw_ok=0
if [[ $gw_ok == 1 ]] && python3 - "$TMP/gw-default-out.yaml" "$TMP/gw-off-out.yaml" "$TMP/gw-override-out.yaml" <<'PY'
import ipaddress, sys, yaml

# Source pods, as (namespace, labels), or an IP for the ALB.
TFY_GW = ("istio-system", {"istio": "tfy-istio-ingress", "app.kubernetes.io/part-of": "istio"})
OTHER_GWS = [("istio-system", {"istio": v, "app.kubernetes.io/part-of": "istio"})
             for v in ("tfy-istio-ingress-tailnet", "tfy-istio-ingress-alb", "tfy-istio-ingress-ctl-alb")]
NGINX = ("ingress-nginx", {"app.kubernetes.io/name": "ingress-nginx"})
ALB_IP = "10.0.0.10"
DEFAULT_PEER = {"namespaceSelector": {"matchLabels": {"kubernetes.io/metadata.name": "istio-system"}},
                "podSelector": {"matchLabels": {"istio": "tfy-istio-ingress"}}}
# Not rendered by this chart: auth-server's VirtualService routes the MCP OAuth callback through a gateway
# straight to servicefoundry-server.
EXTERNAL_VS = {"kind": "VirtualService", "metadata": {"name": "auth-server", "namespace": "auth-server"},
               "spec": {"gateways": ["istio-system/tfy-wildcard"], "hosts": ["auth.example.com"],
                        "http": [{"match": [{"uri": {"prefix": "/mcp/oauth2/callback"}}],
                                  "route": [{"destination": {"host": "tfy-servicefoundry-server.truefoundry.svc.cluster.local",
                                                             "port": {"number": 3000}}}]}]}}

def load(path):
    return [d for d in yaml.safe_load_all(open(path)) if isinstance(d, dict) and d.get("kind")]

def policy(docs, name):
    pol = next((d for d in docs if d["kind"] == "NetworkPolicy" and d["metadata"]["name"].endswith("-np-ing-" + name)), None)
    assert pol is not None, f"ing-{name} missing"
    return pol

def selects(sel, labels):
    sel = sel or {}
    if any(labels.get(k) != v for k, v in (sel.get("matchLabels") or {}).items()):
        return False
    for e in sel.get("matchExpressions") or []:
        has, val = e["key"] in labels, labels.get(e["key"])
        ok = {"In": has and val in e.get("values", []), "NotIn": not has or val not in e.get("values", []),
              "Exists": has, "DoesNotExist": not has}[e["operator"]]
        if not ok:
            return False
    return True

def peer_admits(f, src):
    if isinstance(src, str):
        return "ipBlock" in f and ipaddress.ip_address(src) in ipaddress.ip_network(f["ipBlock"]["cidr"])
    ns, labels = src
    return ("namespaceSelector" in f and selects(f["namespaceSelector"], {"kubernetes.io/metadata.name": ns})
            and selects(f.get("podSelector"), labels))

def admits(pol, port, src):
    for r in pol["spec"].get("ingress") or []:
        if r.get("ports") and port not in {p["port"] for p in r["ports"]}:
            continue
        if "from" not in r or any(peer_admits(f, src) for f in r["from"]):
            return True
    return False

def external_peers(pol):
    return [f for r in pol["spec"].get("ingress") or [] for f in r.get("from") or [{}]
            if "namespaceSelector" in f or "ipBlock" in f or not f]

def backends(docs):
    out = set()
    for d in docs:
        if d["kind"] == "VirtualService":
            for h in d["spec"]["http"]:
                for r in h["route"]:
                    out.add((d["kind"], r["destination"]["host"].split(".")[0], r["destination"]["port"]["number"]))
        elif d["kind"] == "Ingress":
            for rule in d["spec"]["rules"]:
                for p in rule["http"]["paths"]:
                    out.add((d["kind"], p["backend"]["service"]["name"], p["backend"]["service"]["port"]["number"]))
        elif d["kind"] == "HTTPRoute":
            for rule in d["spec"]["rules"]:
                for b in rule["backendRefs"]:
                    out.add((d["kind"], b["name"], b["port"]))
    return out

def resolve(docs, svc_name, port):
    """(component name, target port) for a Service port, from the pods it selects."""
    svc = next(d for d in docs if d["kind"] == "Service" and d["metadata"]["name"] == svc_name)
    sp = next(p for p in svc["spec"]["ports"] if p["port"] == port)
    tp = sp.get("targetPort", port)
    for w in docs:
        if w["kind"] not in ("Deployment", "StatefulSet"):
            continue
        t = w["spec"]["template"]
        labels = t["metadata"].get("labels") or {}
        if all(labels.get(k) == v for k, v in svc["spec"]["selector"].items()):
            if isinstance(tp, str):
                tp = next(p["containerPort"] for c in t["spec"]["containers"] for p in c.get("ports") or [] if p.get("name") == tp)
            return labels["app.kubernetes.io/name"], int(tp)
    raise SystemExit(f"no workload behind Service {svc_name}")

default, off, override = (load(p) for p in sys.argv[1:4])

routes = backends(default)
assert {k for k, _, _ in routes} == {"VirtualService", "Ingress", "HTTPRoute"}, routes
targets = {resolve(default, s, p) for _, s, p in routes} | {resolve(default, s, p) for _, s, p in backends([EXTERNAL_VS])}
assert targets == {("tfy-workflow-admin", 8089), ("tfy-proxy", 8080), ("servicefoundry-server", 3000)}, targets

for name, port in sorted(targets):
    if name == "tfy-proxy":
        for label, docs in (("default", default), ("off", off), ("override", override)):
            assert policy(docs, name)["spec"]["ingress"] == [{"ports": [{"port": 8080, "protocol": "TCP"}]}], f"{label}: tfy-proxy ingress changed"
        continue
    base = policy(off, name)["spec"]["ingress"]
    # extraIngress: [] -> nothing from outside the release
    assert not external_peers(policy(off, name)), f"off: {name} admits a source outside the release"
    # default -> exactly the tfy-istio-ingress pods, on top of the default rules
    d = policy(default, name)
    assert d["spec"]["ingress"][: len(base)] == base and len(d["spec"]["ingress"]) == len(base) + 1, f"default: {name} rules not kept"
    assert external_peers(d) == [DEFAULT_PEER], f"default: {name} external peers {external_peers(d)}"
    assert admits(d, port, TFY_GW), f"default: tfy-istio-ingress not admitted on {name}:{port}"
    for src in OTHER_GWS + [NGINX, ALB_IP]:
        assert not admits(d, port, src), f"default: {src} admitted on {name}:{port}"
    # override -> replaces the default
    o = policy(override, name)
    assert o["spec"]["ingress"][: len(base)] == base and len(o["spec"]["ingress"]) == len(base) + 1, f"override: {name} rules not kept"
    assert admits(o, port, NGINX) and admits(o, port, ALB_IP), f"override: not applied on {name}:{port}"
    assert not admits(o, port, TFY_GW), f"override: default tfy-istio-ingress entry still present on {name}:{port}"
for label, docs in (("default", default), ("override", override)):
    assert not external_peers(policy(docs, "mlfoundry-server")), f"{label}: mlfoundry-server admits a source outside the release"
print(f"ok: routes bypassing tfy-proxy ({', '.join(f'{n}:{p}' for n, p in sorted(targets))}): default admits only "
      "istio-system tfy-istio-ingress pods; extraIngress: [] admits nothing external; an override replaces the default; "
      "tfy-proxy unchanged")
PY
then
  :
else
  echo "FAIL: routes that bypass tfy-proxy"
  fail=1
fi

exit "$fail"
