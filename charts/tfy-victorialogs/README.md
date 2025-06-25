## Parameters

### Upstream VictoriaLogs configurations

| Name                                                | Description                    | Value                                     |
| --------------------------------------------------- | ------------------------------ | ----------------------------------------- |
| `victoria-logs-single.enabled`                      | Enable victoria-logs-single    | `true`                                    |
| `victoria-logs-single.global.image.registry`        | Image registry                 | `tfy.jfrog.io/tfy-mirror`                 |
| `victoria-logs-single.server.image.registry`        | Image registry                 | `tfy.jfrog.io/tfy-mirror`                 |
| `victoria-logs-single.server.retentionPeriod`       | Retention period               | `15d`                                     |
| `victoria-logs-single.server.persistentVolume.size` | Persistent volume size         | `50Gi`                                    |
| `victoria-logs-single.server.resources`             | Resources                      | `{}`                                      |
| `victoria-logs-single.vector.resources`             | Resources                      | `{}`                                      |
| `victoria-logs-single.vector.image.repository`      | Image repository               | `tfy.jfrog.io/tfy-mirror/timberio/vector` |
| `victoria-logs-single.vector.enabled`               | Enable vector                  | `true`                                    |
| `victoria-logs-single.vector.affinity`              | Affinity                       | `{}`                                      |
| `victoria-logs-single.vector.tolerations`           | Tolerations                    | `[]`                                      |
| `victoria-logs-single.vector.priorityClassName`     | Priority class name for vector | `system-node-critical`                    |
| `victoria-logs-single.vector.nodeSelector`          | Node selector                  | `{}`                                      |
| `victoria-logs-single.vector.customConfig`          | Custom config                  | `{}`                                      |
