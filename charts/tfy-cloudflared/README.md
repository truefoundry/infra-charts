# Tfy-cloudflared helm chart packaged by TrueFoundry
Tfy-cloudflared vendors the upstream Cloudflare Tunnel chart into this repository so it can be maintained and released from the TrueFoundry charts repo.

It deploys [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) for secure, outbound-only connections between services in your cluster and Cloudflare's network.

This chart also deploys Caddy resources for private endpoint routing.

## Caddy private endpoint routing

When `caddy.enabled=true`, a Caddy reverse proxy is deployed alongside cloudflared. It accepts inbound requests forwarded by the Cloudflare tunnel and proxies them to in-cluster services.

### URL scheme

All requests must include a `<tunnel-identifier>` prefix segment immediately followed by the target address. Four address formats are supported:

| Format | Example URL | Backend transport |
| ------ | ----------- | ----------------- |
| `/<tunnel-identifier>/http://host:port[/path]` | `/my-tunnel/http://svc.ns.svc.cluster.local:8080/api` | Plain HTTP |
| `/<tunnel-identifier>/https://host:port[/path]` | `/my-tunnel/https://svc.ns.svc.cluster.local:443/api` | TLS (SNI from host) |
| `/<tunnel-identifier>/https/host:port[/path]` | `/my-tunnel/https/svc.ns.svc.cluster.local:443/api` | TLS (SNI from host) |
| `/<tunnel-identifier>/host:port[/path]` | `/my-tunnel/svc.ns.svc.cluster.local:8080/api` | Plain HTTP |

The `<tunnel-identifier>` segment is consumed by Caddy and is **not** forwarded to the upstream service. The remaining path after the host:port is forwarded as-is.

### Restricting upstream hosts (`caddy.allowedHosts`)

By default Caddy proxies to whatever `host:port` is present in the request path, i.e. any address reachable from the Caddy pod's network. In a shared cluster this means the blast radius is "anything the pod can reach", not just the services you intend to expose.

Set `caddy.allowedHosts` to lock routing down to an explicit allowlist:

```yaml
caddy:
  allowedHosts:
    - my-mcp-server.internal
    - some-svc.my-namespace.svc.cluster.local
```

When the list is non-empty, only those hostnames are routable across all four URL formats; requests to any other target return `404`. Entries are **hostnames only — do not include a port** (the port is still taken from the request path). Hostnames are matched exactly (regex metacharacters are escaped), so `svc.ns.svc.cluster.local` will not match `evil-svc.ns.svc.cluster.local`.

Onboarding a new host is a values change followed by `helm upgrade`. The Caddy config is mounted via `subPath` (which does not hot-reload), but the deployment carries a `checksum/config` annotation, so the upgrade rolls the Caddy pods automatically to pick up the new allowlist.

An empty list (the default) preserves the previous behaviour of proxying to any reachable host.

## Parameters

### Configuration values for tfy-cloudflared

