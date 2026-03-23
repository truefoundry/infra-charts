# Truefoundry Control Plane Monitoring helm chart packaged by Truefoundry

This Helm chart package, provided by TrueFoundry, contains the components needed to monitor the control plane components           

## Parameters

### Global configuration

| Name                           | Description                                           | Value         |
| ------------------------------ | ----------------------------------------------------- | ------------- |
| `global.controlPlaneNamespace` | Namespace where TrueFoundry control plane is deployed | `truefoundry` |
| `global.imagePullSecrets`      | Global image pull secrets                             | `[]`          |

### External Services

| Name                                | Description                              | Value                                                                            |
| ----------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------- |
| `externalServices.prometheus.url`   | URL of an existing Prometheus instance   | `http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090` |
| `externalServices.victoriaLogs.url` | URL of an existing VictoriaLogs instance | `http://tfy-logs-victoria-logs-single-server.tfy-logs.svc.cluster.local:9428`    |

### Prometheus (kube-prometheus-stack) configuration

| Name                                                                   | Description                                                 | Value   |
| ---------------------------------------------------------------------- | ----------------------------------------------------------- | ------- |
| `prometheus.enabled`                                                   | Install a dedicated Prometheus for control plane monitoring | `true`  |
| `prometheus.cleanPrometheusOperatorObjectNames`                        | Clean object names (avoids redundant suffixes)              | `true`  |
| `prometheus.kubeStateMetrics.enabled`                                  | Enable kube-state-metrics                                   | `true`  |
| `prometheus.kube-state-metrics.metricLabelsAllowlist`                  | Metric labels to allow in kube-state-metrics                | `[]`    |
| `prometheus.kubelet.enabled`                                           | Enable kubelet/cadvisor metrics collection                  | `true`  |
| `prometheus.crds.enabled`                                              | Set to false if Prometheus Operator CRDs already exist      | `true`  |
| `prometheus.alertmanager.enabled`                                      | Enable alertmanager                                         | `false` |
| `prometheus.prometheusOperator.enabled`                                | Enable Prometheus Operator                                  | `true`  |
| `prometheus.prometheusOperator.resources`                              | Resources for Prometheus Operator                           | `{}`    |
| `prometheus.prometheus.prometheusSpec.retention`                       | Data retention period                                       | `15d`   |
| `prometheus.prometheus.prometheusSpec.retentionSize`                   | Maximum storage size before oldest data is removed          | `""`    |
| `prometheus.prometheus.prometheusSpec.resources`                       | Resources for Prometheus server                             | `{}`    |
| `prometheus.prometheus.prometheusSpec.storageSpec`                     | Storage configuration                                       | `{}`    |
| `prometheus.prometheus.prometheusSpec.serviceMonitorNamespaceSelector` | Namespace selector for ServiceMonitors                      | `{}`    |
| `prometheus.prometheus.prometheusSpec.podMonitorNamespaceSelector`     | Namespace selector for PodMonitors                          | `{}`    |
| `prometheus.prometheus.prometheusSpec.ruleNamespaceSelector`           | Namespace selector for PrometheusRules                      | `{}`    |
| `prometheus.prometheus.prometheusSpec.additionalScrapeConfigsSecret`   | Reference to the generated scrape config Secret             | `{}`    |
| `prometheus.prometheus.prometheusSpec.affinity`                        | Affinity for Prometheus pods                                | `{}`    |
| `prometheus.prometheus.prometheusSpec.tolerations`                     | Tolerations for Prometheus pods                             | `[]`    |
| `prometheus.prometheus.prometheusSpec.nodeSelector`                    | Node selector for Prometheus pods                           | `{}`    |

### Logs (victoria-logs-single) configuration

