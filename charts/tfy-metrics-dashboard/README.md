# tfy-metrics-dashboard

Helm chart for the TrueFoundry Metrics Dashboard.

## Parameters

| Name                  | Description                                                                   | Value                                        |
| --------------------- | ----------------------------------------------------------------------------- | -------------------------------------------- |
| `enabled`             | Deploy Metrics Dashboard Deployment and Service                               | `true`                                       |
| `nameOverride`        | Override the component name used in labels and the Deployment name            | `""`                                         |
| `fullnameOverride`    | If set, overrides the Deployment full name (leave empty for <release>-tfy-metrics-dashboard) | `""`              |
| `replicaCount`        | Number of replicas                                                            | `1`                                          |
| `image.registry`      | Image registry (optional, overrides repository prefix)                        | `""`                                         |
| `image.repository`    | Container image repository                                                    | `ghcr.io/truefoundry/tfy-metrics-dashboard`  |
| `image.tag`           | Image tag                                                                     | `78049faac40e566f3d7014a39a310593254c69c8`   |
| `imagePullPolicy`     | Image pull policy                                                             | `IfNotPresent`                               |
| `imagePullSecrets`    | Image pull secrets                                                            | `[]`                                         |
| `podSecurityContext`  | Pod-level security context                                                    | `{}`                                         |
| `securityContext`     | Container-level security context                                              | `{}`                                         |
| `service.type`        | Kubernetes Service type                                                       | `ClusterIP`                                  |
| `service.port`        | Kubernetes Service port                                                       | `80`                                         |
| `resources`           | CPU/Memory resource requests/limits                                           | `{}`                                         |
| `nodeSelector`        | Node labels for pod assignment                                                | `{}`                                         |
| `tolerations`         | Tolerations for pod assignment                                                | `[]`                                         |
| `affinity`            | Affinity for pod assignment                                                   | `{}`                                         |