| Name                                   | Description                                                 | Value                                            |
| -------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------ |
| `nameOverride`                         | Name override                                               | `""`                                             |
| `fullnameOverride`                     | Full name override for the tfy-cloudflared chart            | `""`                                             |
| `commonLabels`                         | Common labels added to all resources                        | `{}`                                             |
| `commonAnnotations`                    | Common annotations added to all resources                   | `{}`                                             |
| `image.repository`                     | Image repository for cloudflared                            | `tfy.jfrog.io/tfy-mirror/cloudflare/cloudflared` |
| `image.tag`                            | Image tag for cloudflared                                   | `2026.3.0`                                       |
| `image.pullPolicy`                     | Image pull policy                                           | `IfNotPresent`                                   |
| `imagePullSecrets`                     | Image pull secrets                                          | `[]`                                             |
| `tunnel.token`                         | Tunnel token obtained from the Cloudflare dashboard         | `""`                                             |
| `tunnel.existingSecret`                | Name of an existing secret containing the tunnel token      | `""`                                             |
| `tunnel.existingSecretKey`             | Key inside the existing secret that stores the tunnel token | `token`                                          |
| `cloudflared.logLevel`                 | Log level for the cloudflared process                       | `info`                                           |
| `cloudflared.noAutoupdate`             | Disable auto-update for cloudflared                         | `true`                                           |
| `cloudflared.metricsPort`              | Metrics listen port used for /ready and /metrics            | `2000`                                           |
| `cloudflared.extraArgs`                | Extra arguments appended to the cloudflared command         | `[]`                                             |
| `cloudflared.extraEnv`                 | Extra environment variables for the cloudflared container   | `[]`                                             |
| `replicaCount`                         | Number of cloudflared replicas to deploy                    | `2`                                              |
| `pdb.enabled`                          | Create a PodDisruptionBudget                                | `true`                                           |
| `pdb.minAvailable`                     | Minimum available replicas during voluntary disruptions     | `1`                                              |
| `pdb.labels`                           | PodDisruptionBudget labels                                  | `{}`                                             |
| `pdb.annotations`                      | PodDisruptionBudget annotations                             | `{}`                                             |
| `serviceAccount.create`                | Create a dedicated service account                          | `false`                                          |
| `serviceAccount.name`                  | Service account name                                        | `""`                                             |
| `serviceAccount.labels`                | Service account labels                                      | `{}`                                             |
| `serviceAccount.annotations`           | Service account annotations                                 | `{}`                                             |
| `service.type`                         | Service type                                                | `ClusterIP`                                      |
| `service.port`                         | Service port                                                | `2000`                                           |
| `service.labels`                       | Service labels                                              | `{}`                                             |
| `service.annotations`                  | Service annotations                                         | `{}`                                             |
| `metrics.enabled`                      | Expose the metrics service                                  | `true`                                           |
| `serviceMonitor.enabled`               | Create a ServiceMonitor                                     | `false`                                          |
| `serviceMonitor.interval`              | Prometheus scrape interval                                  | `30s`                                            |
| `serviceMonitor.additionalLabels`      | Additional labels for the ServiceMonitor                    | `{}`                                             |
| `serviceMonitor.additionalAnnotations` | Additional annotations for the ServiceMonitor               | `{}`                                             |
| `probes.startup.enabled`               | Enable the startup probe                                    | `true`                                           |
| `probes.startup.path`                  | Startup probe HTTP path                                     | `/ready`                                         |
| `probes.startup.initialDelaySeconds`   | Startup probe initial delay in seconds                      | `5`                                              |
| `probes.startup.periodSeconds`         | Startup probe period in seconds                             | `5`                                              |
| `probes.startup.timeoutSeconds`        | Startup probe timeout in seconds                            | `3`                                              |
| `probes.startup.failureThreshold`      | Startup probe failure threshold                             | `12`                                             |
| `probes.liveness.enabled`              | Enable the liveness probe                                   | `true`                                           |
| `probes.liveness.path`                 | Liveness probe HTTP path                                    | `/ready`                                         |
| `probes.liveness.initialDelaySeconds`  | Liveness probe initial delay in seconds                     | `0`                                              |
| `probes.liveness.periodSeconds`        | Liveness probe period in seconds                            | `15`                                             |
| `probes.liveness.timeoutSeconds`       | Liveness probe timeout in seconds                           | `5`                                              |
| `probes.liveness.failureThreshold`     | Liveness probe failure threshold                            | `3`                                              |
| `probes.readiness.enabled`             | Enable the readiness probe                                  | `true`                                           |
| `probes.readiness.path`                | Readiness probe HTTP path                                   | `/ready`                                         |
| `probes.readiness.initialDelaySeconds` | Readiness probe initial delay in seconds                    | `0`                                              |
| `probes.readiness.periodSeconds`       | Readiness probe period in seconds                           | `10`                                             |
| `probes.readiness.timeoutSeconds`      | Readiness probe timeout in seconds                          | `5`                                              |
| `probes.readiness.failureThreshold`    | Readiness probe failure threshold                           | `3`                                              |
| `resources`                            | Resource requests and limits for cloudflared                | `{}`                                             |
| `podSecurityContext`                   | Pod security context                                        | `{}`                                             |
| `securityContext`                      | Container security context                                  | `{}`                                             |
| `nodeSelector`                         | Node selector                                               | `{}`                                             |
| `tolerations`                          | Tolerations                                                 | `[]`                                             |
| `affinity`                             | Affinity                                                    | `{}`                                             |
| `topologySpreadConstraints`            | Topology spread constraints                                 | `[]`                                             |
| `priorityClassName`                    | PriorityClass name to assign to the pods                    | `""`                                             |
| `terminationGracePeriodSeconds`        | Termination grace period in seconds                         | `30`                                             |
| `podLabels`                            | Pod labels                                                  | `{}`                                             |
| `podAnnotations`                       | Pod annotations                                             | `{}`                                             |
| `deploymentLabels`                     | Deployment labels                                           | `{}`                                             |
| `deploymentAnnotations`                | Deployment annotations                                      | `{}`                                             |
| `extraVolumes`                         | Extra volumes                                               | `[]`                                             |
| `extraVolumeMounts`                    | Extra volume mounts                                         | `[]`                                             |

