#!/usr/bin/env python3
"""Check rendered in-release call edges against the rendered NetworkPolicies.

Usage: check-networkpolicy-flows.py <rendered.yaml>

Call edges come from the manifests themselves. A workload calls a Service's pods on a port when
the Service name (or a <pod>.<headless-service> DNS name) appears in one of the workload's env
values, args, mounted ConfigMaps, or the ConfigMap / Secret keys it references, either:
  - with an explicit port (a pod DNS name uses the pod port; a Service port maps to its targetPort), or
  - without a port, after "://" or as the whole value (e.g. DB_HOST=<svc>.<ns>), when the Service
    exposes a single port.
Host names inside scripts or certificate SAN lists therefore do not count.

Each edge must be admitted by the destination's ingress policies. Edges seen only through envFrom of
a whole ConfigMap / Secret (which often carry keys the workload never uses) and declared container
ports that no ingress rule opens are reported as warnings.

In perComponent mode, every release pod must also be selected by a component ingress policy; a pod
covered only by default-deny-ingress has no networkPolicy.components entry and is reported.
"""
import base64
import re
import sys
from collections import defaultdict

import yaml

WORKLOAD_KINDS = ("Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob")


def pod_template(w):
    spec = w["spec"]
    if w["kind"] == "CronJob":
        spec = spec["jobTemplate"]["spec"]
    return spec["template"]


def matches(selector, labels):
    return all(labels.get(k) == v for k, v in (selector or {}).items())


def decode(v):
    try:
        return base64.b64decode(v).decode("utf-8", "replace")
    except Exception:
        return None


