#!/usr/bin/env python3
"""Check that global.mTLS renders a consistent mesh: every TLS client's target serves TLS.

Usage: check-mtls-consistency.py <rendered.yaml> [options]

  --expect-off            mTLS is off: nothing may serve or dial TLS because of it.
  --secret NAME           mTLS secret the NATS listeners must mount (default truefoundry-internal-tls).
  --nats-allow-non-tls    expect allow_non_tls on the NATS client port (and the pod annotation that rolls NATS).
  --nats-websocket-tls    expect TLS on the NATS websocket port (and tfy-proxy dialing it over TLS with
                          the mesh client cert).
  --no-nats-cluster-tls   expect plain NATS cluster routes.
  --no-nats-verify        expect the NATS client and websocket ports not to require client certificates.
  -v                      print every checked client -> server edge.

With mTLS on:
  - A workload dials its in-release URLs over TLS when its env sets TLS_ENABLED / MTLS_ENABLED to
    "true". It also serves TLS when TLS_MUTUAL / MTLS_ENABLED is "true" or its HTTP probes use HTTPS
    (TLS_ENABLED alone, e.g. on tfy-workflow-admin and the compaction CronJobs, is client-side only).
    A server's HTTP probes must all use HTTPS, and every TLS workload must mount the mTLS secret.
    Vector workloads (tfy-otel-buffer) serve TLS on the ports whose opentelemetry source enables tls.
  - TLS clients are those workloads, tfy-proxy routes that import internal_mtls, and any in-release
    https:// URL. Each target Service port (or <pod>.<headless-service> name) must be backed by a
    workload that serves TLS, except the plain-by-design Services listed in PLAIN_TARGETS.
  - NATS must serve TLS on 4222 from the mTLS secret with the CA, mutual unless --no-nats-verify;
    cluster routes and the websocket listener must match the flags, and a TLS websocket listener
    verifies client certificates exactly like 4222; tfy-proxy's /nats-websocket upstream must dial
    TLS, presenting the mesh client cert, exactly when the websocket listener serves it.
  - Every in-release host name a TLS client dials must be covered by a SAN of the bootstrap leaf.
"""
import argparse
import json
import re
import sys

import yaml

WORKLOAD_KINDS = ("Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob")
TLS_ENV = ("TLS_ENABLED", "MTLS_ENABLED")

# Services (by name without the release prefix) that stay on plain HTTP with mTLS on.
PLAIN_TARGETS = {
    "tfy-workflow-admin-server": "Flyte admin is outside the mesh",
    "spark-history-server": "spark-history-server is outside the mesh",
    "s3proxy": "s3proxy is outside the mesh",
    "tfy-proxy": "public edge, plain behind the ingress",
    "tfy-buildkitd-service": "uses its own buildkit TLS (tfyBuildkitdService.tls)",
}

URL_RE = re.compile(r"(?:(https?|nats|tls|wss?)://)?([a-z0-9][a-z0-9.-]*[a-z0-9]):(\d+)")


def pod_template(w):
    spec = w["spec"]
    if w["kind"] == "CronJob":
        spec = spec["jobTemplate"]["spec"]
    return spec["template"]


def vector_tls_ports(volumes, cms):
    """Ports a Vector workload (e.g. tfy-otel-buffer) serves TLS on, read from the opentelemetry
    sources in its mounted config. Vector has no TLS env or HTTPS probe for the generic check."""
    ports = set()
    for v in volumes:
        cm = cms.get((v.get("configMap") or {}).get("name"))
        for text in ((cm or {}).get("data") or {}).values():
            try:
                conf = yaml.safe_load(text)
            except yaml.YAMLError:
                continue
            if not isinstance(conf, dict):
                continue
            for src in (conf.get("sources") or {}).values():
                if not isinstance(src, dict) or src.get("type") != "opentelemetry":
                    continue
                for listener in (src.get("grpc"), src.get("http")):
                    if isinstance(listener, dict) and (listener.get("tls") or {}).get("enabled"):
                        ports.add(int(str(listener["address"]).rsplit(":", 1)[1]))
    return ports


def matches(selector, labels):
    return all(labels.get(k) == v for k, v in (selector or {}).items())


def parse_nats_conf(text):
    text = re.sub(r"^\s*include .*;\s*$", "", text, flags=re.M)
    text = text.replace("$SERVER_NAME", '"x"')
    text = re.sub(r":\s*(\d+(?:Ki|Mi|Gi|Ti|K|M|G|T|B))\s*([,\n}])", r': "\1"\2', text)
    return json.loads(text)


