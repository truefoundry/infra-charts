# tfy-monitoring-dashboards

Bundled monitoring dashboards for TrueFoundry: NATS UI, Metrics Dashboard, and Headlamp.

## Parameters

### Global parameters

| Name                                    | Description                                                         | Value |
| --------------------------------------- | ------------------------------------------------------------------- | ----- |
| `global.imagePullSecrets`               | Global image pull secrets                                           | `[]`  |
| `global.truefoundryImagePullConfigJSON` | JSON config for truefoundry image pull secret (auto-creates secret) | `""`  |

### NATS UI configuration

| Name                                                    | Description                                                         | Value                                      |
| ------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------ |
| `tfyNatsUi.enabled`                                     | Deploy NATS UI Deployment and Service                               | `false`                                    |
| `tfyNatsUi.nameOverride`                                | Override the component name used in labels and the Deployment name  | `""`                                       |
| `tfyNatsUi.fullnameOverride`                            | If set, overrides the Deployment full name                          | `""`                                       |
| `tfyNatsUi.replicaCount`                                | Number of replicas                                                  | `1`                                        |
| `tfyNatsUi.image.registry`                              | Image registry (optional)                                           | `tfy.jfrog.io`                             |
| `tfyNatsUi.image.repository`                            | Container image repository (required when enabled)                  | `tfy-private-images/nats-ui-dashboard`     |
| `tfyNatsUi.image.tag`                                   | Image tag                                                           | `78859f0304fc2081e835db5cfe7ba241f059fac6` |
| `tfyNatsUi.imagePullPolicy`                             | Image pull policy                                                   | `IfNotPresent`                             |
| `tfyNatsUi.imagePullSecrets`                            | Image pull secrets for this workload                                | `[]`                                       |
| `tfyNatsUi.serviceAccount.create`                       | Create a dedicated ServiceAccount                                   | `false`                                    |
| `tfyNatsUi.serviceAccount.name`                         | Override ServiceAccount name                                        | `""`                                       |
| `tfyNatsUi.serviceAccount.annotations`                  | Service account annotations                                         | `{}`                                       |
| `tfyNatsUi.serviceAccount.labels`                       | Extra labels for the ServiceAccount                                 | `{}`                                       |
| `tfyNatsUi.serviceAccount.automountServiceAccountToken` | Automount service account token                                     | `false`                                    |
| `tfyNatsUi.env`                                         | Environment variables (replaces natsUrl/accountSeedSecret when set) | `{}`                                       |
| `tfyNatsUi.envSecretName`                               | Secret name for shorthand ${k8s-secret/<key>} entries in env        | `""`                                       |
| `tfyNatsUi.natsUrl`                                     | NATS_URL env var when env is empty                                  | `http://{{ .Release.Name }}-tfy-nats:4222` |
| `tfyNatsUi.accountSeedSecret.name`                      | Existing Secret name when env is empty                              | `truefoundry-tfy-nats-secret`              |
| `tfyNatsUi.accountSeedSecret.key`                       | Key inside the Secret                                               | `NATS_CONTROLPLANE_ACCOUNT_SEED`           |
| `tfyNatsUi.service.name`                                | Kubernetes Service metadata.name                                    | `tfy-nats-ui`                              |
| `tfyNatsUi.service.type`                                | Service type                                                        | `ClusterIP`                                |
| `tfyNatsUi.service.port`                                | Service port                                                        | `8080`                                     |
| `tfyNatsUi.service.targetPort`                          | Container port (defaults to service.port)                           | `""`                                       |
| `tfyNatsUi.service.annotations`                         | Service annotations                                                 | `{}`                                       |
| `tfyNatsUi.extraEnv`                                    | Extra environment variables for the container                       | `[]`                                       |
| `tfyNatsUi.resources`                                   | Container resources                                                 | `{}`                                       |
| `tfyNatsUi.podSecurityContext`                          | Pod security context                                                | `{}`                                       |
| `tfyNatsUi.securityContext`                             | Container security context                                          | `{}`                                       |
| `tfyNatsUi.nodeSelector`                                | Node selector                                                       | `{}`                                       |
| `tfyNatsUi.tolerations`                                 | Tolerations                                                         | `[]`                                       |
| `tfyNatsUi.affinity`                                    | Affinity                                                            | `{}`                                       |