def main(path):
    docs = [d for d in yaml.safe_load_all(open(path)) if isinstance(d, dict) and d.get("kind")]
    cms = {d["metadata"]["name"]: d for d in docs if d["kind"] == "ConfigMap"}
    secrets = {d["metadata"]["name"]: d for d in docs if d["kind"] == "Secret"}
    policies = [d for d in docs if d["kind"] == "NetworkPolicy"]

    pods = []
    for w in docs:
        if w["kind"] not in WORKLOAD_KINDS:
            continue
        t = pod_template(w)
        labels = t["metadata"].get("labels") or {}
        ports = {}
        for c in t["spec"].get("containers", []):
            for p in c.get("ports") or []:
                ports[p.get("name") or str(p["containerPort"])] = p["containerPort"]
        pods.append({"id": f"{w['kind']}/{w['metadata']['name']}", "workload": w, "labels": labels,
                     "name": labels.get("app.kubernetes.io/name"), "ports": ports})

    services = {}
    for s in docs:
        if s["kind"] != "Service" or not s["spec"].get("selector"):
            continue
        backing = [p for p in pods if matches(s["spec"]["selector"], p["labels"])]
        if not backing:
            continue
        pmap = {}
        for sp in s["spec"].get("ports", []):
            tp = sp.get("targetPort", sp["port"])
            if isinstance(tp, str):
                tp = next((p["ports"][tp] for p in backing if tp in p["ports"]), sp["port"])
            pmap[sp["port"]] = int(tp)
        services[s["metadata"]["name"]] = {"pods": backing, "ports": pmap}

    def cm_value(name, key):
        cm = cms.get(name)
        return None if cm is None else (cm.get("data") or {}).get(key)

    def secret_value(name, key):
        sec = secrets.get(name)
        if sec is None:
            return None
        if key in (sec.get("stringData") or {}):
            return str(sec["stringData"][key])
        raw = (sec.get("data") or {}).get(key)
        return None if raw is None else decode(raw)

    def values_for(w):
        """(value, strong) pairs; strong=False for whole ConfigMaps / Secrets loaded via envFrom."""
        t = pod_template(w)["spec"]
        out = []
        for c in t.get("containers", []) + t.get("initContainers", []):
            for e in c.get("env") or []:
                if "value" in e:
                    out.append((str(e["value"]), True))
                ref = e.get("valueFrom") or {}
                if "configMapKeyRef" in ref:
                    v = cm_value(ref["configMapKeyRef"]["name"], ref["configMapKeyRef"]["key"])
                    if v is not None:
                        out.append((str(v), True))
                if "secretKeyRef" in ref:
                    v = secret_value(ref["secretKeyRef"]["name"], ref["secretKeyRef"]["key"])
                    if v is not None:
                        out.append((v, True))
            for ef in c.get("envFrom") or []:
                if "configMapRef" in ef and ef["configMapRef"]["name"] in cms:
                    out.extend((str(x), False) for x in (cms[ef["configMapRef"]["name"]].get("data") or {}).values())
                if "secretRef" in ef and ef["secretRef"]["name"] in secrets:
                    sec = secrets[ef["secretRef"]["name"]]
                    out.extend((str(x), False) for x in (sec.get("stringData") or {}).values())
                    out.extend((x, False) for x in map(decode, (sec.get("data") or {}).values()) if x)
            out.extend((str(a), True) for a in (c.get("args") or []) + (c.get("command") or []))
        for v in t.get("volumes") or []:
            if "configMap" in v and v["configMap"]["name"] in cms:
                out.extend((str(x), True) for x in (cms[v["configMap"]["name"]].get("data") or {}).values())
        return out

    # (src pod id, dst component, target port) -> (evidence, strong)
    edges = {}
    for p in pods:
        if not p["name"]:
            continue
        vals = values_for(p["workload"])
        for sname in sorted(services, key=len, reverse=True):
            info = services[sname]
            if p in info["pods"]:
                continue  # a workload addressing its own Service
            pat = re.compile(r"(?<![\w.-])(?:[a-z0-9-]+\.)?" + re.escape(sname) + r"(?:\.[a-z0-9-]+)*(?::(\d+))?(?![\w-])")
            for val, strong in vals:
                for m in pat.finditer(val):
                    if m.group(1):
                        port = int(m.group(1))
                        tport = info["ports"].get(port, port)
                    elif len(info["ports"]) == 1 and (val[: m.start()].endswith("://") or val.strip() == m.group(0)):
                        tport = next(iter(info["ports"].values()))
                    else:
                        continue
                    for dst in {q["name"] for q in info["pods"] if q["name"]}:
                        key = (p["id"], dst, tport)
                        prev = edges.get(key)
                        if prev is None or (strong and not prev[1]):
                            edges[key] = (m.group(0), strong)

    def selected(pol, labels, ptype):
        return ptype in pol["spec"].get("policyTypes", []) and matches(pol["spec"]["podSelector"].get("matchLabels"), labels)

    def peer_admits(peer, labels, policy_ns):
        if "ipBlock" in peer:
            return False
        if "namespaceSelector" in peer:
            ns = (peer["namespaceSelector"].get("matchLabels") or {}).get("kubernetes.io/metadata.name")
            if ns != policy_ns:
                return False
            return matches((peer.get("podSelector") or {}).get("matchLabels"), labels)
        return matches((peer.get("podSelector") or {}).get("matchLabels"), labels)

    def port_ok(rule, port):
        ports = rule.get("ports")
        return not ports or any(x.get("port") == port for x in ports)

    by_id = {p["id"]: p for p in pods}
    dst_labels = {}
    for p in pods:
        if p["name"]:
            dst_labels.setdefault(p["name"], p["labels"])

    errors, warns = set(), set()
    for (src_id, dst, port), (ev, strong) in sorted(edges.items()):
        src = by_id[src_id]
        sl, dl = src["labels"], dst_labels[dst]
        found = []
        ing = [pol for pol in policies if selected(pol, dl, "Ingress")]
        if ing and not any(
            port_ok(r, port) and ("from" not in r or any(peer_admits(f, sl, pol["metadata"].get("namespace")) for f in r["from"]))
            for pol in ing for r in pol["spec"].get("ingress") or []
        ):
            found.append(f"ingress: {src['name']} ({src_id}) -> {dst}:{port} not admitted (seen as {ev})")
        for f in found:
            (errors if strong else warns).add(f if strong else f + " [only via envFrom of a whole ConfigMap/Secret]")

    # perComponent coverage: a release pod picked up only by the blanket default-deny ingress policy
    # has no networkPolicy.components entry, so it accepts no traffic at all.
    if not any(pol["metadata"]["name"].endswith("-intra-instance") for pol in policies):
        for p in pods:
            ing = [pol for pol in policies if selected(pol, p["labels"], "Ingress")]
            if ing and not any((pol["spec"]["podSelector"].get("matchLabels") or {}).get("app.kubernetes.io/name") for pol in ing):
                errors.add(f"coverage: {p['name'] or '<no app.kubernetes.io/name>'} ({p['id']}) has no networkPolicy.components entry, so default-deny-ingress blocks all traffic to it")

    opened = defaultdict(set)
    for pol in policies:
        for p in pods:
            if p["name"] and selected(pol, p["labels"], "Ingress"):
                for r in pol["spec"].get("ingress") or []:
                    opened[p["id"]].update(x.get("port") for x in (r.get("ports") or [{"port": "*"}]))
    for p in pods:
        if p["name"] and p["ports"] and "*" not in opened[p["id"]] and any(selected(pol, p["labels"], "Ingress") for pol in policies):
            closed = sorted(set(p["ports"].values()) - opened[p["id"]])
            if closed:
                warns.add(f"{p['name']} ({p['id']}): declared container port(s) {closed} not opened by any ingress rule")

    for w in sorted(warns):
        print("warn:", w)
    if errors:
        print("rendered flow errors:\n  " + "\n  ".join(sorted(errors)))
        return 1
    print(f"ok: {len(edges)} rendered call edges admitted by ingress")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