def san_covers(sans, host):
    for s in sans:
        if s == host:
            return True
        if s.startswith("*.") and "." in host and host.split(".", 1)[1] == s[2:]:
            return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rendered")
    ap.add_argument("--expect-off", action="store_true")
    ap.add_argument("--secret", default="truefoundry-internal-tls")
    ap.add_argument("--nats-allow-non-tls", action="store_true")
    ap.add_argument("--nats-websocket-tls", action="store_true")
    ap.add_argument("--no-nats-cluster-tls", action="store_true")
    ap.add_argument("--no-nats-verify", action="store_true")
    ap.add_argument("-v", "--verbose", action="store_true", help="print every checked client -> server edge")
    a = ap.parse_args()

    docs = [d for d in yaml.safe_load_all(open(a.rendered)) if isinstance(d, dict) and d.get("kind")]
    cms = {d["metadata"]["name"]: d for d in docs if d["kind"] == "ConfigMap"}
    errors = []

    def err(msg):
        errors.append(msg)

    def env_of(c):
        out = {}
        for e in c.get("env") or []:
            if "value" in e:
                out[e["name"]] = str(e["value"])
            ref = (e.get("valueFrom") or {}).get("configMapKeyRef")
            if ref:
                v = ((cms.get(ref["name"]) or {}).get("data") or {}).get(ref["key"])
                if v is not None:
                    out[e["name"]] = str(v)
        return out

    workloads = []
    for w in docs:
        if w["kind"] not in WORKLOAD_KINDS:
            continue
        t = pod_template(w)
        containers = t["spec"].get("containers", [])
        envs = [env_of(c) for c in containers]
        client = any(e.get(k) == "true" for e in envs for k in TLS_ENV)
        mutual = any(e.get(k) == "true" for e in envs for k in ("TLS_MUTUAL", "MTLS_ENABLED"))
        ports = {}
        probes = []
        for c in containers:
            for p in c.get("ports") or []:
                ports[p.get("name") or str(p["containerPort"])] = p["containerPort"]
            for pk in ("livenessProbe", "readinessProbe", "startupProbe"):
                hg = (c.get(pk) or {}).get("httpGet")
                if hg:
                    probes.append((c["name"], pk, hg.get("scheme", "HTTP")))
        labels = t["metadata"].get("labels") or {}
        https_probe = any(s == "HTTPS" for _, _, s in probes)
        volumes = t["spec"].get("volumes") or []
        workloads.append({"id": f"{w['kind']}/{w['metadata']['name']}", "w": w, "labels": labels,
                          "name": labels.get("app.kubernetes.io/name") or w["metadata"]["name"],
                          "client": client, "tls": mutual or (client and https_probe),
                          "tls_ports": vector_tls_ports(volumes, cms),
                          "envs": envs, "ports": ports, "probes": probes,
                          "volumes": volumes})

    services = {}
    for s in docs:
        if s["kind"] != "Service" or not s["spec"].get("selector"):
            continue
        backing = [w for w in workloads if matches(s["spec"]["selector"], w["labels"])]
        if not backing:
            continue
        pmap = {}
        for sp in s["spec"].get("ports", []):
            tp = sp.get("targetPort", sp["port"])
            if isinstance(tp, str):
                tp = next((w["ports"][tp] for w in backing if tp in w["ports"]), sp["port"])
            pmap[sp["port"]] = int(tp)
        services[s["metadata"]["name"]] = {"backing": backing, "ports": pmap,
                                           "headless": s["spec"].get("clusterIP") == "None"}
    pod_hosts = {}
    for w in workloads:
        if w["w"]["kind"] == "StatefulSet" and w["w"]["spec"].get("serviceName"):
            for i in range(int(w["w"]["spec"].get("replicas") or 1)):
                pod_hosts[f"{w['w']['metadata']['name']}-{i}.{w['w']['spec']['serviceName']}"] = (w, w["w"]["spec"]["serviceName"])

    ns = next((d["metadata"].get("namespace") for d in docs if d["metadata"].get("namespace")), "default")

    def resolve(host, port):
        """(workload, service name or None, container port) for an in-release host:port, else None."""
        base = host
        for suffix in (f".{ns}.svc.cluster.local", f".{ns}.svc", f".{ns}"):
            if base.endswith(suffix):
                base = base[: -len(suffix)]
                break
        if base in services and port in services[base]["ports"]:
            return services[base]["backing"][0], base, services[base]["ports"][port]
        if base in pod_hosts:
            return pod_hosts[base][0], pod_hosts[base][1], port
        return None

    nats = next((w for w in workloads if w["w"]["kind"] == "StatefulSet" and w["ports"].get("nats") == 4222), None)
    nats_cm = next((d for n, d in cms.items() if n.endswith("-tfy-nats-config")), None)
    nats_conf = parse_nats_conf(nats_cm["data"]["nats.conf"]) if nats_cm else {}
    ws_conf = nats_conf.get("websocket") or {}
    cluster_conf = nats_conf.get("cluster") or {}
    nats_ports = {"nats": bool(nats_conf.get("tls")), "websocket": bool(ws_conf.get("tls")),
                  "cluster": bool(cluster_conf.get("tls"))}

    def serves_tls(w, cport):
        if w is nats:
            name = next((n for n, p in w["ports"].items() if p == cport), None)
            return nats_ports.get(name, False)
        return w["tls"] or cport in w["tls_ports"]

    caddy = next((d["data"].get("Caddyfile") for n, d in cms.items() if n.endswith("-tfy-proxy")), "") or ""

    # ---------------------------------------------------------------- mTLS off
    if a.expect_off:
        for w in workloads:
            if w["client"]:
                err(f"{w['id']}: TLS env is on with mTLS off")
            for c, pk, scheme in w["probes"]:
                if scheme == "HTTPS" and w["name"] not in ("tfy-buildkitd-service",):
                    err(f"{w['id']}: {c} {pk} uses HTTPS with mTLS off")
            for v in w["volumes"]:
                if v["name"] in ("truefoundry-mtls", "nats-tls", "cluster-tls", "tls-ca"):
                    err(f"{w['id']}: mounts {v['name']} with mTLS off")
        if any(nats_ports.values()) or nats_conf.get("allow_non_tls"):
            err(f"tfy-nats: TLS configured with mTLS off: {nats_ports}")
        if "import internal_mtls" in caddy:
            err("tfy-proxy: imports internal_mtls with mTLS off")
        return report(errors)

    # ---------------------------------------------------------------- NATS
    if not nats or not nats_conf:
        err("tfy-nats StatefulSet / config not rendered")
    else:
        mounts = {v["name"]: (v.get("secret") or {}).get("secretName") for v in nats["volumes"]}
        client = nats_conf.get("tls") or {}
        if not client.get("cert_file") or not client.get("key_file"):
            err("tfy-nats: client port 4222 has no tls cert_file/key_file")
        if not client.get("ca_file"):
            err("tfy-nats: client port 4222 tls has no ca_file")
        if bool(client.get("verify")) == a.no_nats_verify:
            err(f"tfy-nats: client port verify={client.get('verify')}, expected {not a.no_nats_verify}")
        if mounts.get("nats-tls") != a.secret or mounts.get("tls-ca") != a.secret:
            err(f"tfy-nats: nats-tls / tls-ca must mount secret {a.secret}, got {mounts}")
        if bool(nats_conf.get("allow_non_tls")) != a.nats_allow_non_tls:
            err(f"tfy-nats: allow_non_tls={nats_conf.get('allow_non_tls')}, expected {a.nats_allow_non_tls}")
        ann = pod_template(nats["w"])["metadata"].get("annotations") or {}
        if ("truefoundry.com/nats-allow-non-tls" in ann) != a.nats_allow_non_tls:
            err("tfy-nats: pod template must carry truefoundry.com/nats-allow-non-tls exactly when allow_non_tls "
                "is on (nats-server cannot reload it, so toggling it has to roll the pods)")
        routes = cluster_conf.get("routes") or []
        want_cluster = not a.no_nats_cluster_tls
        if nats_ports["cluster"] != want_cluster:
            err(f"tfy-nats: cluster tls={nats_ports['cluster']}, expected {want_cluster}")
        if want_cluster and nats_ports["cluster"]:
            if not (cluster_conf["tls"].get("verify") and cluster_conf["tls"].get("ca_file")):
                err("tfy-nats: cluster tls must verify peers against ca_file")
            if mounts.get("cluster-tls") != a.secret:
                err(f"tfy-nats: cluster-tls must mount secret {a.secret}")
        if routes and any(r.startswith("tls://") != want_cluster for r in routes):
            err(f"tfy-nats: route URLs {routes} do not match cluster tls={want_cluster}")
        if nats_ports["websocket"] != a.nats_websocket_tls:
            err(f"tfy-nats: websocket tls={nats_ports['websocket']}, expected {a.nats_websocket_tls}")
        if not a.nats_websocket_tls and not ws_conf.get("no_tls"):
            err("tfy-nats: plain websocket must set no_tls")
        if nats_ports["websocket"]:
            wtls = ws_conf["tls"]
            if bool(wtls.get("verify")) == a.no_nats_verify:
                err(f"tfy-nats: websocket verify={wtls.get('verify')}, expected {not a.no_nats_verify} (follows verifyClients)")
            if not wtls.get("ca_file"):
                err("tfy-nats: websocket tls has no ca_file to verify client certificates against")
            if mounts.get("websocket-tls") != a.secret:
                err(f"tfy-nats: websocket-tls must mount secret {a.secret}, got {mounts.get('websocket-tls')}")

    # ---------------------------------------------------------------- probes vs server env
    for w in workloads:
        if w is nats:
            continue
        schemes = {s for _, _, s in w["probes"]}
        if w["tls"] and "HTTP" in schemes:
            err(f"{w['id']}: serves TLS but has an HTTP probe")
        if "HTTPS" in schemes and not w["client"]:
            err(f"{w['id']}: HTTPS probe but no TLS_ENABLED / MTLS_ENABLED")
        if (w["client"] or w["tls_ports"]) and not any(v["name"] in ("truefoundry-mtls", "mtls") for v in w["volumes"]):
            err(f"{w['id']}: TLS env or Vector source TLS is on but the mTLS secret is not mounted")

    # ---------------------------------------------------------------- clients -> targets
    edges = []  # (client id, how, host, port, scheme)
    for w in workloads:
        for e in w["envs"]:
            for k, v in e.items():
                for scheme, host, port in URL_RE.findall(v):
                    if w["client"] or scheme == "https":
                        edges.append((w["id"], f"env {k}", host, int(port), scheme))
    for m in re.finditer(r"(reverse_proxy|forward_auth)\s+(?:@\S+\s+)?([a-z0-9.-]+):(\d+)\s*\{(.*?)\n\s*\}", caddy, re.S):
        if "import internal_mtls" in m.group(4):
            edges.append(("tfy-proxy", f"Caddyfile {m.group(1)}", m.group(2), int(m.group(3)), "https"))
    ws = re.search(r"handle /nats-websocket/\* \{\s*reverse_proxy\s+([a-z0-9.-]+):(\d+)(.*?)\n  \}", caddy, re.S)
    if ws and bool(re.search(r"transport http \{\s*tls\b", ws.group(3))) != nats_ports["websocket"]:
        err(f"tfy-proxy: /nats-websocket dials TLS={not nats_ports['websocket']} but NATS websocket tls={nats_ports['websocket']}")
    if ws and nats_ports["websocket"] and "tls_client_auth /etc/tls/truefoundry/tls.crt /etc/tls/truefoundry/tls.key" not in ws.group(3):
        err("tfy-proxy: /nats-websocket dials TLS without presenting the mesh client cert")

    dialed_hosts = set()
    for client, how, host, port, scheme in edges:
        r = resolve(host, port)
        if r is None:
            continue
        target, svc, cport = r
        if svc and plain_by_design(svc) and scheme != "https":
            continue
        dialed_hosts.add(host)
        if a.verbose:
            print(f"edge: {client} ({how}) -> {host}:{port} = {target['id']}:{cport} tls={serves_tls(target, cport)}")
        if not serves_tls(target, cport):
            err(f"{client}: {how} dials {host}:{port} over TLS but {target['id']} serves plain on {cport}")

    # ---------------------------------------------------------------- leaf SANs
    boot = next((d for d in docs if d["kind"] == "Secret" and d["metadata"]["name"] == "truefoundry-bootstrap-secret"), None)
    if boot:
        script = (boot.get("stringData") or {}).get("truefoundry-bootstrap.sh", "")
        sans = re.findall(r'echo "DNS\.\d+ = ([^"]+)"', script)
        if sans:
            if nats_ports["cluster"]:
                dialed_hosts.update(r.split("://", 1)[1].rsplit(":", 1)[0] for r in cluster_conf.get("routes") or [])
            for name, svc in services.items():
                if not svc["headless"] and any(serves_tls(w, p) for w in svc["backing"] for p in svc["ports"].values()):
                    dialed_hosts.update((name, f"{name}.{ns}", f"{name}.{ns}.svc.cluster.local"))
            for h in sorted(dialed_hosts):
                if not san_covers(sans, h):
                    err(f"bootstrap leaf: no SAN covers {h}")
    return report(errors)


def plain_by_design(svc):
    return any(svc == k or svc.endswith("-" + k) for k in PLAIN_TARGETS)


def report(errors):
    for e in errors:
        print(f"FAIL: {e}")
    if errors:
        return 1
    print("ok: mTLS clients and servers agree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
