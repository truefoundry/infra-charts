#!/usr/bin/env bash
# Render-checks for global.mTLS: with mTLS on, every TLS client's target serves TLS (NATS included);
# with it off, nothing changes. Usage: from charts/truefoundry — ./ci/test-mtls.sh
# If nats-server is on PATH, the rendered NATS config is also validated with `nats-server -t`.
set -euo pipefail
export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ ! -d charts ]] || [[ -z "$(ls charts 2>/dev/null || true)" ]]; then
  helm dependency build . >/dev/null
fi

CHECK="$ROOT/ci/check-mtls-consistency.py"
fail=0

# Every component that takes part in mTLS, so each client/server pair is rendered.
cat > "$TMP/all.yaml" <<'EOF'
global:
  controlPlaneURL: https://cp.example.com
  tenantName: test
tags:
  llmGateway: true
  llmGatewayRequestLogging: true
  tracing: true
devMode:
  enabled: true
redis:
  enabled: true
s3proxy:
  enabled: true
sparkHistoryServer:
  enabled: true
tfyWorkflowAdmin:
  enabled: true
trueforge:
  enabled: true
EOF

cat > "$TMP/mtls.yaml" <<'EOF'
global:
  mTLS:
    enabled: true
trueforge:
  mtls:
    enabled: true
EOF

render() { # <out> <helm args...>
  local out="$1"; shift
  if ! helm template truefoundry . -n truefoundry "$@" >"$out" 2>"$TMP/err.txt"; then
    echo "FAIL: helm template $*"
    grep -v coalesce "$TMP/err.txt" | head -20 || true
    return 1
  fi
}

check() { # <name> <rendered> <check args...>
  local name="$1" out="$2"; shift 2
  if python3 "$CHECK" "$out" "$@" >"$TMP/check.txt"; then
    echo "ok: $name"
  else
    echo "FAIL: $name"
    sed 's/^/  /' "$TMP/check.txt"
    fail=1
  fi
}

# 1) Defaults and full install with mTLS off: nothing serves or dials TLS because of it.
render "$TMP/default.yaml" && check "mTLS off (defaults)" "$TMP/default.yaml" --expect-off || fail=1
render "$TMP/off.yaml" -f "$TMP/all.yaml" && check "mTLS off (all components)" "$TMP/off.yaml" --expect-off || fail=1

# 2) mTLS on: NATS serves mutual TLS on 4222 and the cluster routes; websocket stays plain.
render "$TMP/on.yaml" -f "$TMP/all.yaml" -f "$TMP/mtls.yaml" && check "mTLS on" "$TMP/on.yaml" || fail=1

# 3) Rollout mode and websocket TLS.
render "$TMP/transition.yaml" -f "$TMP/all.yaml" -f "$TMP/mtls.yaml" \
  --set global.mTLS.nats.allowNonTLS=true --set global.mTLS.nats.websocketTLS=true &&
  check "mTLS on, allowNonTLS + websocketTLS" "$TMP/transition.yaml" --nats-allow-non-tls --nats-websocket-tls || fail=1

# 3b) websocketTLS follows verifyClients: TLS on 8080 without client certificates.
render "$TMP/ws-noverify.yaml" -f "$TMP/all.yaml" -f "$TMP/mtls.yaml" \
  --set global.mTLS.nats.websocketTLS=true --set global.mTLS.nats.verifyClients=false &&
  check "mTLS on, websocketTLS + verifyClients=false" "$TMP/ws-noverify.yaml" --nats-websocket-tls --no-nats-verify || fail=1

# 4) Plain cluster routes, no client-cert requirement on 4222 (or 8080).
render "$TMP/relaxed.yaml" -f "$TMP/all.yaml" -f "$TMP/mtls.yaml" \
  --set global.mTLS.nats.clusterTLS=false --set global.mTLS.nats.verifyClients=false &&
  check "mTLS on, clusterTLS=false verifyClients=false" "$TMP/relaxed.yaml" --no-nats-cluster-tls --no-nats-verify || fail=1

