#!/usr/bin/env bash
# Render-checks for service-account guards: annotations on components without an account of their own,
# and the TrueForge sandbox server's account versus global.restrictedServiceAccount. Also checks that
# every non-privileged container in an everything-on render has an effective seccomp profile.
# Usage: from charts/truefoundry — ./ci/test-service-accounts.sh
set -euo pipefail
export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ -z "$(ls charts/*.tgz 2>/dev/null || true)" ]]; then
  helm dependency build . >/dev/null
fi

cat > "$TMP/base.yaml" <<'EOF'
global:
  tenantName: acme
  controlPlaneURL: https://tfy.example.com
  database: {host: db.example.internal, name: tfy, username: tfy, password: changeme}
  tfyApiKey: dummykey
tags: {tracing: true}
redis: {enabled: true}
trueforge:
  enabled: true
  truefoundry: {devSandboxServerEnabled: true}
EOF

fail=0
# expect <label> <ok|fail:<message fragment>> <helm args...>
expect() {
  local label=$1 want=$2; shift 2
  if helm template tfy . -n truefoundry -f "$TMP/base.yaml" "$@" >"$TMP/out.yaml" 2>"$TMP/err.txt"; then
    if [[ $want == ok ]]; then echo "ok: $label renders"; else echo "FAIL: $label rendered, want a failure"; fail=1; fi
  elif [[ $want == fail:* ]] && grep -qF "${want#fail:}" "$TMP/err.txt"; then
    echo "ok: $label fails render"
  else
    echo "FAIL: $label (want $want)"; grep -v coalesce "$TMP/err.txt" | head -3 || true; fail=1
  fi
}

expect "defaults" ok

# Annotations on a component without an account of its own would be dropped.
for c in tfyController tfyK8sController sfyManifestService tfyInfraManager tfyProxy tfy-otel-collector; do
  expect "$c annotations on the restricted account" "fail:$c.serviceAccount.annotations is set, but $c has no account of its own" \
    --set "$c.serviceAccount.annotations.team=platform"
done
expect "tfyController annotations on global.serviceAccount" 'fail:runs on "truefoundry"' \
  --set tfyController.serviceAccount.annotations.team=platform --set global.restrictedServiceAccount.enabled=false \
  --set trueforge.tfy-sandbox-server.serviceAccount.name=null
expect "tfyController annotations with create and name" ok \
  --set tfyController.serviceAccount.annotations.team=platform --set tfyController.serviceAccount.create=true \
  --set tfyController.serviceAccount.name=tfy-controller
if python3 - "$TMP/out.yaml" <<'PY'
import sys, yaml
docs = [d for d in yaml.safe_load_all(open(sys.argv[1])) if d]
sa = next(d for d in docs if d["kind"] == "ServiceAccount" and d["metadata"]["name"] == "tfy-controller")
assert (sa["metadata"].get("annotations") or {}).get("team") == "platform", sa["metadata"]
dep = next(d for d in docs if d["kind"] == "Deployment" and d["metadata"]["name"].endswith("tfy-controller"))
assert dep["spec"]["template"]["spec"]["serviceAccountName"] == "tfy-controller"
PY
then echo "ok: tfy-controller runs on its own annotated account"; else echo "FAIL: tfy-controller own account"; fail=1; fi
expect "tfyProxy annotations with create" ok --set tfyProxy.serviceAccount.annotations.team=platform --set tfyProxy.serviceAccount.create=true
# tfy-otel-collector.enabled is the dependency condition, so an explicit value beats the tags.
expect "tfy-otel-collector annotations with the subchart disabled under tags.tracing" ok \
  --set tfy-otel-collector.enabled=false --set tfy-otel-collector.serviceAccount.annotations.team=platform
if grep -q "^# Source: truefoundry/charts/tfy-otel-collector/" "$TMP/out.yaml"; then echo "FAIL: tfy-otel-collector rendered with enabled=false"; fail=1
else echo "ok: tfy-otel-collector not rendered with enabled=false"; fi
expect "tfy-otel-collector annotations enabled with the tags off" "fail:tfy-otel-collector.serviceAccount.annotations is set" \
  --set tags.tracing=false --set tfy-otel-collector.enabled=true --set tfy-otel-collector.serviceAccount.annotations.team=platform
expect "tfy-otel-collector annotations with the tags off" ok \
  --set tags.tracing=false --set tfy-otel-collector.serviceAccount.annotations.team=platform
expect "tfy-otel-collector annotations with create and name" ok \
  --set tfy-otel-collector.serviceAccount.annotations.team=platform --set tfy-otel-collector.serviceAccount.create=true \
  --set tfy-otel-collector.serviceAccount.name=tfy-otel-collector

# The TrueForge sandbox server must not point at an account that is not created.
expect "sandbox with the restricted account disabled" "fail:but global.restrictedServiceAccount.enabled is false" \
  --set global.restrictedServiceAccount.enabled=false
expect "sandbox with the restricted account renamed" 'fail:but global.restrictedServiceAccount.name is "my-restricted"' \
  --set global.restrictedServiceAccount.name=my-restricted
expect "sandbox renamed together with the restricted account" ok \
  --set global.restrictedServiceAccount.name=my-restricted --set trueforge.tfy-sandbox-server.serviceAccount.name=my-restricted
