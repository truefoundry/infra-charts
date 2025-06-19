# tfy-victorialogs

This Helm chart provisions VictoriaLogs using the `victoria-logs-single` chart from the VictoriaMetrics Helm repository.

## Description

This chart provides a complete logging solution using VictoriaLogs with Vector for log collection and processing. It includes:

- VictoriaLogs server for log storage and querying
- Vector for log collection and transformation
- Service monitoring integration with Prometheus
- Custom log parsing and label extraction

## Dependencies

This chart depends on:

- `victoria-logs-single` from <https://victoriametrics.github.io/helm-charts/>

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `victoria-logs-single.enabled` | Enable VictoriaLogs | `true` |
| `victoria-logs-single.server.resources.limits.cpu` | CPU limit for VictoriaLogs server | `"2"` |
| `victoria-logs-single.server.resources.limits.memory` | Memory limit for VictoriaLogs server | `4000M` |
| `victoria-logs-single.server.retentionPeriod` | Log retention period | `7d` |
| `victoria-logs-single.server.persistentVolume.size` | Persistent volume size | `500Gi` |
| `victoria-logs-single.vector.enabled` | Enable Vector log collection | `true` |

### Image Registry

This chart is configured to use the TrueFoundry mirror registry (`tfy.jfrog.io/tfy-mirror`) for all images.

## Installation

```bash
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm install tfy-victorialogs ./charts/tfy-victorialogs -n <namespace>
```

## Vector Configuration

The chart includes advanced Vector configuration for log parsing and label extraction:

- Parses JSON logs when possible
- Extracts Kubernetes metadata (pod, container, namespace)
- Dynamically extracts all pod labels
- Sanitizes label names for compatibility
