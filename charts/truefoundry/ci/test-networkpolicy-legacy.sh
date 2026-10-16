#!/usr/bin/env bash
# networkPolicy.mode checks.
#   a) networkPolicy.enabled with the default mode (legacy) or an explicit legacy renders
#      the same NetworkPolicies as the base branch (PARITY_MAIN_REF, default: the merge-base of HEAD and
#      origin/<PARITY_BASE_BRANCH, else the PR's base branch GITHUB_BASE_REF, else main>), including
#      allowedIngressFrom / extraIngress. Release branches don't share history with main beyond old
#      merge-bases, so a release PR compares against its release base branch.
#   m) every enabled x mode combination picks the right model or fails render.
#   b) With PARITY_DEFAULTS_REF set (e.g. origin/<base branch>, to show a change only touches
#      NetworkPolicies): the render equals that ref in every profile apart from NetworkPolicy objects, and
#      there are no NetworkPolicies unless networkPolicy.enabled.
# The perComponent model is covered by test-networkpolicy-ingress.sh.
#
# Renders are compared after normalising:
#   - helm.sh/chart and app.kubernetes.io/version labels, checksum/* annotations
#   - image tags and digests (`image:` fields) and bare version strings, which move with every release
#   - null fields (the API server drops them)
#   - randomly generated secret values (Grafana admin password)
#
# Usage: from charts/truefoundry — ./ci/test-networkpolicy-legacy.sh
set -euo pipefail
export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(git -C "$ROOT" rev-parse --show-toplevel)"
CHART_PATH="${ROOT#"$REPO"/}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$ROOT"
if [[ -z "$(ls charts/*.tgz 2>/dev/null || true)" ]]; then
  helm dependency build . >/dev/null
fi

# Dependencies vendored as directories under charts/ (repository: file://charts/...) must render from
# the directory, not from a packaged copy left in charts/ by an earlier `helm dependency build`.
# file:// paths outside charts/ (chart-test.yaml points tfy-llm-gateway at file://../tfy-llm-gateway)
# exist only as that packaged copy, so keep them. Read from each chart's own Chart.yaml.
strip_local_tgz() { # chart dir
  local n
  for n in $(python3 -c 'import os,sys,yaml; d=sys.argv[1]; print(" ".join(x["name"] for x in yaml.safe_load(open(os.path.join(d, "Chart.yaml"))).get("dependencies") or [] if str(x.get("repository","")).startswith("file://") and os.path.isdir(os.path.join(d, "charts", x["name"]))))' "$1"); do
    rm -f "$1"/charts/"$n"-*.tgz
  done
}

# Fails when a dependency is packaged identically in the baseline and in HEAD although the two charts
# resolve it from different sources (repository@version, or the contents of a file:// directory),
# i.e. the baseline is rendering HEAD's subchart (for example chart-test.yaml's file:// gateway).
check_baseline_deps() { # ref, baseline chart dir
  python3 - "$2" "$HEAD_DIR" "$ROOT" "$1" <<'PY'
import hashlib, os, re, sys, yaml
base_dir, head_dir, head_src_root, ref = sys.argv[1:5]

def tree_hash(path):
    if not os.path.isdir(path):
        return "missing"
    h = hashlib.sha256()
    for root, dirs, files in os.walk(path):
        dirs[:] = sorted(d for d in dirs if d != "charts")
        for f in sorted(files):
            p = os.path.join(root, f)
            h.update(os.path.relpath(p, path).encode() + b"\0" + open(p, "rb").read())
    return h.hexdigest()[:12]

def deps(chart_dir, src_root):
    out = {}
    for d in yaml.safe_load(open(os.path.join(chart_dir, "Chart.yaml"))).get("dependencies") or []:
        repo = str(d.get("repository", ""))
        src = f"{repo}@{d.get('version')}"
        if repo.startswith("file://"):
            src += ":" + tree_hash(os.path.normpath(os.path.join(src_root, repo[len("file://"):])))
        pkgs = [f for f in os.listdir(os.path.join(chart_dir, "charts")) if re.match(re.escape(d["name"]) + r"-\d.*\.tgz$", f)]
        digest = hashlib.sha256(open(os.path.join(chart_dir, "charts", pkgs[0]), "rb").read()).hexdigest() if len(pkgs) == 1 else None
        out[d["name"]] = (src, digest)
    return out

base, head = deps(base_dir, base_dir), deps(head_dir, head_src_root)
bad = []
for name in sorted(set(base) & set(head)):
    (bsrc, bdig), (hsrc, hdig) = base[name], head[name]
    if bdig and bdig == hdig and bsrc != hsrc:
        bad.append(f"{name}: baseline {bsrc} and HEAD {hsrc} are the same package (sha256 {bdig[:12]})")
gw_b, gw_h = base.get("tfy-llm-gateway"), head.get("tfy-llm-gateway")
if gw_b and gw_h:
    if not (gw_b[1] and gw_h[1]):
        bad.append("tfy-llm-gateway: packaged chart missing in the baseline or HEAD")
    print(f"baseline deps ({ref[:9]}): tfy-llm-gateway {gw_b[0]} sha256 {(gw_b[1] or '-')[:12]}; HEAD {gw_h[0]} sha256 {(gw_h[1] or '-')[:12]}")
if bad:
    print("FAIL: the baseline does not use its own dependencies:")
    for b in bad:
        print("  " + b)
    sys.exit(1)
PY
}

