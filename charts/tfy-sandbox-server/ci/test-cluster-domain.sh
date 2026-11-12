#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -R "$ROOT" "$TMP/chart"
cat > "$TMP/chart/templates/domain-test.yaml" <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: domain-test
data:
  domain: {{ include "tfy-sandbox-server.clusterDomain" . | quote }}
  host: {{ include "tfy-sandbox-server.serviceFQDN" . | quote }}
YAML

check() {
  local domain="$1" host="$2"
  shift 2
  helm template domain-test "$TMP/chart" --namespace chart-test \
    --show-only templates/domain-test.yaml "$@" > "$TMP/rendered.yaml"
  grep -Fqx "  domain: \"$domain\"" "$TMP/rendered.yaml"
  grep -Fqx "  host: \"$host\"" "$TMP/rendered.yaml"
}

check cluster.local domain-test-tfy-sandbox-server.chart-test.svc.cluster.local
check example.internal domain-test-tfy-sandbox-server.chart-test.svc.example.internal \
  --set global.clusterDomain=example.internal
check cluster.local domain-test-tfy-sandbox-server.chart-test.svc.cluster.local \
  --set-string global.clusterDomain=
check cluster.local domain-test-tfy-sandbox-server.chart-test.svc.cluster.local \
  --set global.clusterDomain=null
check example.internal custom-sandbox.sandbox-ns.svc.example.internal \
  --set global.clusterDomain=example.internal --set global.namespaceOverride=sandbox-ns \
  --set fullnameOverride=custom-sandbox
echo 'ok: sandbox cluster domain defaults, overrides and service FQDN'
