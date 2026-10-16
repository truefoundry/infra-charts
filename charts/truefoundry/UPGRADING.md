# Upgrading the truefoundry chart to 0.177.3

This release hardens the control plane. Most of it is on by default, and every item can be turned off
in your values. NetworkPolicies and mTLS stay off unless you turn them on.

## What changes for you

If you upgrade with unchanged values:

- **Service accounts.** tfy-proxy, sfy-manifest-service, tfy-controller, tfy-k8s-controller,
  tfy-infra-manager, tfy-otel-collector and the TrueForge sandbox server move to a new account,
  `truefoundry-restricted`. It has no RBAC and no mounted token. The accounts `sfy-manifest-service`,
  `tfy-controller`, `tfy-k8s-controller` and `tfy-infra-manager` are no longer created, so the
  upgrade deletes them.
- **Seccomp.** Every container the chart renders runs with the `RuntimeDefault` seccomp profile,
  except the privileged ones ([Seccomp coverage](#seccomp-coverage)). New with this release: TrueFoundry
  components, NATS (server and NATS Box), the LLM gateway, the otel collector, the TrueForge sandbox
  server, the build steps, the build Job and the buildkit placeholder pod, and from the bundled charts
  VictoriaLogs, its Vector log collector, the Grafana test pod and the Redis volume-permissions init
  container. The bundled Postgres, Redis, Grafana and Prometheus charts and the TrueForge server already
  ran with it.
- **Read-only root filesystems.** sfy-manifest-service, tfy-infra-manager and the NATS server get a
  read-only root, no privilege escalation and all capabilities dropped. sfy-manifest-service and
  tfy-infra-manager get a writable `/tmp`. Other components already ran this way.
- **tfy-infra-manager runs as a non-root user** (UID 1001) instead of the image's user.
- **TrueForge sandbox server** (when `trueforge.truefoundry.devSandboxServerEnabled`) gets a read-only
  root, no privilege escalation, all capabilities dropped and a writable `/tmp`. It still runs as root
  ([details](#llm-gateway-vector-and-trueforge-sandbox-server)).
- **Image builds.** Build steps, and the build Job when `tfyBuild.jobTemplate.enabled`, run without
  privilege escalation and with seccomp. The buildkitd service, the buildkitd sidecar and the SOCI
  index step stay privileged.
- **LLM gateway Vector** (when `tfy-llm-gateway.vector.enabled`) runs as non-root with a read-only
  root and no token.

Nothing changes for NetworkPolicies or mTLS unless you set them. If you already use
`networkPolicy.enabled: true`, you keep exactly the policies you have today.

## What to do before upgrading

1. **Find cloud identity on the moved components.** Render fails if `serviceAccount.annotations` is
   set under `sfyManifestService`, `tfyController`, `tfyK8sController`, `tfyInfraManager`, `tfyProxy`
   or `tfy-otel-collector` and that component has no account of its own, because the annotations
   would not be applied. tfy-proxy and tfy-otel-collector also no longer share the identity of the
   `truefoundry` account; render doesn't catch that one. If one of them needs cloud access, keep it on
   its own account ([Service accounts](#service-accounts)).
2. **Find references to the old account names** outside the chart: AWS IAM role trust policies and
   EKS Pod Identity associations, GKE Workload Identity bindings, Azure federated credentials,
   OpenShift SCC grants, Vault roles, and Kyverno, Gatekeeper or OPA policies.
3. **If your release is named `tfy`** and you run both the gateway Vector and `truefoundryMonitoring`
   logs, rename one of them first ([LLM gateway Vector](#llm-gateway-vector-and-trueforge-sandbox-server)). Render
   fails otherwise.
4. **Check custom images or sidecars** on sfy-manifest-service and tfy-infra-manager that write
   outside `/tmp`.
5. **Render and compare** before you apply:

   ```bash
   NS=truefoundry
   kubectl -n $NS get sa
   kubectl get rolebindings,clusterrolebindings -A -o wide \
     | grep -E "$NS/(sfy-manifest-service|tfy-controller|tfy-k8s-controller|tfy-infra-manager)"
   helm template truefoundry truefoundry/truefoundry --version 0.177.3 -n $NS -f my-values.yaml > new.yaml
   ```

If you can't fix something before the upgrade, turn that item off in your values for now (each section
below shows how), and turn it back on later.

## Service accounts

**What changes.** The components listed above run as `truefoundry-restricted`. Everything else
(servicefoundry-server, mlfoundry-server, deltafusion, workflow-admin, build jobs, the LLM gateway)
stays on `global.serviceAccount.name` (`truefoundry`) with its RBAC and cloud identity. The bootstrap
job keeps its own account. The deleted per-component accounts had no RBAC from the chart.

**What to set.** A component that needs a cloud identity must keep its own account. Set both `create`
and `name`; `create: true` on its own does nothing (tfy-proxy is the exception: `create: true` is
enough). Annotations without that fail render with `<component>.serviceAccount.annotations is set, but
<component> has no account of its own`. Keeping the old name means existing IAM trust policies,
bindings and federated credentials keep matching.

AWS (IRSA):

```yaml
tfyController:
  serviceAccount:
    create: true
    name: tfy-controller
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/tfy-controller
```

AWS (EKS Pod Identity): the same, without the annotation. The existing Pod Identity association keeps
working because the name doesn't change.

GCP (GKE Workload Identity):

```yaml
tfyController:
  serviceAccount:
    create: true
    name: tfy-controller
    annotations:
      iam.gke.io/gcp-service-account: tfy-controller@my-project.iam.gserviceaccount.com
```

Azure (Workload Identity) also needs the pod label:

```yaml
tfyController:
  serviceAccount:
    create: true
    name: tfy-controller
    annotations:
      azure.workload.identity/client-id: 00000000-0000-0000-0000-000000000000
  podLabels:
    azure.workload.identity/use: "true"
```

The same keys work for `sfyManifestService`, `tfyK8sController`, `tfyInfraManager` and
`tfy-otel-collector`; for tfy-proxy, set `tfyProxy.serviceAccount.create: true` and the annotations. To
keep tfy-proxy or tfy-otel-collector on `truefoundry`, set `tfyProxy.serviceAccount.name: truefoundry`
or `tfy-otel-collector.serviceAccount.name: truefoundry`, with no annotations on the component: they
would fail render, and the account's identity comes from `global.serviceAccount.annotations`. Don't
put cloud identity annotations on `global.restrictedServiceAccount`.

If you move a component to a different account instead, update the identity binding to the new
subject, `system:serviceaccount:<namespace>:<account>`: the IAM role trust policy or Pod Identity
association on AWS, the `roles/iam.workloadIdentityUser` binding on GCP, the federated credential on
Azure.

**Other references.** If you attach image pull secrets to ServiceAccount objects by hand, add them to
`truefoundry-restricted` too, or set `global.imagePullSecrets`. On OpenShift, grant your SCC to the new
account (`oc adm policy add-scc-to-user <SCC> -z truefoundry-restricted -n <namespace>`).

**Rename or bring your own account.** To use an account you create yourself, set
`global.restrictedServiceAccount.create: false` and create it before upgrading. To rename it, set the
TrueForge sandbox server's name too. If the sandbox server is on
(`trueforge.truefoundry.devSandboxServerEnabled`) and the names differ, render fails.

```yaml
global:
  restrictedServiceAccount:
    name: my-restricted
trueforge:
  tfy-sandbox-server:
    serviceAccount:
      name: my-restricted
```

**Roll back.** This restores the previous accounts. Copy any annotations you had onto these entries.
If the TrueForge sandbox server is on, the `trueforge.tfy-sandbox-server` lines are required. Without
them, render fails with `trueforge.tfy-sandbox-server.serviceAccount.name is "truefoundry-restricted",
but global.restrictedServiceAccount.enabled is false, so that account is not created`. With `null`,
the sandbox server runs on `global.serviceAccount.name`.

```yaml
global:
  restrictedServiceAccount:
    enabled: false
tfyController:
  serviceAccount: {create: true, name: tfy-controller}
tfyK8sController:
  serviceAccount: {create: true, name: tfy-k8s-controller}
sfyManifestService:
  serviceAccount: {create: true, name: sfy-manifest-service}
tfyInfraManager:
  serviceAccount: {create: true, name: tfy-infra-manager}
trueforge:
  tfy-sandbox-server:
    serviceAccount:
      name: null
```

## Seccomp, read-only root and non-root

**What changes.** These are set through the chart's usual security values:
`global.podSecurityContext`, `global.containerSecurityContext`, and each component's
`podSecurityContext` and `securityContext`. A component's own values win over the global ones.

| Item | Values that turn it on |
|------|------------------------|
| Seccomp `RuntimeDefault` | `global.podSecurityContext.seccompProfile`, and the same key under `tfy-llm-gateway.global` and `tfy-otel-collector.global`; NATS through `tfyNats.podTemplate.merge` and `tfyNats.natsBox.podTemplate.merge` |
| Seccomp on bundled charts | `truefoundryMonitoring.logs.victoria-logs-single.server.podSecurityContext`, `truefoundryMonitoring.logs.victoria-logs-single.vector.podSecurityContext`, `truefoundryMonitoring.grafana.testFramework.securityContext`, `redis.volumePermissions.containerSecurityContext` |
| sfy-manifest-service read-only root | `sfyManifestService.securityContext.readOnlyRootFilesystem: true` |
| tfy-infra-manager non-root and read-only root | `tfyInfraManager.podSecurityContext` (inherits the global UID 1001), `tfyInfraManager.securityContext` and `global.containerSecurityContext` |
| NATS server container | `tfyNats.container.merge.securityContext` |
| Build steps and build Job | `tfyBuild.truefoundryWorkflows.securityContext` |
| buildkit placeholder pod | `tfyBuild.preemptibleDeployment.podSecurityContext` and `securityContext` (inherit the global ones) |
| TrueForge sandbox server | `trueforge.tfy-sandbox-server.podSecurityContext`, `securityContext`, `extraEnv`, `extraVolumes` and `extraVolumeMounts` |

### Seccomp coverage

With every optional component on, each container the chart renders has a `RuntimeDefault` profile,
either on its pod or on the container, with these exceptions:

- **Privileged containers**: the buildkitd service, the buildkitd sidecar of the build workflow, and
  the SOCI index step. Kubernetes always runs privileged containers as `Unconfined`, so a profile on
  them would have no effect.
- **Argo's `init` and `wait` containers** in build workflow pods. Argo injects them, and their
  security context comes from the Argo controller's executor configuration, not from this chart.
- **Manifests you add** through `extraResources`.

**What to watch.** sfy-manifest-service and tfy-infra-manager can only write to `/tmp`; look for
`read-only file system` or `permission denied` in their logs. tfy-infra-manager can no longer write
files owned by root. Build scripts that use `sudo` fail. Sidecars that need syscalls blocked by
`RuntimeDefault` fail at start.

**What to set.** To keep one component writable, or add a writable path:

```yaml
sfyManifestService:
  securityContext:
    readOnlyRootFilesystem: false
tfyInfraManager:
  extraVolumes:
    - name: cache
      emptyDir:
        sizeLimit: 256Mi
  extraVolumeMounts:
    - name: cache
      mountPath: /app/cache        # the path your image writes to
```

The `/tmp` volume uses the container's `ephemeral-storage` limit. Set
`sfyManifestService.emptyDir.tmpdir.sizeLimit` or `tfyInfraManager.emptyDir.tmpdir.sizeLimit` to
change it.

**Roll back.** Use only the parts you need:

```yaml
# Seccomp, and the container defaults that tfy-infra-manager otherwise inherits
global:
  podSecurityContext:
    seccompProfile: null
  containerSecurityContext:
    readOnlyRootFilesystem: null
    allowPrivilegeEscalation: null
    capabilities: null
tfy-llm-gateway:
  global:
    podSecurityContext:
      seccompProfile: null
tfy-otel-collector:
  global:
    podSecurityContext:
      seccompProfile: null
# sfy-manifest-service and tfy-infra-manager
sfyManifestService:
  securityContext:
    readOnlyRootFilesystem: false
tfyInfraManager:
  podSecurityContext:
    enabled: false
  securityContext:
    runAsNonRoot: null
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: null
    capabilities: null
# Build steps, the build Job and the buildkit placeholder pod
tfyBuild:
  truefoundryWorkflows:
    securityContext: null
  preemptibleDeployment:
    podSecurityContext:
      enabled: false
    securityContext:
      enabled: false
# NATS: container, the pod security context without seccomp, and NATS Box
tfyNats:
  container:
    merge:
      securityContext: null
  podTemplate:
    merge:
      spec:
        securityContext:
          $tplYaml: |-
            {{- if .Values.global.podSecurityContext.enabled }}
            fsGroup: 1001
            runAsUser: 1001
            runAsGroup: 1001
            runAsNonRoot: true
            {{- end }}
  natsBox:
    podTemplate:
      merge: null
# Bundled charts
truefoundryMonitoring:
  logs:
    victoria-logs-single:
      server:
        podSecurityContext:
          seccompProfile: null
      vector:
        podSecurityContext:
          seccompProfile: null
  grafana:
    testFramework:
      securityContext: null
redis:
  volumePermissions:
    containerSecurityContext:
      seccompProfile: null
```

The `/tmp` volumes stay; they are harmless. The TrueForge sandbox server has its own roll-back block
([below](#llm-gateway-vector-and-trueforge-sandbox-server)).

## NetworkPolicies (opt-in)

**What changes.** Nothing, unless you set `networkPolicy.enabled: true`. `networkPolicy.mode` picks
the model:

- `legacy`: the policies earlier versions created. Release pods can reach each other, other
  namespaces need `networkPolicy.allowedIngressFrom`, and egress is open.
- `perComponent`: an ingress allow-list per component. Egress stays open.
- Empty (the default): `legacy`. Existing installs therefore keep their policies.

Render fails, rather than dropping rules, if you keep `allowedIngressFrom` or `extraIngress` in
`perComponent` mode. Move those entries to `networkPolicy.components.<component>`; see the
[README](README.md#per-component-rules).

**What to set.** Turn on your CNI's deny logging first, then switch to per-component ingress:

```yaml
networkPolicy:
  enabled: true
  mode: perComponent
  metricsFromNamespaces:        # your Prometheus, if it runs in another namespace
    - namespace: monitoring
      podSelector:
        app.kubernetes.io/name: prometheus
  agentFromNamespaces:          # a tfy-agent on the same cluster that dials the control plane directly
    - namespace: tfy-agent
```

**Roll back.** `mode: legacy` (or an empty `mode`) returns to the earlier policies.
`networkPolicy.enabled: false` removes all of them.

## mTLS (opt-in)

**What changes.** Nothing, unless you set `global.mTLS.enabled: true`. When on, control-plane services
serve HTTPS and present client certificates, and NATS serves TLS on 4222 (client certificate
required, `global.mTLS.nats.verifyClients`) and on its cluster routes (`clusterTLS`). The bootstrap job
issues the certificate before anything restarts. Ports, Services and NetworkPolicies don't change. On
earlier chart versions this setting does not turn on TLS for NATS, so upgrade first and turn mTLS on
as a separate change. The [README](README.md#mtls-optional) lists every component.

**Before turning it on:**

- If TrueForge is enabled, set `trueforge.mtls.enabled` to the same value. Render fails otherwise.
- A tfy-agent on the control-plane cluster that dials `tfy-controller:8123` directly needs a client
  certificate from the mTLS CA, or must connect through tfy-proxy like remote agents.
- `global.mTLS.nats.websocketTLS: true` also serves TLS on the NATS websocket port 8080, and requires
  a client certificate there unless `verifyClients` is `false`. tfy-proxy follows this setting. A
  tfy-agent that dials `tfy-nats:8080` directly must then use `wss://`, trust the mTLS CA and present
  a client certificate from it, or connect through tfy-proxy.
- The chart's ServiceMonitors switch to `https` by themselves. Other scrapers of the metrics ports
  must use `https`; the metrics paths don't need a client certificate.
- To bring your own certificate, set `global.mTLS.externalMtlsSecret` to a Secret with `tls.crt`,
  `tls.key` and `ca.crt`.

**What to set.** Each server serves either TLS or plain text, so the change needs a coordinated
restart. Clients that restart before their servers fail until the servers are ready. Let NATS accept
plain clients during the switch:

```yaml
global:
  mTLS:
    enabled: true
    nats:
      allowNonTLS: true
trueforge:              # only if TrueForge is enabled
  mtls:
    enabled: true
```

Upgrade, wait for NATS and the servers to become ready, and delete any pod still in
`CrashLoopBackOff`. Then remove `allowNonTLS` and upgrade again. Each change to `allowNonTLS`
restarts the NATS pods one at a time.

**Roll back.** Set `global.mTLS.enabled: false` (and `trueforge.mtls.enabled: false`), upgrade, and
restart anything left crash-looping. The certificate Secrets stay and are reused if you turn mTLS on
again.

## LLM gateway Vector and TrueForge sandbox server

**Vector hardening.** When `tfy-llm-gateway.vector.enabled` is on, the gateway's Vector runs as UID
1001 with `fsGroup: 1001`, seccomp, a read-only root and no token. On the first start, Kubernetes
changes the ownership of the existing buffer volume to the new group, which can take a while on large
buffers. To roll back:

```yaml
tfy-llm-gateway:
  vector:
    podSecurityContext: null
    securityContext: null
    serviceAccount:
      automountToken: true
```

**Vector name.** The gateway Vector is named `tfy-vector` and the `truefoundryMonitoring` log collector
is named `<release>-vector`. With the release name `tfy` they collide, and render fails. Rename the log
collector; it keeps its read position:

```yaml
truefoundryMonitoring:
  logs:
    victoria-logs-single:
      vector:
        fullnameOverride: tfy-log-collector
```

Renaming the gateway Vector instead (`tfy-llm-gateway.vector.fullnameOverride`) starts it with empty
buffer volumes, and spans still in the old buffer are not sent. See
[Vector name collision](README.md#vector-name-collision) before doing that.

**TrueForge sandbox server.** The TrueForge sandbox server
(`trueforge.truefoundry.devSandboxServerEnabled`) now runs on `truefoundry-restricted`, with the
`RuntimeDefault` seccomp profile, a read-only root, no privilege escalation and all capabilities
dropped. A `/tmp` emptyDir (1Gi) and `XDG_RUNTIME_DIR=/tmp` give it the scratch space it needs. It still
runs as root: the image's supervisord exits under any other user, so `runAsNonRoot` needs an image
change.

**What to watch.** Sandbox commands can't install system packages (for example with `apt-get`).
Without capabilities, root can only write files it owns, so the sandbox data volume must be owned by
root. A newly provisioned block volume (EBS, Persistent Disk, Azure Disk) is. If yours isn't, the
sandbox server logs `Permission denied: '/data/sandboxes/...'`. If you set
`trueforge.tfy-sandbox-server.extraEnv`, `extraVolumes` or `extraVolumeMounts`, your list replaces the
default one, so keep the `/tmp` entries in it.

**Roll back.**

```yaml
trueforge:
  tfy-sandbox-server:
    podSecurityContext: null
    securityContext: null
    extraEnv: null
    extraVolumes: null
    extraVolumeMounts: null
```

## Restore the previous behaviour

To upgrade without any of the defaults above, add all of this. Only the `/tmp` volumes on
sfy-manifest-service and tfy-infra-manager remain.

```yaml
global:
  podSecurityContext:
    seccompProfile: null
  containerSecurityContext:
    readOnlyRootFilesystem: null
    allowPrivilegeEscalation: null
    capabilities: null
  restrictedServiceAccount:
    enabled: false
tfyController:
  serviceAccount: {create: true, name: tfy-controller}
tfyK8sController:
  serviceAccount: {create: true, name: tfy-k8s-controller}
sfyManifestService:
  serviceAccount: {create: true, name: sfy-manifest-service}
  securityContext:
    readOnlyRootFilesystem: false
tfyInfraManager:
  serviceAccount: {create: true, name: tfy-infra-manager}
  podSecurityContext:
    enabled: false
  securityContext:
    runAsNonRoot: null
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: null
    capabilities: null
tfyBuild:
  truefoundryWorkflows:
    securityContext: null
  preemptibleDeployment:
    podSecurityContext:
      enabled: false
    securityContext:
      enabled: false
tfyNats:
  container:
    merge:
      securityContext: null
  podTemplate:
    merge:
      spec:
        securityContext:
          $tplYaml: |-
            {{- if .Values.global.podSecurityContext.enabled }}
            fsGroup: 1001
            runAsUser: 1001
            runAsGroup: 1001
            runAsNonRoot: true
            {{- end }}
  natsBox:
    podTemplate:
      merge: null
truefoundryMonitoring:
  logs:
    victoria-logs-single:
      server:
        podSecurityContext:
          seccompProfile: null
      vector:
        podSecurityContext:
          seccompProfile: null
  grafana:
    testFramework:
      securityContext: null
redis:
  volumePermissions:
    containerSecurityContext:
      seccompProfile: null
tfy-otel-collector:
  global:
    podSecurityContext:
      seccompProfile: null
tfy-llm-gateway:
  global:
    podSecurityContext:
      seccompProfile: null
  vector:
    podSecurityContext: null
    securityContext: null
    serviceAccount:
      automountToken: true
trueforge:
  tfy-sandbox-server:
    serviceAccount:
      name: null
    podSecurityContext: null
    securityContext: null
    extraEnv: null
    extraVolumes: null
    extraVolumeMounts: null
```

To undo the whole upgrade, use `helm rollback truefoundry <REVISION> -n <namespace>`, and revert any
IAM, SCC or policy changes you made for it.

## After upgrading

```bash
NS=truefoundry
kubectl -n $NS get pods -o custom-columns=POD:.metadata.name,SA:.spec.serviceAccountName,STATUS:.status.phase
kubectl -n $NS get sa
kubectl -n $NS get jobs
for d in sfy-manifest-service tfy-infra-manager; do
  kubectl -n $NS logs deploy/truefoundry-$d --since=30m | grep -Ei 'read-only file system|permission denied' || echo "$d: clean"
done
```

Then log in to the UI, deploy and delete a sample service, run an image build, and check that
components with cloud identity can still read and write object storage. If you turned on
NetworkPolicies, watch your CNI's deny logs; brief denies while pods start are normal and clear on
their own.
