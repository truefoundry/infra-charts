# Truefoundry Control Plane Monitoring helm chart packaged by Truefoundry

This Helm chart package, provided by TrueFoundry, contains the components needed to monitor the control plane components           

## Parameters

### Global configuration

| Name                           | Description                                           | Value         |
| ------------------------------ | ----------------------------------------------------- | ------------- |
| `global.controlPlaneNamespace` | Namespace where TrueFoundry control plane is deployed | `truefoundry` |
| `global.imagePullSecrets`      | Global image pull secrets                             | `[]`          |

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

| Name                                                            | Description                                                                                                     | Value                                                        |
| --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `grafana.enabled`                                               | Enable Grafana for control plane dashboards                                                                     | `true`                                                       |
| `grafana.plugins`                                               | Grafana plugins to install                                                                                      | `[]`                                                         |
| `grafana.replicas`                                              | Number of Grafana replicas                                                                                      | `1`                                                          |
| `grafana.useStatefulSet`                                        | Use StatefulSet for Grafana                                                                                     | `true`                                                       |
| `grafana.resources`                                             | Resources for Grafana                                                                                           | `{}`                                                         |
| `grafana.grafana\.ini`                                          | Grafana INI configuration overrides                                                                             | `{}`                                                         |
| `grafana.grafana.ini.server.domain`                             | Domain for Grafana (e.g. mycluster.example.com)                                                                 | `""`                                                         |
| `grafana.grafana.ini.server.root_url`                           | Root URL for Grafana (subpath /admin/grafana via tfy-proxy)                                                     | `%(protocol)s://%(domain)s/admin/grafana`                    |
| `grafana.grafana.ini.server.enforce_domain`                     | Enforce domain for Grafana                                                                                      | `false`                                                      |
| `grafana.grafana.ini.server.serve_from_sub_path`                | Serve Grafana from a subpath                                                                                    | `true`                                                       |
| `grafana.grafana.ini.auth.jwt.enabled`                          | Enable JWT auth for Grafana                                                                                     | `true`                                                       |
| `grafana.grafana.ini.auth.jwt.email_claim`                      | JWT claim for email                                                                                             | `email`                                                      |
| `grafana.grafana.ini.auth.jwt.header_name`                      | Header carrying JWT for Grafana auth                                                                            | `X-TFY-AUTH`                                                 |
| `grafana.grafana.ini.auth.jwt.jwk_set_url`                      | JWKS URL (must match your global.controlPlaneURL, e.g. https://cp.example.com/api/svc/v1/keys/truefoundry/jwks) | `https://CONTROL_PLANE_URL/api/svc/v1/keys/TENANT_NAME/jwks` |
| `grafana.grafana.ini.auth.jwt.auto_sign_up`                     | Auto sign up Grafana users from JWT                                                                             | `true`                                                       |
| `grafana.grafana.ini.auth.jwt.username_claim`                   | JWT claim for username                                                                                          | `sub`                                                        |
| `grafana.grafana.ini.auth.jwt.skip_org_role_sync`               | Skip org role sync from JWT                                                                                     | `true`                                                       |
| `grafana.adminUser`                                             | Admin user for Grafana                                                                                          | `admin`                                                      |
| `grafana.adminPassword`                                         | Admin password for Grafana (generate a random password if empty)                                                | `""`                                                         |
| `grafana.initChownData.resources`                               | Resources for init-chown-data container                                                                         | `{}`                                                         |
| `grafana.sidecar.resources`                                     | Resources for Grafana sidecar                                                                                   | `{}`                                                         |
| `grafana.sidecar.dashboards.enabled`                            | Enable dashboard sidecar                                                                                        | `true`                                                       |
| `grafana.sidecar.dashboards.label`                              | Label key for dashboard ConfigMaps                                                                              | `truefoundry_monitoring`                                     |
| `grafana.sidecar.dashboards.labelValue`                         | Label value for dashboard ConfigMaps                                                                            | `1`                                                          |
| `grafana.sidecar.dashboards.folderAnnotation`                   | Annotation key used to determine dashboard folder                                                               | `grafana_folder`                                             |
| `grafana.sidecar.dashboards.SCProvider`                         | Enable sidecar provider                                                                                         | `true`                                                       |
| `grafana.sidecar.dashboards.provider.foldersFromFilesStructure` | Use folder structure from files                                                                                 | `true`                                                       |
| `grafana.sidecar.datasources.enabled`                           | Enable datasource sidecar                                                                                       | `true`                                                       |
| `grafana.sidecar.datasources.label`                             | Label key for datasource ConfigMaps                                                                             | `truefoundry_monitoring_datasource`                          |
| `grafana.sidecar.datasources.labelValue`                        | Label value for datasource ConfigMaps                                                                           | `1`                                                          |
| `grafana.persistence.enabled`                                   | Enable persistence for Grafana                                                                                  | `true`                                                       |
| `grafana.persistence.type`                                      | Persistence type                                                                                                | `statefulset`                                                |
| `grafana.persistence.size`                                      | Persistence size                                                                                                | `5Gi`                                                        |
| `grafana.affinity`                                              | Affinity for Grafana pods                                                                                       | `{}`                                                         |
| `grafana.tolerations`                                           | Tolerations for Grafana pods                                                                                    | `[]`                                                         |
| `grafana.nodeSelector`                                          | Node selector for Grafana pods                                                                                  | `{}`                                                         |
