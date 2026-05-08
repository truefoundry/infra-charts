# Truefoundry Control Plane Monitoring helm chart packaged by Truefoundry

This Helm chart package, provided by TrueFoundry, contains the components needed to monitor the control plane components           

## Parameters

### Global configuration

| Name                                    | Description                                                         | Value         |
| --------------------------------------- | ------------------------------------------------------------------- | ------------- |
| `global.controlPlaneNamespace`          | Namespace where TrueFoundry control plane is deployed               | `truefoundry` |
| `global.imagePullSecrets`               | Global image pull secrets                                           | `[]`          |
| `global.truefoundryImagePullConfigJSON` | JSON config for truefoundry image pull secret (auto-creates secret) | `""`          |

### External Services

| Name                                | Description                                                                                                                                                              | Value |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----- |
| `externalServices.prometheus.url`   | URL of an existing Prometheus instance. Must be set if prometheus.enabled=false. Example: http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090 | `""`  |
| `externalServices.victoriaLogs.url` | URL of an existing VictoriaLogs instance. Must be set if logs.enabled=false. Example: http://tfy-logs-victoria-logs-single-server.tfy-logs.svc.cluster.local:9428        | `""`  |

### Prometheus (kube-prometheus-stack) configuration

| Name                                                                   | Description                                                                                                                                                                                                                            | Value        |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `prometheus.enabled`                                                   | Install a dedicated Prometheus for control plane monitoring                                                                                                                                                                            | `true`       |
| `prometheus.nameOverride`                                              | Override the subchart name so the parent chart helpers can predict service names correctly. The kube-prometheus-stack subchart's .Chart.Name is "kube-prometheus-stack" regardless of the alias, so this override keeps names aligned. | `prometheus` |
| `prometheus.fullnameOverride`                                          | Override the subchart fullname. Leave empty to use the default (<release>-<nameOverride>) naming.                                                                                                                                      | `""`         |
| `prometheus.cleanPrometheusOperatorObjectNames`                        | Clean object names (avoids redundant suffixes)                                                                                                                                                                                         | `true`       |
| `prometheus.kubeStateMetrics.enabled`                                  | Enable kube-state-metrics                                                                                                                                                                                                              | `true`       |
| `prometheus.crds.enabled`                                              | Set to false if Prometheus Operator CRDs already exist                                                                                                                                                                                 | `true`       |
| `prometheus.alertmanager.enabled`                                      | Enable alertmanager                                                                                                                                                                                                                    | `false`      |
| `prometheus.prometheusOperator.enabled`                                | Enable Prometheus Operator                                                                                                                                                                                                             | `true`       |
| `prometheus.prometheusOperator.resources`                              | Resources for Prometheus Operator                                                                                                                                                                                                      | `{}`         |
| `prometheus.prometheus.prometheusSpec.retention`                       | Data retention period                                                                                                                                                                                                                  | `15d`        |
| `prometheus.prometheus.prometheusSpec.retentionSize`                   | Maximum storage size before oldest data is removed                                                                                                                                                                                     | `""`         |
| `prometheus.prometheus.prometheusSpec.resources`                       | Resources for Prometheus server                                                                                                                                                                                                        | `{}`         |
| `prometheus.prometheus.prometheusSpec.storageSpec`                     | Storage configuration                                                                                                                                                                                                                  | `{}`         |
| `prometheus.prometheus.prometheusSpec.serviceMonitorNamespaceSelector` | Namespace selector for ServiceMonitors                                                                                                                                                                                                 | `{}`         |
| `prometheus.prometheus.prometheusSpec.podMonitorNamespaceSelector`     | Namespace selector for PodMonitors                                                                                                                                                                                                     | `{}`         |
| `prometheus.prometheus.prometheusSpec.ruleNamespaceSelector`           | Namespace selector for PrometheusRules                                                                                                                                                                                                 | `{}`         |
| `prometheus.prometheus.prometheusSpec.additionalScrapeConfigsSecret`   | Reference to the generated scrape config Secret                                                                                                                                                                                        | `{}`         |
| `prometheus.prometheus.prometheusSpec.affinity`                        | Affinity for Prometheus pods                                                                                                                                                                                                           | `{}`         |
| `prometheus.prometheus.prometheusSpec.tolerations`                     | Tolerations for Prometheus pods                                                                                                                                                                                                        | `[]`         |
| `prometheus.prometheus.prometheusSpec.nodeSelector`                    | Node selector for Prometheus pods                                                                                                                                                                                                      | `{}`         |

