# tfy-metrics-dashboard

Helm chart for the TrueFoundry Metrics Dashboard.

## Parameters

| Name                                            | Description                                                                          | Value                                      |
| ----------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------ |
| `enabled`                                       | Deploy Metrics Dashboard Deployment and Service                                      | `true`                                     |
| `nameOverride`                                  | Override the component name used in labels and the Deployment name                   | `""`                                       |
| `fullnameOverride`                              | If set, overrides the Deployment full name (leave empty for <release>-tfy-metrics-dashboard) | `""`                               |
| `replicaCount`                                  | Number of replicas                                                                   | `1`                                        |
| `image.registry`                                | Image registry                                                                       | `ghcr.io`                                  |
| `image.repository`                              | Container image repository (path within registry)                                    | `truefoundry/tfy-metrics-dashboard`        |
| `image.tag`                                     | Image tag                                                                            | `78049faac40e566f3d7014a39a310593254c69c8` |
| `imagePullPolicy`                               | Image pull policy                                                                    | `IfNotPresent`                             |
| `serviceAccount.create`                         | Create a dedicated ServiceAccount                                                    | `false`                                    |
| `serviceAccount.name`                           | Override ServiceAccount name (defaults to fullname when create is true)              | `""`                                       |
| `serviceAccount.annotations`                    | Service account annotations                                                          | `{}`                                       |
| `serviceAccount.labels`                         | Extra labels for the ServiceAccount                                                  | `{}`                                       |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token into the pod (only used when create is true)         | `false`                                    |
| `imagePullSecrets`                              | Image pull secrets                                                                   | `[]`                                       |
| `podSecurityContext`                            | Pod-level security context                                                           | `{}`                                       |
| `securityContext`                               | Container-level security context                                                     | `{}`                                       |
| `service.type`                                  | Kubernetes Service type                                                              | `ClusterIP`                                |
| `service.port`                                  | Kubernetes Service port                                                              | `80`                                       |
| `resources`                                     | CPU/Memory resource requests/limits                                                  | `{}`                                       |
| `nodeSelector`                                  | Node labels for pod assignment                                                       | `{}`                                       |
| `tolerations`                                   | Tolerations for pod assignment                                                       | `[]`                                       |
| `affinity`                                      | Affinity for pod assignment                                                          | `{}`                                       |
