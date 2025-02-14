# Prometheus Config

This chart is used to configure prometheus. It is used to configure the scrape configs, alert managers, prometheus rules, and service monitors for prometheus.

## Parameters

### scrapeConfigs Scrape configs for prometheus

| Name                                              | Description                              | Value               |
| ------------------------------------------------- | ---------------------------------------- | ------------------- |
| `scrapeConfigs.envoy.enabled`                     | Enable scrape config for envoy           | `true`              |
| `scrapeConfigs.envoy.name`                        | Name of the scrape config                | `envoy-stats`       |
| `scrapeConfigs.envoy.jobName`                     | Job name for envoy                       | `envoy-stats`       |
| `scrapeConfigs.envoy.labels`                      | Labels for envoy                         | `{}`                |
| `scrapeConfigs.envoy.metricsPath`                 | Metrics path for envoy                   | `/stats/prometheus` |
| `scrapeConfigs.envoy.relabelings`                 | Relabelings for envoy                    | `[]`                |
| `scrapeConfigs.envoy.metricsRelabelings`          | Metrics relabelings for envoy            | `[]`                |
| `scrapeConfigs.kubernetesPods.enabled`            | Enable scrape config for kubernetes pods | `true`              |
| `scrapeConfigs.kubernetesPods.name`               | Name of the scrape config                | `kubernetes-pods`   |
| `scrapeConfigs.kubernetesPods.jobName`            | Job name for kubernetes pods             | `kubernetes-pods`   |
| `scrapeConfigs.kubernetesPods.labels`             | Labels for kubernetes pods               | `{}`                |
| `scrapeConfigs.kubernetesPods.relabelings`        | Relabelings for kubernetes pods          | `[]`                |
| `scrapeConfigs.kubernetesPods.metricsRelabelings` | Metrics relabelings for kubernetes pods  | `[]`                |
| `scrapeConfigs.additionalScrapeConfigs`           | Additional scrape configs for prometheus | `[]`                |

### alertManagers Alert managers for prometheus

| Name                               | Description                        | Value                     |
| ---------------------------------- | ---------------------------------- | ------------------------- |
| `alertManagers.tfyAgent.enabled`   | Enable alert manager for tfy-agent | `true`                    |
| `alertManagers.tfyAgent.name`      | Name of the alert manager          | `tfy-alertmanager-config` |
| `alertManagers.tfyAgent.route`     | Route for the alert manager        | `{}`                      |
| `alertManagers.tfyAgent.receivers` | Receivers for the alert manager    | `[]`                      |

### prometheusRules Prometheus rules for prometheus

| Name                                     | Description                          | Value                                    |
| ---------------------------------------- | ------------------------------------ | ---------------------------------------- |
| `prometheusRules.containerRules.enabled` | Enable prometheus rules for alerts   | `true`                                   |
| `prometheusRules.containerRules.name`    | Name of the prometheus rules         | `tfy-alertmanager-config-alerting-rules` |
| `prometheusRules.containerRules.labels`  | Labels for the prometheus rules      | `{}`                                     |
| `prometheusRules.kubecostRules.enabled`  | Enable prometheus rules for kubecost | `true`                                   |
| `prometheusRules.kubecostRules.name`     | Name of the prometheus rules         | `tfy-alertmanager-config-kubecost-rules` |
| `prometheusRules.kubecostRules.labels`   | Labels for the prometheus rules      | `{}`                                     |

### serviceMonitors Service monitors for prometheus