### Logs (tfy-logs) configuration

| Name           | Description                                                      | Value  |
| -------------- | ---------------------------------------------------------------- | ------ |
| `logs.enabled` | Install a dedicated VictoriaLogs + Vector for control plane logs | `true` |

### logs.victoria-logs-single VictoriaLogs subchart configuration

| Name                                                            | Description                                  | Value                                             |
| --------------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------- |
| `logs.victoria-logs-single.global.image.registry`               | Image registry for VictoriaLogs              | `tfy.jfrog.io/tfy-mirror`                         |
| `logs.victoria-logs-single.server.image.registry`               | Image registry                               | `tfy.jfrog.io/tfy-mirror`                         |
| `logs.victoria-logs-single.server.retentionPeriod`              | Retention period for logs                    | `15d`                                             |
| `logs.victoria-logs-single.server.retentionMaxDiskUsagePercent` | Maximum disk usage percentage for retention  | `85`                                              |
| `logs.victoria-logs-single.server.persistentVolume.size`        | Persistent volume size                       | `50Gi`                                            |
| `logs.victoria-logs-single.server.resources`                    | Resources for VictoriaLogs server            | `{}`                                              |
| `logs.victoria-logs-single.server.affinity`                     | Affinity for VictoriaLogs server             | `{}`                                              |
| `logs.victoria-logs-single.server.tolerations`                  | Tolerations for VictoriaLogs server          | `[]`                                              |
| `logs.victoria-logs-single.vector.enabled`                      | Enable Vector for log collection             | `true`                                            |
| `logs.victoria-logs-single.vector.podPriorityClassName`         | Pod priority class name                      | `system-node-critical`                            |
| `logs.victoria-logs-single.vector.image.repository`             | Image repository                             | `public.ecr.aws/truefoundrycloud/timberio/vector` |
| `logs.victoria-logs-single.vector.image.tag`                    | Image tag                                    | `v0.52.0`                                         |
| `logs.victoria-logs-single.vector.resources`                    | Resources for Vector                         | `{}`                                              |
| `logs.victoria-logs-single.vector.podSecurityContext`           | Pod-level security context for Vector        | `{}`                                              |
| `logs.victoria-logs-single.vector.securityContext`              | Container-level security context for Vector  | `{}`                                              |
| `logs.victoria-logs-single.vector.affinity`                     | Affinity for Vector pods                     | `{}`                                              |
| `logs.victoria-logs-single.vector.tolerations`                  | Tolerations for Vector pods                  | `[]`                                              |
| `logs.victoria-logs-single.vector.nodeSelector`                 | Node selector for Vector pods                | `{}`                                              |
| `logs.victoria-logs-single.vector.customConfig`                 | Custom Vector config scoped to control plane | `{}`                                              |

### Grafana configuration