| Name                                       | Description                                                      | Value                                             |
| ------------------------------------------ | ---------------------------------------------------------------- | ------------------------------------------------- |
| `logs.enabled`                             | Install a dedicated VictoriaLogs + Vector for control plane logs | `true`                                            |
| `logs.global.image.registry`               | Image registry                                                   | `tfy.jfrog.io/tfy-mirror`                         |
| `logs.server.image.registry`               | Image registry                                                   | `tfy.jfrog.io/tfy-mirror`                         |
| `logs.server.retentionPeriod`              | Retention period for logs                                        | `15d`                                             |
| `logs.server.retentionMaxDiskUsagePercent` | Maximum disk usage percentage for retention                      | `85`                                              |
| `logs.server.persistentVolume.size`        | Persistent volume size                                           | `50Gi`                                            |
| `logs.server.resources`                    | Resources for VictoriaLogs server                                | `{}`                                              |
| `logs.server.affinity`                     | Affinity for VictoriaLogs server                                 | `{}`                                              |
| `logs.server.tolerations`                  | Tolerations for VictoriaLogs server                              | `[]`                                              |
| `logs.vector.enabled`                      | Enable Vector for log collection                                 | `true`                                            |
| `logs.vector.podPriorityClassName`         | Pod priority class name                                          | `system-node-critical`                            |
| `logs.vector.image.repository`             | Image repository                                                 | `public.ecr.aws/truefoundrycloud/timberio/vector` |
| `logs.vector.image.tag`                    | Image tag                                                        | `v0.52.0`                                         |
| `logs.vector.resources`                    | Resources for Vector                                             | `{}`                                              |
| `logs.vector.podSecurityContext`           | Pod-level security context for Vector                            | `{}`                                              |
| `logs.vector.securityContext`              | Container-level security context for Vector                      | `{}`                                              |
| `logs.vector.affinity`                     | Affinity for Vector pods                                         | `{}`                                              |
| `logs.vector.tolerations`                  | Tolerations for Vector pods                                      | `[]`                                              |
| `logs.vector.nodeSelector`                 | Node selector for Vector pods                                    | `{}`                                              |
| `logs.vector.customConfig`                 | Custom Vector config scoped to control plane                     | `{}`                                              |

### Grafana configuration

| Name                                                            | Description                                                      | Value                               |
| --------------------------------------------------------------- | ---------------------------------------------------------------- | ----------------------------------- |
| `grafana.enabled`                                               | Enable Grafana for control plane dashboards                      | `true`                              |
| `grafana.plugins`                                               | Grafana plugins to install                                       | `[]`                                |
| `grafana.replicas`                                              | Number of Grafana replicas                                       | `1`                                 |
| `grafana.useStatefulSet`                                        | Use StatefulSet for Grafana                                      | `true`                              |
| `grafana.resources`                                             | Resources for Grafana                                            | `{}`                                |
| `grafana.adminUser`                                             | Admin user for Grafana                                           | `admin`                             |
| `grafana.adminPassword`                                         | Admin password for Grafana (generate a random password if empty) | `""`                                |
| `grafana.initChownData.resources`                               | Resources for init-chown-data container                          | `{}`                                |
| `grafana.sidecar.resources`                                     | Resources for Grafana sidecar                                    | `{}`                                |
| `grafana.sidecar.dashboards.enabled`                            | Enable dashboard sidecar                                         | `true`                              |
| `grafana.sidecar.dashboards.label`                              | Label key for dashboard ConfigMaps                               | `truefoundry_monitoring`            |
| `grafana.sidecar.dashboards.labelValue`                         | Label value for dashboard ConfigMaps                             | `1`                                 |
| `grafana.sidecar.dashboards.folderAnnotation`                   | Annotation key used to determine dashboard folder                | `grafana_folder`                    |
| `grafana.sidecar.dashboards.SCProvider`                         | Enable sidecar provider                                          | `true`                              |
| `grafana.sidecar.dashboards.provider.foldersFromFilesStructure` | Use folder structure from files                                  | `true`                              |
| `grafana.sidecar.datasources.enabled`                           | Enable datasource sidecar                                        | `true`                              |
| `grafana.sidecar.datasources.label`                             | Label key for datasource ConfigMaps                              | `truefoundry_monitoring_datasource` |
| `grafana.sidecar.datasources.labelValue`                        | Label value for datasource ConfigMaps                            | `1`                                 |
| `grafana.persistence.enabled`                                   | Enable persistence for Grafana                                   | `true`                              |
| `grafana.persistence.type`                                      | Persistence type                                                 | `statefulset`                       |
| `grafana.persistence.size`                                      | Persistence size                                                 | `5Gi`                               |
| `grafana.affinity`                                              | Affinity for Grafana pods                                        | `{}`                                |
| `grafana.tolerations`                                           | Tolerations for Grafana pods                                     | `[]`                                |
| `grafana.nodeSelector`                                          | Node selector for Grafana pods                                   | `{}`                                |
