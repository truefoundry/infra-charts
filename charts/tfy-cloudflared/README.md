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

| Name                               | Description                                        | Value                                 |
| ---------------------------------- | -------------------------------------------------- | ------------------------------------- |
| `caddy.enabled`                    | Deploy the Caddy private endpoint router manifests | `true`                                |
| `caddy.replicaCount`               | Number of Caddy replicas to deploy                 | `2`                                   |
| `caddy.image.repository`           | Image repository for Caddy                         | `public.ecr.aws/docker/library/caddy` |
| `caddy.image.tag`                  | Image tag for Caddy                                | `2.6.3`                               |
| `caddy.image.pullPolicy`           | Image pull policy for Caddy                        | `IfNotPresent`                        |
| `caddy.service.type`               | Caddy service type                                 | `ClusterIP`                           |
| `caddy.service.annotations`        | Caddy service annotations                          | `{}`                                  |
| `caddy.service.ports.http`         | Caddy HTTP service port                            | `80`                                  |
| `caddy.serviceAccount.create`      | Create a dedicated Caddy service account           | `false`                               |
| `caddy.serviceAccount.name`        | Caddy service account name                         | `""`                                  |
| `caddy.serviceAccount.labels`      | Caddy service account labels                       | `{}`                                  |
| `caddy.serviceAccount.annotations` | Caddy service account annotations                  | `{}`                                  |
| `caddy.resources`                  | Resource requests and limits for Caddy             | `{}`                                  |
| `caddy.nodeSelector`               | Node selector for Caddy pods                       | `{}`                                  |
| `caddy.tolerations`                | Tolerations for Caddy pods                         | `[]`                                  |
| `caddy.affinity`                   | Affinity for Caddy pods                            | `{}`                                  |
| `extraManifests`                   | Extra manifests to deploy alongside the chart      | `[]`                                  |

## Migrating from the `/proxy/` URL scheme

Prior to this change, Caddy accepted URLs with an explicit `/proxy/` segment:

```
# Old scheme (no longer supported)
<tunnel-url>/proxy/http://host:port/path
<tunnel-url>/proxy/https://host:port/path
<tunnel-url>/proxy/https/host:port/path
<tunnel-url>/proxy/host:port/path
```

The `/proxy/` segment has been removed. The `<tunnel-identifier>` prefix is now **required**.

### Migration steps

1. **Identify all callers** that construct Caddy proxy URLs — SDKs, agents, platform services, scripts, or any code that builds URLs pointing at the Cloudflare tunnel endpoint.

2. **Rewrite URLs** using the following substitution rules (replace `<tunnel-identifier>` with your actual tunnel identifier):

   | Old URL | New URL |
   | ------- | ------- |
   | `.../proxy/http://host:port/path` | `.../<tunnel-identifier>/http://host:port/path` |
   | `.../proxy/https://host:port/path` | `.../<tunnel-identifier>/https://host:port/path` |
   | `.../proxy/https/host:port/path` | `.../<tunnel-identifier>/https/host:port/path` |
   | `.../proxy/host:port/path` | `.../<tunnel-identifier>/host:port/path` |

3. **Deploy the new chart version:**

   ```bash
   helm upgrade tfy-cloudflared truefoundry/tfy-cloudflared \
     --namespace tfy-cloudflared \
     --reuse-values
   ```

4. **Smoke-test** after the rollout completes:

   ```bash
   # Should return a response from your target service
   curl -v https://<tunnel-url>/<tunnel-identifier>/http://<host>:<port>/healthz
   ```

### Rollback

If you need to revert to the old `/proxy/` matchers while callers are updated, patch the configmap directly:

```bash
kubectl patch configmap tfy-cloudflared-caddy-config -n tfy-cloudflared \
  --type merge \
  -p '{"data":{"Caddyfile":"<old-caddyfile-content>"}}'

# Then restart Caddy to pick up the change
kubectl rollout restart deployment/tfy-cloudflared-caddy -n tfy-cloudflared
```

Alternatively, roll back the Helm release:

```bash
helm rollback tfy-cloudflared -n tfy-cloudflared
```

## Migrating from the `cloudflared` namespace

Starting with chart version `0.3.0`, the recommended install namespace is **`tfy-cloudflared`** (previously `cloudflared`). Caddy is also now enabled by default (`caddy.enabled=true`).

If you have an existing release in the `cloudflared` namespace, follow these steps to move it.

### Migration steps

1. **Capture the existing tunnel token** so the new release can reuse it:

   ```bash
   kubectl get secret -n cloudflared \
     -l app.kubernetes.io/instance=tfy-cloudflared \
     -o yaml > /tmp/cloudflared-secret.yaml
   ```

2. **Install the chart in the new namespace** (creates it if it doesn't exist):

   ```bash
   helm upgrade --install tfy-cloudflared truefoundry/tfy-cloudflared \
     --namespace tfy-cloudflared \
     --create-namespace \
     --reuse-values \
     -f <your-values-overrides>.yaml
   ```

3. **Verify the new release is healthy** before tearing down the old one:

   ```bash
   kubectl rollout status deployment -n tfy-cloudflared \
     -l app.kubernetes.io/instance=tfy-cloudflared --timeout=120s
   ```

4. **Uninstall the old release** once traffic is confirmed flowing through the new namespace:

   ```bash
   helm uninstall tfy-cloudflared -n cloudflared
   kubectl delete namespace cloudflared
   ```

> **Note:** Cloudflare tunnels are outbound-only — running the old and new releases in parallel during the cutover is safe; both will establish their own connections to Cloudflare's edge using the same token. Cut over by uninstalling the old release when ready.

### Rollback

If the new namespace deployment has issues, the old `cloudflared` namespace release is still active (assuming you haven't run step 4). Simply scale the new deployment down or uninstall it:

```bash
helm uninstall tfy-cloudflared -n tfy-cloudflared
```
