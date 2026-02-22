# Victoria Metrics Config

This chart is used to configure the scrape configs, alert managers, rules, and service scrape monitors for victoria metrics.

## Parameters

### global Global settings

| Name                 | Description                       | Value |
| -------------------- | --------------------------------- | ----- |
| `global.labels`      |                                   | `{}`  |
| `global.annotations` |                                   | `{}`  |
| `global.tenantName`  | Tenant name for the control plane | `""`  |

### controlPlaneMonitors service scrapes for control plane components

| Name                                                              | Description                                           | Value                                    |
| ----------------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------- |
| `controlPlaneMonitors.enabled`                                    | Enable service scrapes for control plane components   | `false`                                  |
| `controlPlaneMonitors.releaseNamespace`                           | Release namespace for the control plane               | `truefoundry`                            |
| `controlPlaneMonitors.namespaceSelector`                          | Namespace selector for the control plane monitors     | `{}`                                     |
| `controlPlaneMonitors.serviceSelectorLabel`                       | Service selector label for the control plane monitors | `app.kubernetes.io/name`                 |
| `controlPlaneMonitors.alerts.enabled`                             | Enable alerts for control plane                       | `false`                                  |
| `controlPlaneMonitors.alerts.alertRules.labels`                   | Labels for control plane alert rules                  | `{}`                                     |
| `controlPlaneMonitors.alerts.alertRules.annotations`              | Annotations for control plane alert rules             | `{}`                                     |
| `controlPlaneMonitors.alerts.alertRules.enabled`                  | Enable alert rules for control plane                  | `true`                                   |
| `controlPlaneMonitors.alerts.alertRules.name`                     | Name of the alert rules                               | `tfy-control-plane-alerting-rules`       |
| `controlPlaneMonitors.alerts.alertManager.enabled`                | Enable alert manager for control plane                | `true`                                   |
| `controlPlaneMonitors.alerts.alertManager.labels`                 | Labels for control plane alert manager                | `{}`                                     |
| `controlPlaneMonitors.alerts.alertManager.annotations`            | Annotations for control plane alert manager           | `{}`                                     |
| `controlPlaneMonitors.alerts.alertManager.name`                   | Name of the alert manager                             | `tfy-control-plane-alert-manager`        |
| `controlPlaneMonitors.alerts.alertManager.secret.create`          | Create a secret for the alert manager                 | `false`                                  |
| `controlPlaneMonitors.alerts.alertManager.secret.name`            | Name of the secret for the alert manager              | `tfy-control-plane-alert-manager-secret` |
| `controlPlaneMonitors.alerts.alertManager.secret.data`            | Data for the secret for the alert manager             | `{}`                                     |
| `controlPlaneMonitors.alerts.alertManager.route`                  | Route for the alert manager                           | `{}`                                     |
| `controlPlaneMonitors.alerts.alertManager.receivers`              | Receivers for the alert manager                       | `[]`                                     |
| `controlPlaneMonitors.servicefoundryServer.enabled`               | Enable service scrape for servicefoundry server       | `true`                                   |
| `controlPlaneMonitors.servicefoundryServer.name`                  | Name of the service scrape                            | `servicefoundry-server`                  |
| `controlPlaneMonitors.servicefoundryServer.labels`                | Labels for servicefoundry server                      | `{}`                                     |
| `controlPlaneMonitors.servicefoundryServer.annotations`           | Annotations for servicefoundry server                 | `{}`                                     |
| `controlPlaneMonitors.servicefoundryServer.endpoints`             | Endpoints for servicefoundry server                   | `[]`                                     |
| `controlPlaneMonitors.servicefoundryServer.serviceSelectorLabels` | Service selector labels for servicefoundry server     | `{}`                                     |
| `controlPlaneMonitors.servicefoundryServer.namespaceSelector`     | Namespace selector for servicefoundry server          | `{}`                                     |
| `controlPlaneMonitors.mlfoundryServer.enabled`                    | Enable service scrape for mlfoundry server            | `true`                                   |
| `controlPlaneMonitors.mlfoundryServer.name`                       | Name of the service scrape                            | `mlfoundry-server`                       |
| `controlPlaneMonitors.mlfoundryServer.labels`                     | Labels for mlfoundry server                           | `{}`                                     |
| `controlPlaneMonitors.mlfoundryServer.annotations`                | Annotations for mlfoundry server                      | `{}`                                     |
| `controlPlaneMonitors.mlfoundryServer.endpoints`                  | Endpoints for mlfoundry server                        | `[]`                                     |
| `controlPlaneMonitors.mlfoundryServer.serviceSelectorLabels`      | Service selector labels for mlfoundry server          | `{}`                                     |
| `controlPlaneMonitors.mlfoundryServer.namespaceSelector`          | Namespace selector for mlfoundry server               | `{}`                                     |
| `controlPlaneMonitors.sfyManifestService.enabled`                 | Enable service scrape for sfy manifest service        | `true`                                   |
| `controlPlaneMonitors.sfyManifestService.name`                    | Name of the service scrape                            | `sfy-manifest-service`                   |
| `controlPlaneMonitors.sfyManifestService.labels`                  | Labels for sfy manifest service                       | `{}`                                     |
| `controlPlaneMonitors.sfyManifestService.annotations`             | Annotations for sfy manifest service                  | `{}`                                     |
| `controlPlaneMonitors.sfyManifestService.endpoints`               | Endpoints for sfy manifest service                    | `[]`                                     |
| `controlPlaneMonitors.sfyManifestService.serviceSelectorLabels`   | Service selector labels for sfy manifest service      | `{}`                                     |
| `controlPlaneMonitors.sfyManifestService.namespaceSelector`       | Namespace selector for sfy manifest service           | `{}`                                     |
| `controlPlaneMonitors.tfyController.enabled`                      | Enable service scrape for tfy-controller              | `true`                                   |
| `controlPlaneMonitors.tfyController.name`                         | Name of the service scrape                            | `tfy-controller`                         |
| `controlPlaneMonitors.tfyController.labels`                       | Labels for tfy-controller                             | `{}`                                     |
| `controlPlaneMonitors.tfyController.annotations`                  | Annotations for tfy-controller                        | `{}`                                     |
| `controlPlaneMonitors.tfyController.endpoints`                    | Endpoints for tfy-controller                          | `[]`                                     |
| `controlPlaneMonitors.tfyController.serviceSelectorLabels`        | Service selector labels for tfy-controller            | `{}`                                     |
| `controlPlaneMonitors.tfyController.namespaceSelector`            | Namespace selector for tfy-controller                 | `{}`                                     |
| `controlPlaneMonitors.tfyK8sController.enabled`                   | Enable service scrape for tfy-k8s-controller          | `true`                                   |
| `controlPlaneMonitors.tfyK8sController.name`                      | Name of the service scrape                            | `tfy-k8s-controller`                     |
| `controlPlaneMonitors.tfyK8sController.labels`                    | Labels for tfy-k8s-controller                         | `{}`                                     |
| `controlPlaneMonitors.tfyK8sController.annotations`               | Annotations for tfy-k8s-controller                    | `{}`                                     |
| `controlPlaneMonitors.tfyK8sController.jobLabel`                  | Job label for tfy-k8s-controller                      | `app.kubernetes.io/name`                 |
| `controlPlaneMonitors.tfyK8sController.endpoints`                 | Endpoints for tfy-k8s-controller                      | `[]`                                     |
| `controlPlaneMonitors.tfyK8sController.serviceSelectorLabels`     | Service selector labels for tfy-k8s-controller        | `{}`                                     |
| `controlPlaneMonitors.tfyK8sController.namespaceSelector`         | Namespace selector for tfy-k8s-controller             | `{}`                                     |
| `controlPlaneMonitors.tfyOtelCollector.enabled`                   | Enable service scrape for tfy-otel-collector          | `true`                                   |
| `controlPlaneMonitors.tfyOtelCollector.name`                      | Name of the service scrape                            | `tfy-otel-collector`                     |
| `controlPlaneMonitors.tfyOtelCollector.labels`                    | Labels for otel collector                             | `{}`                                     |
| `controlPlaneMonitors.tfyOtelCollector.annotations`               | Annotations for otel collector                        | `{}`                                     |
| `controlPlaneMonitors.tfyOtelCollector.endpoints`                 | Endpoints for otel collector                          | `[]`                                     |
| `controlPlaneMonitors.tfyOtelCollector.namespaceSelector`         | Namespace selector for otel collector                 | `{}`                                     |
| `controlPlaneMonitors.tfyOtelCollector.serviceSelectorLabels`     | Service selector labels for otel collector            | `{}`                                     |
| `controlPlaneMonitors.llmGateway.enabled`                         | Enable service scrape for llm gateway                 | `true`                                   |
| `controlPlaneMonitors.llmGateway.name`                            | Name of the service scrape                            | `tfy-llm-gateway`                        |
| `controlPlaneMonitors.llmGateway.labels`                          | Labels for llm gateway                                | `{}`                                     |
| `controlPlaneMonitors.llmGateway.annotations`                     | Annotations for llm gateway                           | `{}`                                     |
| `controlPlaneMonitors.llmGateway.endpoints`                       | Endpoints for llm gateway                             | `[]`                                     |
| `controlPlaneMonitors.llmGateway.namespaceSelector`               | Namespace selector for llm gateway                    | `{}`                                     |
| `controlPlaneMonitors.llmGateway.serviceSelectorLabels`           | Service selector labels for llm gateway               | `{}`                                     |
| `controlPlaneMonitors.nats.enabled`                               | Enable pod scrape for nats                            | `true`                                   |
| `controlPlaneMonitors.nats.name`                                  | Name of the pod scrape                                | `truefoundry-tfy-nats`                   |
| `controlPlaneMonitors.nats.labels`                                | Labels for nats                                       | `{}`                                     |
| `controlPlaneMonitors.nats.annotations`                           | Annotations for nats                                  | `{}`                                     |
| `controlPlaneMonitors.nats.podMetricsEndpoints`                   | Pod metrics endpoints for nats                        | `[]`                                     |
| `controlPlaneMonitors.nats.podSelectorLabels`                     | Pod selector labels for nats                          | `{}`                                     |
| `controlPlaneMonitors.nats.namespaceSelector`                     | Namespace selector for nats                           | `{}`                                     |
