## tfy-k8s-gcp-gke-standard-inframold
Inframold, the superchart that configure your cluster on gcp for truefoundry.

## Parameters

### Global Parameters

| Name              | Description                    | Value |
| ----------------- | ------------------------------ | ----- |
| `tenantName`      | Parameters for tenantName      | `""`  |
| `controlPlaneURL` | Parameters for controlPlaneURL | `""`  |
| `clusterName`     | Name of the cluster            | `""`  |

### argocd parameters

| Name             | Description           | Value  |
| ---------------- | --------------------- | ------ |
| `argocd.enabled` | Flag to enable ArgoCD | `true` |

### argoWorkflows parameters

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `argoWorkflows.enabled` | Flag to enable Argo Workflows | `true` |

### argoRollouts parameters

| Name                   | Description                  | Value  |
| ---------------------- | ---------------------------- | ------ |
| `argoRollouts.enabled` | Flag to enable Argo Rollouts | `true` |

### notebookController parameters

| Name                                     | Description                                   | Value  |
| ---------------------------------------- | --------------------------------------------- | ------ |
| `notebookController.enabled`             | Flag to enable Notebook Controller            | `true` |
| `notebookController.defaultStorageClass` | Default storage class for Notebook Controller | `""`   |

### certManager parameters

| Name                  | Description                 | Value   |
| --------------------- | --------------------------- | ------- |
| `certManager.enabled` | Flag to enable Cert Manager | `false` |

### metricsServer parameters

| Name                    | Description                   | Value   |
| ----------------------- | ----------------------------- | ------- |
| `metricsServer.enabled` | Flag to enable Metrics Server | `false` |

### gpu parameters

| Name              | Description                       | Value            |
| ----------------- | --------------------------------- | ---------------- |
| `gpu.enabled`     | Flag to enable Tfy GPU Operator   | `true`           |
| `gpu.clusterType` | Cluster type for Tfy GPU Operator | `gcpGkeStandard` |

### truefoundry parameters

| Name                  | Description                         | Value   |
| --------------------- | ----------------------------------- | ------- |
| `truefoundry.enabled` | Flag to enable TrueFoundry          | `false` |
| `truefoundry.dev`     | Flag to enable TrueFoundry Dev mode | `true`  |

### truefoundryBootstrap parameters

| Name                                       | Description                                                               | Value   |
| ------------------------------------------ | ------------------------------------------------------------------------- | ------- |
| `truefoundry.truefoundryBootstrap.enabled` | Flag to enable bootstrap job to prep cluster for truefoundry installation | `false` |

### database. Can be left empty if using the dev mode parameters

| Name                                         | Description                                                | Value |
| -------------------------------------------- | ---------------------------------------------------------- | ----- |
| `truefoundry.database.host`                  | Hostname of the database                                   | `""`  |
| `truefoundry.database.name`                  | Name of the database                                       | `""`  |
| `truefoundry.database.username`              | Username of the database                                   | `""`  |
| `truefoundry.database.password`              | Password of the database                                   | `""`  |
| `truefoundry.tfyApiKey`                      | API Key for TrueFoundry                                    | `""`  |
| `truefoundry.truefoundryImagePullConfigJSON` | Json config for authenticating to the TrueFoundry registry | `""`  |

### loki parameters

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `loki.enabled` | Flag to enable Loki | `true` |

### istio parameters

| Name                             | Description                                     | Value  |
| -------------------------------- | ----------------------------------------------- | ------ |
| `istio.enabled`                  | Flag to enable Istio                            | `true` |
| `istio.tfyGateway.httpsRedirect` | Flag to enable HTTPS redirect for Istio Gateway | `true` |

### keda parameters

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `keda.enabled` | Flag to enable Keda | `true` |

### kubecost parameters

| Name               | Description             | Value  |
| ------------------ | ----------------------- | ------ |
| `kubecost.enabled` | Flag to enable Kubecost | `true` |

### prometheus parameters

| Name                 | Description               | Value  |
| -------------------- | ------------------------- | ------ |
| `prometheus.enabled` | Flag to enable Prometheus | `true` |

### grafana parameters

| Name              | Description            | Value  |
| ----------------- | ---------------------- | ------ |
| `grafana.enabled` | Flag to enable Grafana | `true` |

### tfyAgent parameters

| Name                    | Description              | Value  |
| ----------------------- | ------------------------ | ------ |
| `tfyAgent.enabled`      | Flag to enable Tfy Agent | `true` |
| `tfyAgent.clusterToken` | cluster token            | `""`   |
