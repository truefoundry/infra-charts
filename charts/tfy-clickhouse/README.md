# TFY-Clickhouse helm chart packaged by Truefoundry
TFY-Clickhouse is a helm chart for deploying Clickhouse on Kubernetes. It is designed to be easy to use and customizable, allowing you to deploy Clickhouse quickly and efficiently.

## Parameters

### tfyClickhouse parameters

| Name                           | Description                                                                     | Value          |
| ------------------------------ | ------------------------------------------------------------------------------- | -------------- |
| `global.resourceTier`          | Resource deployment type                                                        | `medium`       |
| `global.affinity`              | Affinity rules for pod scheduling on a node                                     | `{}`           |
| `global.tolerations`           | Tolerations for pod scheduling on a node                                        | `[]`           |
| `global.nodeSelector`          | Node selector                                                                   | `{}`           |
| `global.image.registry`        | Image registry for tfyClickhouse (defaults to global.image.registry if not set) | `tfy.jfrog.io` |
| `altinity-clickhouse-operator` | altinity operator                                                               | `{}`           |