| Name                                                     | Description                                    | Value                                     |
| -------------------------------------------------------- | ---------------------------------------------- | ----------------------------------------- |
| `serviceMonitors.enabled`                                | Enable service monitors for prometheus         | `true`                                    |
| `serviceMonitors.alertManager.enabled`                   | Enable service monitor for alert manager       | `true`                                    |
| `serviceMonitors.alertManager.name`                      | Name of the service monitor                    | `prometheus-kube-prometheus-alertmanager` |
| `serviceMonitors.alertManager.labels`                    | Labels for alert manager                       | `{}`                                      |
| `serviceMonitors.alertManager.endpoints`                 | Endpoints for alert manager                    | `[]`                                      |
| `serviceMonitors.alertManager.serviceSelectorLabels`     | Service selector labels for alert manager      | `{}`                                      |
| `serviceMonitors.alertManager.namespaceSelector`         | Namespace selector for alert manager           | `{}`                                      |
| `serviceMonitors.workflows.enabled`                      | Enable service monitor for workflows           | `true`                                    |
| `serviceMonitors.workflows.name`                         | Name of the service monitor                    | `argo-workflows`                          |
| `serviceMonitors.workflows.labels`                       | Labels for workflows                           | `{}`                                      |
| `serviceMonitors.workflows.jobLabel`                     | Job label for workflows                        | `app.kubernetes.io/instance`              |
| `serviceMonitors.workflows.endpoints`                    | Endpoints for workflows                        | `[]`                                      |
| `serviceMonitors.workflows.serviceSelectorLabels`        | Service selector labels for workflows          | `{}`                                      |
| `serviceMonitors.workflows.namespaceSelector`            | Namespace selector for workflows               | `{}`                                      |
| `serviceMonitors.keda.enabled`                           | Enable service monitor for keda                | `true`                                    |
| `serviceMonitors.keda.name`                              | Name of the service monitor                    | `keda`                                    |
| `serviceMonitors.keda.labels`                            | Labels for keda                                | `{}`                                      |
| `serviceMonitors.keda.jobLabel`                          | Job label for keda                             | `app.kubernetes.io/instance`              |
| `serviceMonitors.keda.endpoints`                         | Endpoints for keda                             | `[]`                                      |
| `serviceMonitors.keda.serviceSelectorLabels`             | Service selector labels for keda               | `{}`                                      |
| `serviceMonitors.keda.namespaceSelector`                 | Namespace selector for keda                    | `{}`                                      |
| `serviceMonitors.elasti.enabled`                         | Enable service monitor for elasti              | `true`                                    |
| `serviceMonitors.elasti.name`                            | Name of the service monitor                    | `elasti-resolver`                         |
| `serviceMonitors.elasti.labels`                          | Labels for elasti                              | `{}`                                      |
| `serviceMonitors.elasti.jobLabel`                        | Job label for elasti                           | `app.kubernetes.io/prometheus`            |
| `serviceMonitors.elasti.endpoints`                       | Endpoints for elasti                           | `[]`                                      |
| `serviceMonitors.elasti.serviceSelectorLabels`           | Service selector labels for elasti             | `{}`                                      |
| `serviceMonitors.elasti.namespaceSelector`               | Namespace selector for elasti                  | `{}`                                      |
| `serviceMonitors.kubecost.enabled`                       | Enable service monitor for kubecost            | `true`                                    |
| `serviceMonitors.kubecost.name`                          | Name of the service monitor                    | `kubecost`                                |
| `serviceMonitors.kubecost.labels`                        | Labels for kubecost                            | `{}`                                      |
| `serviceMonitors.kubecost.jobLabel`                      | Job label for kubecost                         | `app.kubernetes.io/instance`              |
| `serviceMonitors.kubecost.endpoints`                     | Endpoints for kubecost                         | `[]`                                      |
| `serviceMonitors.kubecost.serviceSelectorLabels`         | Service selector labels for kubecost           | `{}`                                      |
| `serviceMonitors.kubecost.namespaceSelector`             | Namespace selector for kubecost                | `{}`                                      |
| `serviceMonitors.kubelet.enabled`                        | Enable service monitor for kubelet             | `true`                                    |
| `serviceMonitors.kubelet.name`                           | Name of the service monitor                    | `prometheus-kube-prometheus-kubelet`      |
| `serviceMonitors.kubelet.labels`                         | Labels for kubelet                             | `{}`                                      |
| `serviceMonitors.kubelet.jobLabel`                       | Job label for kubelet                          | `k8s-app`                                 |
| `serviceMonitors.kubelet.endpoints`                      | Endpoints for kubelet                          | `[]`                                      |
| `serviceMonitors.kubelet.serviceSelectorLabels`          | Service selector labels for kubelet            | `{}`                                      |
| `serviceMonitors.kubelet.namespaceSelector`              | Namespace selector for kubelet                 | `{}`                                      |
| `serviceMonitors.nodeExporter.enabled`                   | Enable service monitor for node exporter       | `true`                                    |
| `serviceMonitors.nodeExporter.name`                      | Name of the service monitor                    | `prometheus-prometheus-node-exporter`     |
| `serviceMonitors.nodeExporter.labels`                    | Labels for node exporter                       | `{}`                                      |
| `serviceMonitors.nodeExporter.jobLabel`                  | Job label for node exporter                    | `jobLabel`                                |
| `serviceMonitors.nodeExporter.endpoints`                 | Endpoints for node exporter                    | `[]`                                      |
| `serviceMonitors.nodeExporter.serviceSelectorLabels`     | Service selector labels for node exporter      | `{}`                                      |
| `serviceMonitors.nodeExporter.namespaceSelector`         | Namespace selector for node exporter           | `{}`                                      |
| `serviceMonitors.kubeStateMetrics.enabled`               | Enable service monitor for kube state metrics  | `true`                                    |
| `serviceMonitors.kubeStateMetrics.name`                  | Name of the service monitor                    | `prometheus-kube-state-metrics`           |
| `serviceMonitors.kubeStateMetrics.labels`                | Labels for kube state metrics                  | `{}`                                      |
| `serviceMonitors.kubeStateMetrics.jobLabel`              | Job label for kube state metrics               | `app.kubernetes.io/name`                  |
| `serviceMonitors.kubeStateMetrics.endpoints`             | Endpoints for kube state metrics               | `[]`                                      |
| `serviceMonitors.kubeStateMetrics.serviceSelectorLabels` | Service selector labels for kube state metrics | `{}`                                      |
| `serviceMonitors.prometheus.enabled`                     | Enable service monitor for prometheus          | `true`                                    |
| `serviceMonitors.prometheus.name`                        | Name of the service monitor                    | `prometheus`                              |
| `serviceMonitors.prometheus.labels`                      | Labels for prometheus                          | `{}`                                      |
| `serviceMonitors.prometheus.jobLabel`                    | Job label for prometheus                       | `app.kubernetes.io/instance`              |
| `serviceMonitors.prometheus.endpoints`                   | Endpoints for prometheus                       | `[]`                                      |
| `serviceMonitors.prometheus.serviceSelectorLabels`       | Service selector labels for prometheus         | `{}`                                      |
| `serviceMonitors.prometheus.namespaceSelector`           | Namespace selector for prometheus              | `{}`                                      |
| `serviceMonitors.loki.enabled`                           | Enable service monitor for loki                | `true`                                    |
| `serviceMonitors.loki.name`                              | Name of the service monitor                    | `loki`                                    |
| `serviceMonitors.loki.labels`                            | Labels for loki                                | `{}`                                      |
| `serviceMonitors.loki.jobLabel`                          | Job label for loki                             | `app.kubernetes.io/instance`              |
| `serviceMonitors.loki.endpoints`                         | Endpoints for loki                             | `[]`                                      |
| `serviceMonitors.loki.serviceSelectorLabels`             | Service selector labels for loki               | `{}`                                      |
| `serviceMonitors.loki.namespaceSelector`                 | Namespace selector for loki                    | `{}`                                      |
| `serviceMonitors.loki.promtail.enabled`                  | Enable service monitor for promtail            | `true`                                    |
| `serviceMonitors.loki.promtail.name`                     | Name of the service monitor                    | `loki-promtail`                           |
| `serviceMonitors.loki.promtail.labels`                   | Labels for promtail                            | `{}`                                      |
| `serviceMonitors.loki.promtail.endpoints`                | Endpoints for promtail                         | `[]`                                      |
| `serviceMonitors.loki.promtail.serviceSelectorLabels`    | Service selector labels for promtail           | `{}`                                      |
| `serviceMonitors.loki.promtail.namespaceSelector`        | Namespace selector for promtail                | `{}`                                      |
| `extraObjects`                                           | Extra objects for prometheus                   | `[]`                                      |



