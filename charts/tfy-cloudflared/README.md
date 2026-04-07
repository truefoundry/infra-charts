# Tfy-cloudflared helm chart packaged by TrueFoundry
Tfy-cloudflared vendors the upstream Cloudflare Tunnel chart into this repository so it can be maintained and released from the TrueFoundry charts repo.

It deploys [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) for secure, outbound-only connections between services in your cluster and Cloudflare's network.

## Parameters

### Configuration values for tfy-cloudflared

| Name                                   | Description                                                 | Value                                            |
| -------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------ |
| `global.labels`                        | Global labels                                               | `{}`                                             |
| `global.annotations`                   | Global annotations                                          | `{}`                                             |
| `global.podLabels`                     | Global pod labels                                           | `{}`                                             |
| `global.podAnnotations`                | Global pod annotations                                      | `{}`                                             |
| `global.deploymentLabels`              | Global deployment labels                                    | `{}`                                             |
| `global.deploymentAnnotations`         | Global deployment annotations                               | `{}`                                             |
| `global.serviceLabels`                 | Global service labels                                       | `{}`                                             |
| `global.serviceAnnotations`            | Global service annotations                                  | `{}`                                             |
| `global.serviceAccount.labels`         | Global service account labels                               | `{}`                                             |
| `global.serviceAccount.annotations`    | Global service account annotations                          | `{}`                                             |
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
| `extraManifests`                       | Extra manifests to deploy alongside the chart               | `[]`                                             |