| Name                                                            | Description                                                      | Value                                     |
| --------------------------------------------------------------- | ---------------------------------------------------------------- | ----------------------------------------- |
| `grafana.enabled`                                               | Enable Grafana for control plane dashboards                      | `true`                                    |
| `grafana.plugins`                                               | Grafana plugins to install                                       | `[]`                                      |
| `grafana.replicas`                                              | Number of Grafana replicas                                       | `1`                                       |
| `grafana.useStatefulSet`                                        | Use StatefulSet for Grafana                                      | `true`                                    |
| `grafana.resources`                                             | Resources for Grafana                                            | `{}`                                      |
| `grafana.grafana\.ini`                                          | Grafana INI configuration overrides                              | `{}`                                      |
| `grafana.grafana.ini.server.domain`                             | Domain for Grafana (e.g. mycluster.example.com)                  | `""`                                      |
| `grafana.grafana.ini.server.root_url`                           | Root URL for Grafana (subpath /admin/grafana via tfy-proxy)      | `%(protocol)s://%(domain)s/admin/grafana` |
| `grafana.grafana.ini.server.enforce_domain`                     | Enforce domain for Grafana                                       | `false`                                   |
| `grafana.grafana.ini.server.serve_from_sub_path`                | Serve Grafana from a subpath                                     | `true`                                    |
| `grafana.grafana.ini.auth.anonymous.enabled`                    | Enable anonymous auth for Grafana                                | `true`                                    |
| `grafana.grafana.ini.auth.anonymous.enabled`                    | Enable anonymous auth for Grafana                                | `true`                                    |
| `grafana.grafana.ini.auth.anonymous.org_role`                   | Org role for anonymous auth                                      | `Admin`                                   |
| `grafana.adminUser`                                             | Admin user for Grafana                                           | `admin`                                   |
| `grafana.adminPassword`                                         | Admin password for Grafana (generate a random password if empty) | `""`                                      |
| `grafana.initChownData.resources`                               | Resources for init-chown-data container                          | `{}`                                      |
| `grafana.sidecar.resources`                                     | Resources for Grafana sidecar                                    | `{}`                                      |
| `grafana.sidecar.dashboards.enabled`                            | Enable dashboard sidecar                                         | `true`                                    |
| `grafana.sidecar.dashboards.label`                              | Label key for dashboard ConfigMaps                               | `truefoundry_monitoring`                  |
| `grafana.sidecar.dashboards.labelValue`                         | Label value for dashboard ConfigMaps                             | `1`                                       |
| `grafana.sidecar.dashboards.folderAnnotation`                   | Annotation key used to determine dashboard folder                | `grafana_folder`                          |
| `grafana.sidecar.dashboards.SCProvider`                         | Enable sidecar provider                                          | `true`                                    |
| `grafana.sidecar.dashboards.provider.foldersFromFilesStructure` | Use folder structure from files                                  | `true`                                    |
| `grafana.sidecar.datasources.enabled`                           | Enable datasource sidecar                                        | `true`                                    |
| `grafana.sidecar.datasources.label`                             | Label key for datasource ConfigMaps                              | `truefoundry_monitoring_datasource`       |
| `grafana.sidecar.datasources.labelValue`                        | Label value for datasource ConfigMaps                            | `1`                                       |
| `grafana.persistence.enabled`                                   | Enable persistence for Grafana                                   | `true`                                    |
| `grafana.persistence.type`                                      | Persistence type                                                 | `statefulset`                             |
| `grafana.persistence.size`                                      | Persistence size                                                 | `5Gi`                                     |
| `grafana.affinity`                                              | Affinity for Grafana pods                                        | `{}`                                      |
| `grafana.tolerations`                                           | Tolerations for Grafana pods                                     | `[]`                                      |
| `grafana.nodeSelector`                                          | Node selector for Grafana pods                                   | `{}`                                      |

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