### Caddy private endpoint router configuration

| Name                               | Description                                                                                                                                                                                                                                                                                                         | Value                                 |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `caddy.enabled`                    | Deploy the Caddy private endpoint router manifests                                                                                                                                                                                                                                                                  | `true`                                |
| `caddy.allowedHosts`               | Restrict Caddy to proxy only these upstream hosts. Entries are hostnames without a port (e.g. `my-mcp-server.internal` or `svc.ns.svc.cluster.local`). An empty list allows any host reachable from the pod's network.                                                                                              | `[]`                                  |
| `caddy.networkPolicy.enabled`      | Create a NetworkPolicy that only allows cloudflared pods (plus any `caddy.networkPolicy.extraFrom` peers) to reach the Caddy router on port 80. Requires a CNI that enforces NetworkPolicy; it is inert otherwise. Kubelet health probes originate from the node and are not blocked by this policy on common CNIs. | `true`                                |
| `caddy.networkPolicy.extraFrom`    | Additional NetworkPolicyPeer entries appended to the ingress `from` list (e.g. another in-cluster gateway or a specific namespace).                                                                                                                                                                                 | `[]`                                  |
| `caddy.replicaCount`               | Number of Caddy replicas to deploy                                                                                                                                                                                                                                                                                  | `2`                                   |
| `caddy.image.repository`           | Image repository for Caddy                                                                                                                                                                                                                                                                                          | `public.ecr.aws/docker/library/caddy` |
| `caddy.image.tag`                  | Image tag for Caddy                                                                                                                                                                                                                                                                                                 | `2.6.3`                               |
| `caddy.image.pullPolicy`           | Image pull policy for Caddy                                                                                                                                                                                                                                                                                         | `IfNotPresent`                        |
| `caddy.service.type`               | Caddy service type                                                                                                                                                                                                                                                                                                  | `ClusterIP`                           |
| `caddy.service.annotations`        | Caddy service annotations                                                                                                                                                                                                                                                                                           | `{}`                                  |
| `caddy.service.ports.http`         | Caddy HTTP service port                                                                                                                                                                                                                                                                                             | `80`                                  |
| `caddy.serviceAccount.create`      | Create a dedicated Caddy service account                                                                                                                                                                                                                                                                            | `false`                               |
| `caddy.serviceAccount.name`        | Caddy service account name                                                                                                                                                                                                                                                                                          | `""`                                  |
| `caddy.serviceAccount.labels`      | Caddy service account labels                                                                                                                                                                                                                                                                                        | `{}`                                  |
| `caddy.serviceAccount.annotations` | Caddy service account annotations                                                                                                                                                                                                                                                                                   | `{}`                                  |
| `caddy.resources`                  | Resource requests and limits for Caddy                                                                                                                                                                                                                                                                              | `{}`                                  |
| `caddy.nodeSelector`               | Node selector for Caddy pods                                                                                                                                                                                                                                                                                        | `{}`                                  |
| `caddy.tolerations`                | Tolerations for Caddy pods                                                                                                                                                                                                                                                                                          | `[]`                                  |
| `caddy.affinity`                   | Affinity for Caddy pods                                                                                                                                                                                                                                                                                             | `{}`                                  |
| `extraManifests`                   | Extra manifests to deploy alongside the chart                                                                                                                                                                                                                                                                       | `[]`                                  |

## Upgrading

For breaking changes, version-by-version migration steps, and rollback instructions, see [CHANGELOG.md](./CHANGELOG.md).
