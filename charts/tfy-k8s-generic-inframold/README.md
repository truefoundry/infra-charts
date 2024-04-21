## tfy-k8s-generic-inframold
Inframold, the superchart that configure your cluster on generic for truefoundry.

## Parameters

### Parameters for argocd

| Name             | Description           | Value  |
| ---------------- | --------------------- | ------ |
| `argocd.enabled` | Flag to enable ArgoCD | `true` |

### Parameters for argoWorkflows

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `argoWorkflows.enabled` | Flag to enable Argo Workflows | `true` |

### Parameters for argoRollouts

| Name                   | Description                  | Value  |
| ---------------------- | ---------------------------- | ------ |
| `argoRollouts.enabled` | Flag to enable Argo Rollouts | `true` |

### Parameters for notebookController

| Name                         | Description                        | Value  |
| ---------------------------- | ---------------------------------- | ------ |
| `notebookController.enabled` | Flag to enable Notebook Controller | `true` |

### Parameters for certManager

| Name                  | Description                 | Value  |
| --------------------- | --------------------------- | ------ |
| `certManager.enabled` | Flag to enable Cert Manager | `true` |

### Parameters for metricsServer

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `metricsServer.enabled` | Flag to enable Metrics Server | `true` |

### Parameters for tfyGpuOperator

| Name                         | Description                       | Value     |
| ---------------------------- | --------------------------------- | --------- |
| `tfyGpuOperator.enabled`     | Flag to enable Tfy GPU Operator   | `true`    |
| `tfyGpuOperator.clusterType` | Cluster type for Tfy GPU Operator | `generic` |

### Parameters for truefoundry

| Name                  | Description                         | Value  |
| --------------------- | ----------------------------------- | ------ |
| `truefoundry.enabled` | Flag to enable TrueFoundry          | `true` |
| `truefoundry.dev`     | Flag to enable TrueFoundry Dev mode | `true` |

### Parameters for loki

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `loki.enabled` | Flag to enable Loki | `true` |

### Parameters for istio

| Name            | Description          | Value  |
| --------------- | -------------------- | ------ |
| `istio.enabled` | Flag to enable Istio | `true` |

### Parameters for tfyInferentiaOperator

| Name                            | Description                            | Value  |
| ------------------------------- | -------------------------------------- | ------ |
| `tfyInferentiaOperator.enabled` | Flag to enable Tfy Inferentia Operator | `true` |

### Parameters for keda

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `keda.enabled` | Flag to enable Keda | `true` |

### Parameters for kubecost

| Name               | Description             | Value  |
| ------------------ | ----------------------- | ------ |
| `kubecost.enabled` | Flag to enable Kubecost | `true` |

### Parameters for prometheus

| Name                 | Description               | Value  |
| -------------------- | ------------------------- | ------ |
| `prometheus.enabled` | Flag to enable Prometheus | `true` |

### Parameters for grafana

| Name              | Description            | Value  |
| ----------------- | ---------------------- | ------ |
| `grafana.enabled` | Flag to enable Grafana | `true` |

### Parameters for tfyAgent

| Name                    | Description                 | Value  |
| ----------------------- | --------------------------- | ------ |
| `tfyAgent.enabled`      | Flag to enable Tfy Agent    | `true` |
| `tfyAgent.clusterToken` | Parameters for clusterToken | `""`   |
