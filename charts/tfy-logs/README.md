## Truefoundry Logs 
This Helm chart deploys a centralized logging solution for Truefoundry using VictoriaLogs as the backend storage and Vector as the log collection agent.

### Overview

The `tfy-logs` chart provides:

- Centralized log collection from all Kubernetes pods
- Log storage with configurable retention period
- Log parsing and structured storage
- Efficient log querying capabilities

### Architecture

The solution consists of two main components:

1. **VictoriaLogs Server**: A high-performance, cost-effective log storage and search system
2. **Vector Agents**: DaemonSet that collects logs from all nodes and forwards them to VictoriaLogs

### Prerequisites

- Kubernetes 1.30+
- Helm 3.1.0+
- PV provisioner support in the underlying infrastructure

### Installation

## Parameters

### Upstream VictoriaLogs configurations

| Name                                                  | Description                                                                           | Value                                     |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------- |
| `victoria-logs-single.enabled`                        | Enable victoria-logs-single                                                           | `true`                                    |
| `victoria-logs-single.global.image.registry`          | Image registry                                                                        | `tfy.jfrog.io/tfy-mirror`                 |
| `victoria-logs-single.server.image.registry`          | Image registry                                                                        | `tfy.jfrog.io/tfy-mirror`                 |
| `victoria-logs-single.server.retentionPeriod`         | Retention period                                                                      | `15d`                                     |
| `victoria-logs-single.server.retentionDiskSpaceUsage` | Retention disk space usage, this is kept to be 6-8% smaller than the total disk space | `46`                                      |
| `victoria-logs-single.server.persistentVolume.size`   | Persistent volume size                                                                | `50Gi`                                    |
| `victoria-logs-single.server.resources`               | Resources                                                                             | `{}`                                      |
| `victoria-logs-single.server.affinity`                | Affinity                                                                              | `{}`                                      |
| `victoria-logs-single.server.tolerations`             | Tolerations                                                                           | `[]`                                      |
| `victoria-logs-single.vector.resources`               | Resources                                                                             | `{}`                                      |
| `victoria-logs-single.vector.podPriorityClassName`    | Pod priority class name                                                               | `system-node-critical`                    |
| `victoria-logs-single.vector.image.repository`        | Image repository                                                                      | `tfy.jfrog.io/tfy-mirror/timberio/vector` |
| `victoria-logs-single.vector.enabled`                 | Enable vector                                                                         | `true`                                    |
| `victoria-logs-single.vector.affinity`                | Affinity                                                                              | `{}`                                      |
| `victoria-logs-single.vector.tolerations`             | Tolerations                                                                           | `[]`                                      |
| `victoria-logs-single.vector.nodeSelector`            | Node selector                                                                         | `{}`                                      |
| `victoria-logs-single.vector.customConfig`            | Custom config                                                                         | `{}`                                      |

### resourceQuota Add a ResourceQuota to enable priority class in a namespace.

| Name                            | Description                             | Value                      |
| ------------------------------- | --------------------------------------- | -------------------------- |
| `resourceQuota.enabled`         | Create the ResourceQuota.               | `true`                     |
| `resourceQuota.annotations`     | Annotations to add to the ResourceQuota | `{}`                       |
| `resourceQuota.labels`          | Labels to add to the ResourceQuota      | `{}`                       |
| `resourceQuota.priorityClasses` | PriorityClasses to enable.              | `["system-node-critical"]` |