# 5) External secret: NATS mounts it and the bootstrap job does not issue one.
if render "$TMP/external.yaml" -f "$TMP/all.yaml" -f "$TMP/mtls.yaml" --set global.mTLS.externalMtlsSecret=my-mtls; then
  check "mTLS on, externalMtlsSecret" "$TMP/external.yaml" --secret my-mtls
  if grep -qE '^ +create_tfy_mtls_certificate_and_secret$' "$TMP/external.yaml"; then
    echo "FAIL: bootstrap still issues a leaf with externalMtlsSecret set"
    fail=1
  else
    echo "ok: bootstrap skips issuance with externalMtlsSecret"
  fi
else
  fail=1
fi

# 6) trueforge.mtls must follow global.mTLS.
if helm template truefoundry . -n truefoundry -f "$TMP/all.yaml" --set global.mTLS.enabled=true >/dev/null 2>"$TMP/err.txt"; then
  echo "FAIL: global.mTLS.enabled without trueforge.mtls.enabled rendered"
  fail=1
elif grep -q "must have the same value" "$TMP/err.txt"; then
  echo "ok: mismatched trueforge.mtls fails render"
else
  echo "FAIL: unexpected error for mismatched trueforge.mtls"; grep -v coalesce "$TMP/err.txt" | head -5
  fail=1
fi

# 7) Optional: the rendered NATS config loads in nats-server with a leaf carrying the rendered SANs.
if command -v nats-server >/dev/null && command -v openssl >/dev/null; then
  for f in on transition ws-noverify relaxed; do
    if ! python3 - "$TMP/$f.yaml" "$TMP/$f" <<'PY'
import os, re, sys, yaml
docs = [d for d in yaml.safe_load_all(open(sys.argv[1])) if d]
out = sys.argv[2]
os.makedirs(out, exist_ok=True)
conf = next(d["data"]["nats.conf"] for d in docs if d["kind"] == "ConfigMap" and d["metadata"]["name"].endswith("-tfy-nats-config"))
script = next(d["stringData"]["truefoundry-bootstrap.sh"] for d in docs if d["kind"] == "Secret" and d["metadata"]["name"] == "truefoundry-bootstrap-secret")
conf = re.sub(r"^\s*include .*;\s*$", "", conf, flags=re.M).replace("$SERVER_NAME", '"x"')
conf = re.sub(r"/etc/nats-(certs/[a-z]+|ca-cert)/", out + "/", conf)
open(f"{out}/nats.conf", "w").write(conf)
open(f"{out}/sans.txt", "w").write("\n".join(re.findall(r'echo "DNS\.\d+ = ([^"]+)"', script)))
PY
    then fail=1; continue; fi
    d="$TMP/$f"
    openssl req -x509 -newkey rsa:2048 -nodes -days 1 -subj "/CN=test-ca" -keyout "$d/ca.key" -out "$d/ca.crt" \
      -addext "basicConstraints=critical,CA:TRUE" -addext "keyUsage=critical,keyCertSign" >/dev/null 2>&1
    { echo "subjectAltName = @alt"; echo "extendedKeyUsage = serverAuth, clientAuth"; echo "[alt]"
      n=1; while IFS= read -r s; do echo "DNS.$n = $s"; n=$((n+1)); done < "$d/sans.txt"; } > "$d/ext.cnf"
    openssl req -newkey rsa:2048 -nodes -subj "/CN=truefoundry-internal" -keyout "$d/tls.key" -out "$d/tls.csr" >/dev/null 2>&1
    openssl x509 -req -in "$d/tls.csr" -CA "$d/ca.crt" -CAkey "$d/ca.key" -CAcreateserial -days 1 \
      -extfile "$d/ext.cnf" -out "$d/tls.crt" >/dev/null 2>&1
    if nats-server -c "$d/nats.conf" -t >"$d/t.txt" 2>&1; then
      echo "ok: nats-server -t accepts the $f config"
    else
      echo "FAIL: nats-server -t rejects the $f config"; sed 's/^/  /' "$d/t.txt"
      fail=1
    fi
  done
elif [[ ${CI:-} == true ]]; then
  echo "FAIL: nats-server or openssl not on PATH under CI; the NATS config load test must run (ci/install-nats-server.sh)"
  fail=1
else
  echo "skip: nats-server or openssl not on PATH; NATS config load test not run"
fi

exit "$fail"
