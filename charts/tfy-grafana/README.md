# Header
subheading

## Upgrade Guide

### From 1.3 to 1.4
- Default dashboards are now included with the grafana charts
- You can add the dashboards in the `dashboards/` folder
- Apply a label to the configmap via `.grafana.sidecar.dashboards.label` and `.grafana.sidecar.dashboards.labelValue`.


## Parameters

### grafana Configuration for Grafana deployment.
| Name                                                      | Description                                        | Value                |
| --------------------------------------------------------- | -------------------------------------------------- | -------------------- |
| `grafana.replicas`                                        | StatefulSet configuration for Grafana.             | `1`                  |
| `grafana.useStatefulSet`                                  | Replicas configuration for Grafana.                | `true`               |
| `grafana.resources.limits.cpu`                            | CPU limit for Grafana.                             | `100m`               |
| `grafana.resources.limits.memory`                         | Memory limit for Grafana.                          | `128Mi`              |
| `grafana.resources.requests.cpu`                          | CPU request for Grafana.                           | `100m`               |
| `grafana.resources.requests.memory`                       | Memory request for Grafana.                        | `128Mi`              |
| `grafana.adminUser`                                       | Admin user for Grafana.                            | `""`                 |
| `grafana.adminPassword`                                   | Admin password for Grafana.                        | `""`                 |
| `grafana.initChownData.resources.limits.cpu`              | CPU limit for initializing chown data.             | `100m`               |
| `grafana.initChownData.resources.limits.memory`           | Memory limit for initializing chown data.          | `128Mi`              |
| `grafana.initChownData.resources.requests.cpu`            | CPU request for initializing chown data.           | `100m`               |
| `grafana.initChownData.resources.requests.memory`         | Memory request for initializing chown data.        | `128Mi`              |
| `grafana.sidecar.resources.limits.cpu`                    | CPU limit for Grafana sidecar.                     | `100m`               |
| `grafana.sidecar.resources.limits.memory`                 | Memory limit for Grafana sidecar.                  | `100Mi`              |
| `grafana.sidecar.resources.requests.cpu`                  | CPU request for Grafana sidecar.                   | `50m`                |
| `grafana.sidecar.resources.requests.memory`               | Memory request for Grafana sidecar.                | `50Mi`               |
| `grafana.datasources.datasources.yaml.apiVersion`         | API version for the datasource configuration.     | `1`                  |
| `grafana.datasources.datasources.yaml.datasources[0].name`| Name of the first datasource.                      | `Prometheus`         |
| `grafana.datasources.datasources.yaml.datasources[0].type`| Type of the first datasource.                      | `prometheus`         |
| `grafana.datasources.datasources.yaml.datasources[0].url` | URL for the first datasource.                      | `http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090` |
| `grafana.datasources.datasources.yaml.datasources[0].access` | Access type for the first datasource.           | `proxy`              |
| `grafana.datasources.datasources.yaml.datasources[0].isDefault` | Specify if the first datasource is the default. | `true`               |
| `grafana.datasources.datasources.yaml.datasources[1].name`| Name of the second datasource.                     | `Loki`               |
| `grafana.datasources.datasources.yaml.datasources[1].type`| Type of the second datasource.                     | `loki`               |
| `grafana.datasources.datasources.yaml.datasources[1].url` | URL for the second datasource.                     | `http://loki.loki.svc.cluster.local:3100` |
| `grafana.datasources.datasources.yaml.datasources[1].access` | Access type for the second datasource.          | `proxy`              |
| `grafana.datasources.datasources.yaml.datasources[1].isDefault` | Specify if the second datasource is the default.| `false`              |
| `grafana.persistence.enabled`                             | Enable or disable persistence for Grafana.         | `true`               |
| `grafana.persistence.size`                                | Size of the persisted storage for Grafana.         | `10Gi`               |

