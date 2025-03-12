# Prometheus Config

This chart is used to configure prometheus. It is used to configure the scrape configs, alert managers, prometheus rules, and service monitors for prometheus.

## Parameters

### global Global settings for prometheus

| Name                 | Description | Value |
| -------------------- | ----------- | ----- |
| `global.labels`      |             | `{}`  |
| `global.annotations` |             | `{}`  |

### scrapeConfigs Scrape configs for prometheus

| Name                                              | Description                              | Value               |
| ------------------------------------------------- | ---------------------------------------- | ------------------- |
| `scrapeConfigs.envoy.enabled`                     | Enable scrape config for envoy           | `true`              |
| `scrapeConfigs.envoy.name`                        | Name of the scrape config                | `envoy-stats`       |
| `scrapeConfigs.envoy.jobName`                     | Job name for envoy                       | `envoy-stats`       |
| `scrapeConfigs.envoy.labels`                      | Labels for envoy                         | `{}`                |
| `scrapeConfigs.envoy.annotations`                 | Annotations for envoy                    | `{}`                |
| `scrapeConfigs.envoy.metricsPath`                 | Metrics path for envoy                   | `/stats/prometheus` |
| `scrapeConfigs.envoy.relabelings`                 | Relabelings for envoy                    | `[]`                |
| `scrapeConfigs.envoy.metricsRelabelings`          | Metrics relabelings for envoy            | `[]`                |
| `scrapeConfigs.kubernetesPods.enabled`            | Enable scrape config for kubernetes pods | `true`              |
| `scrapeConfigs.kubernetesPods.name`               | Name of the scrape config                | `kubernetes-pods`   |
| `scrapeConfigs.kubernetesPods.jobName`            | Job name for kubernetes pods             | `kubernetes-pods`   |
| `scrapeConfigs.kubernetesPods.labels`             | Labels for kubernetes pods               | `{}`                |
| `scrapeConfigs.kubernetesPods.annotations`        | Annotations for kubernetes pods          | `{}`                |
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

| Name                                         | Description                          | Value                                    |
| -------------------------------------------- | ------------------------------------ | ---------------------------------------- |
| `prometheusRules.containerRules.enabled`     | Enable prometheus rules for alerts   | `true`                                   |
| `prometheusRules.containerRules.name`        | Name of the prometheus rules         | `tfy-alertmanager-config-alerting-rules` |
| `prometheusRules.containerRules.labels`      | Labels for the prometheus rules      | `{}`                                     |
| `prometheusRules.containerRules.annotations` | Annotations for the prometheus rules | `{}`                                     |
| `prometheusRules.kubecostRules.enabled`      | Enable prometheus rules for kubecost | `true`                                   |
| `prometheusRules.kubecostRules.name`         | Name of the prometheus rules         | `tfy-alertmanager-config-kubecost-rules` |
| `prometheusRules.kubecostRules.labels`       | Labels for the prometheus rules      | `{}`                                     |
| `prometheusRules.kubecostRules.annotations`  | Annotations for the prometheus rules | `{}`                                     |

### serviceMonitors Service monitors for prometheus