checkout_ref() { # ref, dir: the chart at ref with dependencies built from that ref's own Chart.lock
  mkdir -p "$2"
  git -C "$REPO" archive "$1" "$CHART_PATH" | tar -x -C "$2"
  rm -f "$2/$CHART_PATH"/charts/*.tgz
  if ! (cd "$2/$CHART_PATH" && helm dependency build . >/dev/null); then
    echo "FAIL: helm dependency build for the chart at $1"; exit 1
  fi
  strip_local_tgz "$2/$CHART_PATH"
  check_baseline_deps "$1" "$2/$CHART_PATH" || exit 1
}
mkdir -p "$TMP/head"
cp -r "$ROOT/." "$TMP/head/"
HEAD_DIR="$TMP/head"
strip_local_tgz "$HEAD_DIR"

cat > "$TMP/min.yaml" <<'VALUES'
global:
  tenantName: acme
  controlPlaneURL: https://tfy.example.com
  database: {host: db.example.internal, name: tfy, username: tfy, password: changeme}
  tfyApiKey: dummykey
VALUES
cat > "$TMP/np.yaml" <<'VALUES'
networkPolicy:
  enabled: true
VALUES
cat > "$TMP/np-legacy-keys.yaml" <<'VALUES'
networkPolicy:
  enabled: true
  allowedIngressFrom:
    - namespace: ingress-nginx
      podSelector:
        app.kubernetes.io/name: ingress-nginx
  extraIngress:
    - from:
        - ipBlock:
            cidr: 10.0.0.0/8
      ports:
        - port: 8000
          protocol: TCP
VALUES
cat > "$TMP/full.yaml" <<'VALUES'
tags: {llmGateway: true, llmGatewayRequestLogging: true, tracing: true}
devMode: {enabled: true}
s3proxy: {enabled: true}
sparkHistoryServer: {enabled: true}
tfyWorkflowAdmin: {enabled: true}
redis: {enabled: true}
trueforge: {enabled: true, truefoundry: {devSandboxServerEnabled: true}}
truefoundryMonitoring: {enabled: true}
monitoring: {enabled: true}
VALUES

cat > "$TMP/compare.py" <<'PY'
import re, sys, yaml

NOISY_LABELS = {"helm.sh/chart", "app.kubernetes.io/version"}
RANDOM_SECRET_KEYS = {("Secret", "admin-password")}
VERSION = re.compile(r"^v?\d+\.\d+\.\d+([-+][\w.-]+)?$")

def untag(image):
    image = image.split("@", 1)[0]
    return re.sub(r":[^/:]+$", "", image)

def norm(o, path=()):
    if isinstance(o, dict):
        out = {}
        for k, v in o.items():
            if v is None:
                continue
            if path and path[-1] == "labels" and k in NOISY_LABELS:
                continue
            if path and path[-1] == "annotations" and str(k).startswith("checksum/"):
                continue
            if k == "image" and isinstance(v, str):
                out[k] = untag(v)
                continue
            out[k] = norm(v, path + (k,))
        return out
    if isinstance(o, list):
        return [norm(x, path) for x in o]
    if isinstance(o, str) and VERSION.match(o):
        return "<version>"
    return o

def load(f, kinds):
    docs = {}
    for d in yaml.safe_load_all(open(f)):
        if not d or (kinds and d["kind"] not in kinds):
            continue
        d = norm(d)
        if d["kind"] == "Secret":
            for kind, key in RANDOM_SECRET_KEYS:
                for sect in ("data", "stringData"):
                    if key in (d.get(sect) or {}):
                        d[sect][key] = "<random>"
        docs[(d["kind"], d["metadata"].get("namespace", ""), d["metadata"]["name"])] = d
    return docs

def diff(a, b, path=""):
    if type(a) != type(b):
        yield path, a, b
    elif isinstance(a, dict):
        for k in sorted(set(a) | set(b), key=str):
            if k not in a or k not in b:
                yield f"{path}.{k}", a.get(k, "<absent>"), b.get(k, "<absent>")
            else:
                yield from diff(a[k], b[k], f"{path}.{k}")
    elif isinstance(a, list):
        if len(a) != len(b):
            yield path, f"<{len(a)} items>", f"<{len(b)} items>"
        else:
            for i, (x, y) in enumerate(zip(a, b)):
                yield from diff(x, y, f"{path}[{i}]")
    elif a != b:
        yield path, a, b

base_f, head_f, label, kinds = sys.argv[1], sys.argv[2], sys.argv[3], set(filter(None, sys.argv[4].split(",")))
base, head = load(base_f, kinds), load(head_f, kinds)
problems = []
for k in sorted(set(base) - set(head)):
    problems.append(f"removed: {k[0]}/{k[2]}")
for k in sorted(set(head) - set(base)):
    problems.append(f"added: {k[0]}/{k[2]}")
for k in sorted(set(base) & set(head)):
    for p, a, b in diff(base[k], head[k]):
        s = lambda v: (str(v)[:100] + "…") if len(str(v)) > 100 else str(v)
        problems.append(f"changed: {k[0]}/{k[2]} {p}: {s(a)} -> {s(b)}")
if problems:
    print(f"FAIL {label}: {len(problems)} difference(s)")
    for p in problems[:40]:
        print("  " + p)
    sys.exit(1)
print(f"ok: {label}: {len(head)} {'/'.join(sorted(kinds)) if 0 < len(kinds) <= 2 else 'objects'} identical")
PY

fail=0
render() { # dir, out, value files...
  local dir=$1 out=$2; shift 2
  local args=(-f "$TMP/min.yaml")
  for f in "$@"; do args+=(-f "$TMP/$f"); done
  if ! (cd "$dir" && helm template tfy . -n truefoundry "${args[@]}" >"$out" 2>"$out.err"); then
    echo "FAIL: render $out"; grep -v coalesce "$out.err" | head -5 || true; return 1
  fi
}
count_np() { python3 -c 'import sys,yaml; print(sum(1 for d in yaml.safe_load_all(open(sys.argv[1])) if d and d["kind"]=="NetworkPolicy"))' "$1"; }

# a) legacy mode renders main's NetworkPolicies
BASE_BRANCH="${PARITY_BASE_BRANCH:-${GITHUB_BASE_REF:-main}}"
if [[ -n ${PARITY_MAIN_REF:-} ]]; then
  MAIN_REF=$PARITY_MAIN_REF
elif ! MAIN_REF="$(git -C "$REPO" merge-base "origin/$BASE_BRANCH" HEAD 2>/dev/null)"; then
  echo "FAIL: cannot resolve the merge-base of origin/$BASE_BRANCH and HEAD, so the legacy parity check cannot run." \
    "Check out full history (actions/checkout fetch-depth: 0) or run \`git fetch origin $BASE_BRANCH\`, or set PARITY_MAIN_REF."
  exit 1
fi
echo "baseline (origin/$BASE_BRANCH): $MAIN_REF ($(git -C "$REPO" log -1 --format=%s "$MAIN_REF" | cut -c1-70))"
checkout_ref "$MAIN_REF" "$TMP/main"
printf 'networkPolicy:\n  mode: legacy\n' > "$TMP/mode-legacy.yaml"
for profile in "networkpolicy:np.yaml" "networkpolicy-explicit-legacy:np.yaml mode-legacy.yaml" "networkpolicy-legacy-keys:np-legacy-keys.yaml" "full-networkpolicy:full.yaml np.yaml"; do
  name=${profile%%:*}; read -ra files <<<"${profile#*:}"
  render "$TMP/main/$CHART_PATH" "$TMP/$name-main.yaml" "${files[@]}" || { fail=1; continue; }
  render "$HEAD_DIR" "$TMP/$name-head.yaml" "${files[@]}" || { fail=1; continue; }
  python3 "$TMP/compare.py" "$TMP/$name-main.yaml" "$TMP/$name-head.yaml" "legacy mode ($name) = main" "NetworkPolicy" || fail=1
done

# m) mode matrix. Expectations: legacy (main's policies, allow-all egress), perComponent-ingress (ing-*,
# allow-all egress), none (no NetworkPolicies), or fail:<message>.
check_mode() { # label, expectation, helm args...
  local label=$1 want=$2; shift 2
  if ! (cd "$HEAD_DIR" && helm template tfy . -n truefoundry -f "$TMP/min.yaml" "$@") >"$TMP/m.yaml" 2>"$TMP/m.err"; then
    if [[ $want == fail:* ]] && grep -qF "${want#fail:}" "$TMP/m.err"; then
      echo "ok: mode ($label): fails render"
    else
      echo "FAIL: mode ($label): unexpected render failure (want $want)"; grep -v coalesce "$TMP/m.err" | head -3 || true; fail=1
    fi
    return
  fi
  if [[ $want == fail:* ]]; then echo "FAIL: mode ($label): rendered, want a failure"; fail=1; return; fi
  python3 - "$TMP/m.yaml" "$label" "$want" <<'PY' || fail=1
import sys, yaml
names = {d["metadata"]["name"].split("-np-", 1)[-1] for d in yaml.safe_load_all(open(sys.argv[1])) if d and d["kind"] == "NetworkPolicy"}
legacy = "intra-instance" in names and "allow-all-egress" in names and not any(n.startswith("ing-") for n in names)
ingress = any(n.startswith("ing-") for n in names) and "intra-instance" not in names
got = ("none" if not names else "legacy" if legacy else
       "perComponent-ingress" if ingress and "allow-all-egress" in names else "unknown: " + ",".join(sorted(names)))
if got != sys.argv[3]:
    print(f"FAIL: mode ({sys.argv[2]}): got {got}, want {sys.argv[3]}")
    sys.exit(1)
print(f"ok: mode ({sys.argv[2]}): {got}")
PY
}
on=(--set networkPolicy.enabled=true)
check_mode "enabled, mode empty" legacy "${on[@]}"
check_mode "enabled, mode legacy" legacy "${on[@]}" --set networkPolicy.mode=legacy
check_mode "enabled, mode perComponent" perComponent-ingress "${on[@]}" --set networkPolicy.mode=perComponent
check_mode "enabled, mode perComponent, allowedIngressFrom" "fail:networkPolicy.allowedIngressFrom is only read in networkPolicy.mode: legacy" \
  "${on[@]}" --set networkPolicy.mode=perComponent --set "networkPolicy.allowedIngressFrom[0].namespace=ingress-nginx"
check_mode "enabled, mode bogus" 'fail:networkPolicy.mode must be empty, "legacy" or "perComponent"' "${on[@]}" --set networkPolicy.mode=bogus
for mode in "" legacy perComponent; do
  check_mode "disabled, mode '${mode}'" none --set "networkPolicy.mode=${mode}"
done

# b) everything but NetworkPolicies matches the base branch
if [[ -n "${PARITY_DEFAULTS_REF:-}" ]]; then
  DEFAULTS_REF="$(git -C "$REPO" merge-base "$PARITY_DEFAULTS_REF" HEAD)"
  echo "defaults: $PARITY_DEFAULTS_REF at $DEFAULTS_REF ($(git -C "$REPO" log -1 --format=%s "$DEFAULTS_REF" | cut -c1-70))"
  checkout_ref "$DEFAULTS_REF" "$TMP/defaults"
  KINDS="$(cd "$HEAD_DIR" && helm template tfy . -n truefoundry -f "$TMP/min.yaml" -f "$TMP/full.yaml" -f "$TMP/np.yaml" 2>/dev/null \
    | python3 -c 'import sys,yaml; print(",".join(sorted({d["kind"] for d in yaml.safe_load_all(sys.stdin) if d} - {"NetworkPolicy"})))')"
  for profile in "default:" "networkpolicy:np.yaml" "full:full.yaml" "full-networkpolicy:full.yaml np.yaml"; do
    name=${profile%%:*}; read -ra files <<<"${profile#*:}"
    render "$TMP/defaults/$CHART_PATH" "$TMP/$name-defaults.yaml" "${files[@]}" || { fail=1; continue; }
    render "$HEAD_DIR" "$TMP/$name-head.yaml" "${files[@]}" || { fail=1; continue; }
    python3 "$TMP/compare.py" "$TMP/$name-defaults.yaml" "$TMP/$name-head.yaml" "defaults ($name) = base branch, NetworkPolicies aside" "$KINDS" || fail=1
    if [[ -z "${files[*]}" || "${files[*]}" == full.yaml ]]; then
      n=$(count_np "$TMP/$name-head.yaml")
      if [[ $n == 0 ]]; then echo "ok: defaults ($name): no NetworkPolicies"; else echo "FAIL: defaults ($name): $n NetworkPolicies without networkPolicy.enabled"; fail=1; fi
    fi
  done
fi

exit "$fail"