expect "sandbox on global.serviceAccount (null) with the restricted account disabled" ok \
  --set global.restrictedServiceAccount.enabled=false --set trueforge.tfy-sandbox-server.serviceAccount.name=null
expect "sandbox with its own account" ok \
  --set global.restrictedServiceAccount.enabled=false --set trueforge.tfy-sandbox-server.serviceAccount.create=true
expect "sandbox off with the restricted account disabled" ok \
  --set global.restrictedServiceAccount.enabled=false --set trueforge.truefoundry.devSandboxServerEnabled=false

# Every optional workload on, including both build modes, the opt-in monitoring apps and the bitnami
# init and metrics containers.
cat > "$TMP/all-on.yaml" <<'EOF'
tags: {llmGateway: true, llmGatewayRequestLogging: true, tracing: true}
devMode: {enabled: true}
metricsV2: {enabled: true}
s3proxy: {enabled: true}
sparkHistoryServer: {enabled: true}
tfyWorkflowAdmin: {enabled: true}
monitoring: {enabled: true}
victoriaMetricsMonitoring: {enabled: true}
truefoundryMonitoring:
  enabled: true
  tfyNatsUi: {enabled: true}
  tfyMetricsDashboard: {enabled: true}
  headlamp: {enabled: true}
  prometheus: {alertmanager: {enabled: true}}
tfyNats: {natsBox: {enabled: true}}
tfy-llm-gateway:
  enableOtelBuffer: true
  proxy: {tls: {enabled: true, secretName: gateway-tls}}
  redis: {metrics: {enabled: true}}
tfyBuild:
  preemptibleDeployment: {enabled: true}
  jobTemplate: {enabled: true}
postgresql:
  metrics: {enabled: true}
  volumePermissions: {enabled: true}
redis:
  metrics: {enabled: true}
  volumePermissions: {enabled: true}
EOF
if helm template truefoundry . -n truefoundry -f "$TMP/base.yaml" -f "$TMP/all-on.yaml" >"$TMP/all-on-out.yaml" 2>"$TMP/err.txt"; then
  if python3 - "$TMP/all-on-out.yaml" <<'PY'
import re, sys, yaml

def profile(sc):
    t = ((sc or {}).get("seccompProfile") or {}).get("type")
    return t if t in ("RuntimeDefault", "Localhost") else None

def containers(spec):
    for key in ("initContainers", "containers", "ephemeralContainers"):
        yield from spec.get(key) or []

checked, missing = 0, []
def check(name, pod_sc, ctrs):
    global checked
    for c in ctrs:
        sc = c.get("securityContext") or {}
        if sc.get("privileged"):
            continue  # Kubernetes never applies seccomp to privileged containers
        checked += 1
        if not (profile(sc) or profile(pod_sc)):
            missing.append(f"{name}: {c.get('name')}")

def walk(d, name):
    kind, spec = d.get("kind"), d.get("spec") or {}
    if kind in ("Deployment", "StatefulSet", "DaemonSet", "ReplicaSet", "Job"):
        pod = (spec.get("template") or {}).get("spec") or {}
        check(name, pod.get("securityContext"), containers(pod))
    elif kind == "CronJob":
        pod = spec["jobTemplate"]["spec"]["template"]["spec"]
        check(name, pod.get("securityContext"), containers(pod))
    elif kind == "Pod":
        check(name, spec.get("securityContext"), containers(spec))
    elif kind in ("Prometheus", "Alertmanager", "ThanosRuler", "PrometheusAgent"):
        check(name, spec.get("securityContext"), containers(spec) if spec.get("containers") else [{"name": "(operator-managed)"}])
    elif kind in ("WorkflowTemplate", "ClusterWorkflowTemplate", "CronWorkflow"):
        spec = spec.get("workflowSpec", spec) if kind == "CronWorkflow" else spec
        for t in spec.get("templates") or []:
            ctrs = [t[k] | {"name": t[k].get("name") or k} for k in ("container", "script") if t.get(k)]
            ctrs += (t.get("containerSet") or {}).get("containers") or []
            ctrs += (t.get("initContainers") or []) + (t.get("sidecars") or [])
            check(f"{name}#{t['name']}", t.get("securityContext") or spec.get("securityContext"), ctrs)
    elif kind == "ConfigMap":
        # Pod specs that the chart ships as data, such as the tfyBuild.jobTemplate build Job.
        for key, val in (d.get("data") or {}).items():
            if isinstance(val, str) and "containers:" in val:
                for sub in yaml.safe_load_all(re.sub(r"\{\{.*?\}\}", "x", val)):
                    if isinstance(sub, dict):
                        walk(sub, f"{name}[{key}]")

for d in yaml.safe_load_all(open(sys.argv[1])):
    if d:
        walk(d, f"{d['kind']}/{d['metadata']['name']}")
assert checked >= 55, f"only {checked} containers rendered; the everything-on profile lost workloads"
assert not missing, "no seccomp profile on: " + ", ".join(missing)
print(f"ok: seccomp profile on all {checked} non-privileged containers of the everything-on render")
PY
  then :; else echo "FAIL: seccomp coverage"; fail=1; fi
else
  echo "FAIL: everything-on render"; grep -v coalesce "$TMP/err.txt" | head -3 || true; fail=1
fi

exit "$fail"