| Name                                                         | Description                                       | Value                                     |
| ------------------------------------------------------------ | ------------------------------------------------- | ----------------------------------------- |
| `serviceMonitors.enabled`                                    | Enable service monitors for prometheus            | `true`                                    |
| `serviceMonitors.alertManager.enabled`                       | Enable service monitor for alert manager          | `true`                                    |
| `serviceMonitors.alertManager.name`                          | Name of the service monitor                       | `prometheus-kube-prometheus-alertmanager` |
| `serviceMonitors.alertManager.labels`                        | Labels for alert manager                          | `{}`                                      |
| `serviceMonitors.alertManager.annotations`                   | Annotations for alert manager                     | `{}`                                      |
| `serviceMonitors.alertManager.endpoints`                     | Endpoints for alert manager                       | `[]`                                      |
| `serviceMonitors.alertManager.serviceSelectorLabels`         | Service selector labels for alert manager         | `{}`                                      |
| `serviceMonitors.alertManager.namespaceSelector`             | Namespace selector for alert manager              | `{}`                                      |
| `serviceMonitors.workflows.enabled`                          | Enable service monitor for workflows              | `true`                                    |
| `serviceMonitors.workflows.name`                             | Name of the service monitor                       | `argo-workflows`                          |
| `serviceMonitors.workflows.annotations`                      | Annotations for workflows                         | `{}`                                      |
| `serviceMonitors.workflows.labels`                           | Labels for workflows                              | `{}`                                      |
| `serviceMonitors.workflows.jobLabel`                         | Job label for workflows                           | `app.kubernetes.io/instance`              |
| `serviceMonitors.workflows.endpoints`                        | Endpoints for workflows                           | `[]`                                      |
| `serviceMonitors.workflows.serviceSelectorLabels`            | Service selector labels for workflows             | `{}`                                      |
| `serviceMonitors.workflows.namespaceSelector`                | Namespace selector for workflows                  | `{}`                                      |
| `serviceMonitors.keda.enabled`                               | Enable service monitor for keda                   | `true`                                    |
| `serviceMonitors.keda.name`                                  | Name of the service monitor                       | `keda`                                    |
| `serviceMonitors.keda.labels`                                | Labels for keda                                   | `{}`                                      |
| `serviceMonitors.keda.annotations`                           | Annotations for keda                              | `{}`                                      |
| `serviceMonitors.keda.jobLabel`                              | Job label for keda                                | `app.kubernetes.io/instance`              |
| `serviceMonitors.keda.endpoints`                             | Endpoints for keda                                | `[]`                                      |
| `serviceMonitors.keda.serviceSelectorLabels`                 | Service selector labels for keda                  | `{}`                                      |
| `serviceMonitors.keda.namespaceSelector`                     | Namespace selector for keda                       | `{}`                                      |
| `serviceMonitors.sshServer.enabled`                          | Enable service monitor for ssh server             | `true`                                    |
| `serviceMonitors.sshServer.name`                             | Name of the service monitor                       | `ssh`                                     |
| `serviceMonitors.sshServer.labels`                           | Labels for ssh server                             | `{}`                                      |
| `serviceMonitors.sshServer.jobLabel`                         | Job label for ssh server                          | `truefoundry.com/component-type`          |
| `serviceMonitors.sshServer.endpoints`                        | Endpoints for ssh server                          | `[]`                                      |
| `serviceMonitors.sshServer.serviceSelectorLabels`            | Service selector labels for ssh server            | `{}`                                      |
| `serviceMonitors.sshServer.namespaceSelector`                | Namespace selector for ssh server                 | `{}`                                      |
| `serviceMonitors.gpu.labels`                                 | Labels for gpu                                    | `{}`                                      |
| `serviceMonitors.gpu.annotations`                            | Annotations for gpu                               | `{}`                                      |
| `serviceMonitors.gpu.operator.enabled`                       | Enable service monitor for gpu                    | `false`                                   |
| `serviceMonitors.gpu.operator.enabled`                       | Enable service monitor for gpu                    | `false`                                   |
| `serviceMonitors.gpu.operator.name`                          | Name of the service monitor                       | `gpu-operator`                            |
| `serviceMonitors.gpu.operator.jobLabel`                      | Job label for gpu                                 | `app`                                     |
| `serviceMonitors.gpu.operator.endpoints`                     | Endpoints for gpu                                 | `[]`                                      |
| `serviceMonitors.gpu.operator.serviceSelectorLabels`         | Service selector labels for gpu                   | `{}`                                      |
| `serviceMonitors.gpu.operator.namespaceSelector`             | Namespace selector for gpu                        | `{}`                                      |
| `serviceMonitors.gpu.dcgmExporter.enabled`                   | Enable service monitor for dcgm exporter          | `true`                                    |
| `serviceMonitors.gpu.dcgmExporter.name`                      | Name of the service monitor                       | `nvidia-dcgm-exporter`                    |
| `serviceMonitors.gpu.dcgmExporter.jobLabel`                  | Job label for dcgm exporter                       | `app`                                     |
| `serviceMonitors.gpu.dcgmExporter.endpoints`                 | Endpoints for dcgm exporter                       | `[]`                                      |
| `serviceMonitors.gpu.dcgmExporter.serviceSelectorLabels`     | Service selector labels for dcgm exporter         | `{}`                                      |
| `serviceMonitors.gpu.dcgmExporter.namespaceSelector`         | Namespace selector for dcgm exporter              | `{}`                                      |
| `serviceMonitors.karpenter.enabled`                          | Enable service monitor for karpenter              | `true`                                    |
| `serviceMonitors.karpenter.name`                             | Name of the service monitor                       | `karpenter`                               |
| `serviceMonitors.karpenter.namespace`                        | Namespace for karpenter                           | `kube-system`                             |
| `serviceMonitors.karpenter.labels`                           | Labels for karpenter                              | `{}`                                      |
| `serviceMonitors.karpenter.annotations`                      | Annotations for karpenter                         | `{}`                                      |
| `serviceMonitors.karpenter.namespaceSelector`                | Namespace selector for karpenter                  | `{}`                                      |
| `serviceMonitors.karpenter.endpoints`                        | Endpoints for karpenter                           | `[]`                                      |
| `serviceMonitors.karpenter.serviceSelectorLabels`            | Service selector labels for karpenter             | `{}`                                      |
| `serviceMonitors.kubecost.enabled`                           | Enable service monitor for kubecost               | `true`                                    |
| `serviceMonitors.kubecost.name`                              | Name of the service monitor                       | `kubecost`                                |
| `serviceMonitors.kubecost.labels`                            | Labels for kubecost                               | `{}`                                      |
| `serviceMonitors.kubecost.annotations`                       | Annotations for kubecost                          | `{}`                                      |
| `serviceMonitors.kubecost.jobLabel`                          | Job label for kubecost                            | `app.kubernetes.io/instance`              |
| `serviceMonitors.kubecost.endpoints`                         | Endpoints for kubecost                            | `[]`                                      |
| `serviceMonitors.kubecost.serviceSelectorLabels`             | Service selector labels for kubecost              | `{}`                                      |
| `serviceMonitors.kubecost.namespaceSelector`                 | Namespace selector for kubecost                   | `{}`                                      |
| `serviceMonitors.kubelet.enabled`                            | Enable service monitor for kubelet                | `true`                                    |
| `serviceMonitors.kubelet.name`                               | Name of the service monitor                       | `prometheus-kube-prometheus-kubelet`      |
| `serviceMonitors.kubelet.labels`                             | Labels for kubelet                                | `{}`                                      |
| `serviceMonitors.kubelet.annotations`                        | Annotations for kubelet                           | `{}`                                      |
| `serviceMonitors.kubelet.jobLabel`                           | Job label for kubelet                             | `k8s-app`                                 |
| `serviceMonitors.kubelet.endpoints`                          | Endpoints for kubelet                             | `[]`                                      |
| `serviceMonitors.kubelet.serviceSelectorLabels`              | Service selector labels for kubelet               | `{}`                                      |
| `serviceMonitors.kubelet.namespaceSelector`                  | Namespace selector for kubelet                    | `{}`                                      |
| `serviceMonitors.llmGateway.enabled`                         | Enable service monitor for llm gateway            | `false`                                   |
| `serviceMonitors.llmGateway.name`                            | Name of the service monitor                       | `tfy-llm-gateway`                         |
| `serviceMonitors.llmGateway.labels`                          | Labels for llm gateway                            | `{}`                                      |
| `serviceMonitors.llmGateway.annotations`                     | Annotations for llm gateway                       | `{}`                                      |
| `serviceMonitors.llmGateway.jobLabel`                        | Job label for llm gateway                         | `truefoundry.com/application`             |
| `serviceMonitors.llmGateway.endpoints`                       | Endpoints for llm gateway                         | `[]`                                      |
| `serviceMonitors.llmGateway.namespaceSelector`               | Namespace selector for llm gateway                | `{}`                                      |
| `serviceMonitors.llmGateway.serviceSelectorLabels`           | Service selector labels for llm gateway           | `{}`                                      |
| `serviceMonitors.nodeExporter.enabled`                       | Enable service monitor for node exporter          | `true`                                    |
| `serviceMonitors.nodeExporter.name`                          | Name of the service monitor                       | `prometheus-prometheus-node-exporter`     |
| `serviceMonitors.nodeExporter.labels`                        | Labels for node exporter                          | `{}`                                      |
| `serviceMonitors.nodeExporter.annotations`                   | Annotations for node exporter                     | `{}`                                      |
| `serviceMonitors.nodeExporter.jobLabel`                      | Job label for node exporter                       | `jobLabel`                                |
| `serviceMonitors.nodeExporter.endpoints`                     | Endpoints for node exporter                       | `[]`                                      |
| `serviceMonitors.nodeExporter.serviceSelectorLabels`         | Service selector labels for node exporter         | `{}`                                      |
| `serviceMonitors.nodeExporter.namespaceSelector`             | Namespace selector for node exporter              | `{}`                                      |
| `serviceMonitors.kubeStateMetrics.enabled`                   | Enable service monitor for kube state metrics     | `true`                                    |
| `serviceMonitors.kubeStateMetrics.name`                      | Name of the service monitor                       | `prometheus-kube-state-metrics`           |
| `serviceMonitors.kubeStateMetrics.labels`                    | Labels for kube state metrics                     | `{}`                                      |
| `serviceMonitors.kubeStateMetrics.annotations`               | Annotations for kube state metrics                | `{}`                                      |
| `serviceMonitors.kubeStateMetrics.jobLabel`                  | Job label for kube state metrics                  | `app.kubernetes.io/name`                  |
| `serviceMonitors.kubeStateMetrics.endpoints`                 | Endpoints for kube state metrics                  | `[]`                                      |
| `serviceMonitors.kubeStateMetrics.serviceSelectorLabels`     | Service selector labels for kube state metrics    | `{}`                                      |
| `serviceMonitors.prometheus.enabled`                         | Enable service monitor for prometheus             | `true`                                    |
| `serviceMonitors.prometheus.name`                            | Name of the service monitor                       | `prometheus`                              |
| `serviceMonitors.prometheus.labels`                          | Labels for prometheus                             | `{}`                                      |
| `serviceMonitors.prometheus.annotations`                     | Annotations for prometheus                        | `{}`                                      |
| `serviceMonitors.prometheus.jobLabel`                        | Job label for prometheus                          | `app.kubernetes.io/instance`              |
| `serviceMonitors.prometheus.endpoints`                       | Endpoints for prometheus                          | `[]`                                      |
| `serviceMonitors.prometheus.serviceSelectorLabels`           | Service selector labels for prometheus            | `{}`                                      |
| `serviceMonitors.prometheus.namespaceSelector`               | Namespace selector for prometheus                 | `{}`                                      |
| `serviceMonitors.prometheusOperator.enabled`                 | Enable service monitor for prometheus operator    | `true`                                    |
| `serviceMonitors.prometheusOperator.name`                    | Name of the service monitor                       | `prometheus-kube-prometheus-admission`    |
| `serviceMonitors.prometheusOperator.labels`                  | Labels for prometheus operator                    | `{}`                                      |
| `serviceMonitors.prometheusOperator.annotations`             | Annotations for prometheus operator               | `{}`                                      |
| `serviceMonitors.prometheusOperator.endpoints`               | Endpoints for prometheus operator                 | `[]`                                      |
| `serviceMonitors.prometheusOperator.serviceSelectorLabels`   | Service selector labels for prometheus operator   | `{}`                                      |
| `serviceMonitors.prometheusOperator.namespaceSelector`       | Namespace selector for prometheus operator        | `{}`                                      |
| `serviceMonitors.loki.enabled`                               | Enable service monitor for loki                   | `true`                                    |
| `serviceMonitors.loki.name`                                  | Name of the service monitor                       | `loki`                                    |
| `serviceMonitors.loki.labels`                                | Labels for loki                                   | `{}`                                      |
| `serviceMonitors.loki.annotations`                           | Annotations for loki                              | `{}`                                      |
| `serviceMonitors.loki.jobLabel`                              | Job label for loki                                | `app.kubernetes.io/instance`              |
| `serviceMonitors.loki.endpoints`                             | Endpoints for loki                                | `[]`                                      |
| `serviceMonitors.loki.serviceSelectorLabels`                 | Service selector labels for loki                  | `{}`                                      |
| `serviceMonitors.loki.namespaceSelector`                     | Namespace selector for loki                       | `{}`                                      |
| `serviceMonitors.loki.promtail.enabled`                      | Enable service monitor for promtail               | `true`                                    |
| `serviceMonitors.loki.promtail.name`                         | Name of the service monitor                       | `loki-promtail`                           |
| `serviceMonitors.loki.promtail.labels`                       | Labels for promtail                               | `{}`                                      |
| `serviceMonitors.loki.promtail.annotations`                  | Annotations for promtail                          | `{}`                                      |
| `serviceMonitors.loki.promtail.endpoints`                    | Endpoints for promtail                            | `[]`                                      |
| `serviceMonitors.loki.promtail.serviceSelectorLabels`        | Service selector labels for promtail              | `{}`                                      |
| `serviceMonitors.loki.promtail.namespaceSelector`            | Namespace selector for promtail                   | `{}`                                      |
| `serviceMonitors.nats.enabled`                               | Enable service monitor for nats                   | `false`                                   |
| `serviceMonitors.nats.name`                                  | Name of the service monitor                       | `truefoundry-nats`                        |
| `serviceMonitors.nats.labels`                                | Labels for nats                                   | `{}`                                      |
| `serviceMonitors.nats.annotations`                           | Annotations for nats                              | `{}`                                      |
| `serviceMonitors.nats.jobLabel`                              | Job label for nats                                | `app.kubernetes.io/name`                  |
| `serviceMonitors.nats.endpoints`                             | Endpoints for nats                                | `[]`                                      |
| `serviceMonitors.nats.serviceSelectorLabels`                 | Service selector labels for nats                  | `{}`                                      |
| `serviceMonitors.nats.namespaceSelector`                     | Namespace selector for nats                       | `{}`                                      |
| `serviceMonitors.servicefoundryServer.enabled`               | Enable service monitor for servicefoundry server  | `false`                                   |
| `serviceMonitors.servicefoundryServer.name`                  | Name of the service monitor                       | `""`                                      |
| `serviceMonitors.servicefoundryServer.labels`                | Labels for servicefoundry server                  | `{}`                                      |
| `serviceMonitors.servicefoundryServer.annotations`           | Annotations for servicefoundry server             | `{}`                                      |
| `serviceMonitors.servicefoundryServer.jobLabel`              | Job label for servicefoundry server               | `app.kubernetes.io/name`                  |
| `serviceMonitors.servicefoundryServer.endpoints`             | Endpoints for servicefoundry server               | `[]`                                      |
| `serviceMonitors.servicefoundryServer.serviceSelectorLabels` | Service selector labels for servicefoundry server | `{}`                                      |
| `serviceMonitors.servicefoundryServer.namespaceSelector`     | Namespace selector for servicefoundry server      | `{}`                                      |
| `serviceMonitors.sfyManifestService.enabled`                 | Enable service monitor for sfy manifest service   | `false`                                   |
| `serviceMonitors.sfyManifestService.name`                    | Name of the service monitor                       | `sfy-manifest-service`                    |
| `serviceMonitors.sfyManifestService.labels`                  | Labels for sfy manifest service                   | `{}`                                      |
| `serviceMonitors.sfyManifestService.annotations`             | Annotations for sfy manifest service              | `{}`                                      |
| `serviceMonitors.sfyManifestService.jobLabel`                | Job label for sfy manifest service                | `app.kubernetes.io/name`                  |
| `serviceMonitors.sfyManifestService.endpoints`               | Endpoints for sfy manifest service                | `[]`                                      |
| `serviceMonitors.sfyManifestService.serviceSelectorLabels`   | Service selector labels for sfy manifest service  | `{}`                                      |
| `serviceMonitors.sfyManifestService.namespaceSelector`       | Namespace selector for sfy manifest service       | `{}`                                      |
| `serviceMonitors.tfyController.enabled`                      | Enable service monitor for tfy-controller         | `false`                                   |
| `serviceMonitors.tfyController.name`                         | Name of the service monitor                       | `tfy-controller`                          |
| `serviceMonitors.tfyController.labels`                       | Labels for tfy-controller                         | `{}`                                      |
| `serviceMonitors.tfyController.annotations`                  | Annotations for tfy-controller                    | `{}`                                      |
| `serviceMonitors.tfyController.jobLabel`                     | Job label for tfy-controller                      | `app.kubernetes.io/name`                  |
| `serviceMonitors.tfyController.endpoints`                    | Endpoints for tfy-controller                      | `[]`                                      |
| `serviceMonitors.tfyController.serviceSelectorLabels`        | Service selector labels for tfy-controller        | `{}`                                      |
| `serviceMonitors.tfyController.namespaceSelector`            | Namespace selector for tfy-controller             | `{}`                                      |
| `serviceMonitors.tfyK8sController.enabled`                   | Enable service monitor for tfy-k8s-controller     | `false`                                   |
| `serviceMonitors.tfyK8sController.name`                      | Name of the service monitor                       | `tfy-k8s-controller`                      |
| `serviceMonitors.tfyK8sController.labels`                    | Labels for tfy-k8s-controller                     | `{}`                                      |
| `serviceMonitors.tfyK8sController.annotations`               | Annotations for tfy-k8s-controller                | `{}`                                      |
| `serviceMonitors.tfyK8sController.jobLabel`                  | Job label for tfy-k8s-controller                  | `app.kubernetes.io/name`                  |
| `serviceMonitors.tfyK8sController.endpoints`                 | Endpoints for tfy-k8s-controller                  | `[]`                                      |
| `serviceMonitors.tfyK8sController.serviceSelectorLabels`     | Service selector labels for tfy-k8s-controller    | `{}`                                      |
| `serviceMonitors.tfyK8sController.namespaceSelector`         | Namespace selector for tfy-k8s-controller         | `{}`                                      |
| `extraObjects`                                               | Extra objects for prometheus                      | `[]`                                      |