| Name                                                              | Description                                                                                   | Value                                      |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `tfyMetricsDashboard.enabled`                                     | Deploy Metrics Dashboard Deployment and Service                                               | `false`                                    |
| `tfyMetricsDashboard.nameOverride`                                | Override the component name used in labels and the Deployment name                            | `""`                                       |
| `tfyMetricsDashboard.fullnameOverride`                            | If set, overrides the Deployment full name                                                    | `""`                                       |
| `tfyMetricsDashboard.replicaCount`                                | Number of replicas                                                                            | `1`                                        |
| `tfyMetricsDashboard.image.registry`                              | Image registry                                                                                | `tfy.jfrog.io`                             |
| `tfyMetricsDashboard.image.repository`                            | Container image repository (path within registry)                                             | `tfy-private-images/tfy-metrics-dashboard` |
| `tfyMetricsDashboard.image.tag`                                   | Image tag                                                                                     | `b6585fa000977af22096d3f6e75b8625a11df66a` |
| `tfyMetricsDashboard.prometheusUrl`                               | Prometheus base URL (required)                                                                | `""`                                       |
| `tfyMetricsDashboard.targetNamespace`                             | Kubernetes namespace to scope PromQL queries (used as $namespace in queries)                  | `truefoundry`                              |
| `tfyMetricsDashboard.dashboardVisibility`                         | Per-dashboard visibility toggle keyed by filename. Set a key to false to hide that dashboard. | `{}`                                       |
| `tfyMetricsDashboard.imagePullPolicy`                             | Image pull policy                                                                             | `IfNotPresent`                             |
| `tfyMetricsDashboard.serviceAccount.create`                       | Create a dedicated ServiceAccount                                                             | `false`                                    |
| `tfyMetricsDashboard.serviceAccount.name`                         | Override ServiceAccount name                                                                  | `""`                                       |
| `tfyMetricsDashboard.serviceAccount.annotations`                  | Service account annotations                                                                   | `{}`                                       |
| `tfyMetricsDashboard.serviceAccount.labels`                       | Extra labels for the ServiceAccount                                                           | `{}`                                       |
| `tfyMetricsDashboard.serviceAccount.automountServiceAccountToken` | Automount service account token                                                               | `false`                                    |
| `tfyMetricsDashboard.imagePullSecrets`                            | Image pull secrets                                                                            | `[]`                                       |
| `tfyMetricsDashboard.podSecurityContext`                          | Pod-level security context                                                                    | `{}`                                       |
| `tfyMetricsDashboard.securityContext`                             | Container-level security context                                                              | `{}`                                       |
| `tfyMetricsDashboard.service.type`                                | Kubernetes Service type                                                                       | `ClusterIP`                                |
| `tfyMetricsDashboard.service.port`                                | Kubernetes Service port                                                                       | `80`                                       |
| `tfyMetricsDashboard.resources`                                   | CPU/Memory resource requests/limits                                                           | `{}`                                       |
| `tfyMetricsDashboard.nodeSelector`                                | Node labels for pod assignment                                                                | `{}`                                       |
| `tfyMetricsDashboard.tolerations`                                 | Tolerations for pod assignment                                                                | `[]`                                       |
| `tfyMetricsDashboard.affinity`                                    | Affinity for pod assignment                                                                   | `{}`                                       |

### Headlamp configuration

| Name                                     | Description                                                                                                                                                          | Value               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `headlamp.enabled`                       | Deploy Headlamp                                                                                                                                                      | `false`             |
| `headlamp.clusterRoleBinding.create`     | Keep false - prevents headlamp subchart from creating a cluster-admin ClusterRoleBinding. Read-only RBAC is always created by this chart when headlamp.enabled=true. | `false`             |
| `headlamp.allowPodExec`                  | Allow shell/exec into pods from headlamp.                                                                                                                            | `false`             |
| `headlamp.config.inCluster`              | Use in-cluster auth mode. Must be false to enable the kubeconfig auto-auth bypass.                                                                                   | `false`             |
| `headlamp.config.baseURL`                | Base URL path at which Headlamp is served. Must match the proxy path prefix.                                                                                         | `/admin/kubernetes` |
| `headlamp.config.pluginsDir`             | Directory for Headlamp plugins                                                                                                                                       | `/headlamp/plugins` |
| `headlamp.persistentVolumeClaim.enabled` | Enable PVC for plugin storage                                                                                                                                        | `false`             |
| `headlamp.service.port`                  | Service port for Headlamp                                                                                                                                            | `4466`              |