### Metrics Dashboard configuration

| Name                                                              | Description                                                                                                                    | Value                                      |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------ |
| `tfyMetricsDashboard.enabled`                                     | Deploy Metrics Dashboard Deployment and Service                                                                                | `false`                                    |
| `tfyMetricsDashboard.nameOverride`                                | Override the component name used in labels and the Deployment name                                                             | `""`                                       |
| `tfyMetricsDashboard.fullnameOverride`                            | If set, overrides the Deployment full name                                                                                     | `""`                                       |
| `tfyMetricsDashboard.replicaCount`                                | Number of replicas                                                                                                             | `1`                                        |
| `tfyMetricsDashboard.image.registry`                              | Image registry                                                                                                                 | `tfy.jfrog.io`                             |
| `tfyMetricsDashboard.image.repository`                            | Container image repository (path within registry)                                                                              | `tfy-private-images/tfy-metrics-dashboard` |
| `tfyMetricsDashboard.image.tag`                                   | Image tag                                                                                                                      | `78049faac40e566f3d7014a39a310593254c69c8` |
| `tfyMetricsDashboard.prometheusUrl`                               | Prometheus base URL accessible from the browser (nginx will proxy this). Leave empty to use the built-in nginx proxy path.     | `""`                                       |
| `tfyMetricsDashboard.targetNamespace`                             | Kubernetes namespace to scope PromQL queries (used as $namespace in queries)                                                   | `truefoundry`                              |
| `tfyMetricsDashboard.dashboardVisibility`                         | Per-dashboard visibility toggle keyed by filename. Set a key to false to hide that dashboard. E.g. {"deltafusion.json": false} | `{}`                                       |
| `tfyMetricsDashboard.imagePullPolicy`                             | Image pull policy                                                                                                              | `IfNotPresent`                             |
| `tfyMetricsDashboard.serviceAccount.create`                       | Create a dedicated ServiceAccount                                                                                              | `false`                                    |
| `tfyMetricsDashboard.serviceAccount.name`                         | Override ServiceAccount name                                                                                                   | `""`                                       |
| `tfyMetricsDashboard.serviceAccount.annotations`                  | Service account annotations                                                                                                    | `{}`                                       |
| `tfyMetricsDashboard.serviceAccount.labels`                       | Extra labels for the ServiceAccount                                                                                            | `{}`                                       |
| `tfyMetricsDashboard.serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                                | `false`                                    |
| `tfyMetricsDashboard.imagePullSecrets`                            | Image pull secrets                                                                                                             | `[]`                                       |
| `tfyMetricsDashboard.podSecurityContext`                          | Pod-level security context                                                                                                     | `{}`                                       |
| `tfyMetricsDashboard.securityContext`                             | Container-level security context                                                                                               | `{}`                                       |
| `tfyMetricsDashboard.service.type`                                | Kubernetes Service type                                                                                                        | `ClusterIP`                                |
| `tfyMetricsDashboard.service.port`                                | Kubernetes Service port                                                                                                        | `80`                                       |
| `tfyMetricsDashboard.resources`                                   | CPU/Memory resource requests/limits                                                                                            | `{}`                                       |
| `tfyMetricsDashboard.nodeSelector`                                | Node labels for pod assignment                                                                                                 | `{}`                                       |
| `tfyMetricsDashboard.tolerations`                                 | Tolerations for pod assignment                                                                                                 | `[]`                                       |
| `tfyMetricsDashboard.affinity`                                    | Affinity for pod assignment                                                                                                    | `{}`                                       |

### Headlamp configuration

| Name                                     | Description                                                                                                                                                          | Value               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `headlamp.enabled`                       | Deploy Headlamp                                                                                                                                                      | `false`             |
| `headlamp.clusterRoleBinding.create`     | Keep false — prevents headlamp subchart from creating a cluster-admin ClusterRoleBinding. Read-only RBAC is always created by this chart when headlamp.enabled=true. | `false`             |
| `headlamp.config.pluginsDir`             | Directory for Headlamp plugins                                                                                                                                       | `/headlamp/plugins` |
| `headlamp.persistentVolumeClaim.enabled` | Enable PVC for plugin storage                                                                                                                                        | `false`             |
| `headlamp.service.port`                  | Service port for Headlamp                                                                                                                                            | `4466`              |

