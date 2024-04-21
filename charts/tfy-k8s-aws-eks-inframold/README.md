## tfy-k8s-aws-eks-inframold
Inframold, the superchart that configure your cluster on aws for truefoundry.

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

| Name                  | Description                 | Value   |
| --------------------- | --------------------------- | ------- |
| `certManager.enabled` | Flag to enable Cert Manager | `false` |

### Parameters for metricsServer

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `metricsServer.enabled` | Flag to enable Metrics Server | `true` |

### Parameters for AWS

| Name                                                   | Description                                  | Value                                       |
| ------------------------------------------------------ | -------------------------------------------- | ------------------------------------------- |
| `aws.awsLoadBalancerController.enabled`                | Flag to enable AWS Load Balancer Controller  | `true`                                      |
| `aws.awsLoadBalancerController.roleArn`                | Role ARN for AWS Load Balancer Controller    | `""`                                        |
| `aws.karpenter.enabled`                                | Flag to enable Karpenter                     | `true`                                      |
| `aws.karpenter.clusterEndpoint`                        | Cluster endpoint for Karpenter               | `""`                                        |
| `aws.karpenter.roleArn`                                | Role ARN for Karpenter                       | `""`                                        |
| `aws.karpenter.instanceProfile`                        | Instance profile for Karpenter               | `""`                                        |
| `aws.karpenter.defaultZones`                           | Default zones for Karpenter                  | `""`                                        |
| `aws.karpenter.gpuProvisioner.capacityTypes`           | Capacity types for GPU provisioner           | `["spot","on-demand"]`                      |
| `aws.karpenter.gpuProvisioner.instanceFamilies`        | Instance families for GPU provisioner        | `["p2","p3","p4d","p4de","p5","g4dn","g5"]` |
| `aws.karpenter.gpuProvisioner.zones`                   | Zones for GPU provisioner                    | `""`                                        |
| `aws.karpenter.inferentiaProvisioner.capacityTypes`    | Capacity types for Inferentia provisioner    | `["spot","on-demand"]`                      |
| `aws.karpenter.inferentiaProvisioner.instanceFamilies` | Instance families for Inferentia provisioner | `["inf1","inf2"]`                           |
| `aws.karpenter.inferentiaProvisioner.zones`            | Zones for Inferentia provisioner             | `""`                                        |
| `aws.karpenter.interruptionQueueName`                  | Interruption queue name for Karpenter        | `""`                                        |
| `aws.awsEbsCsiDriver.enabled`                          | Flag to enable AWS EBS CSI Driver            | `true`                                      |
| `aws.awsEbsCsiDriver.roleArn`                          | Role ARN for AWS EBS CSI Driver              | `""`                                        |
| `aws.awsEfsCsiDriver.enabled`                          | Flag to enable AWS EFS CSI Driver            | `true`                                      |
| `aws.awsEfsCsiDriver.fileSystemId`                     | File system ID for AWS EFS CSI Driver        | `""`                                        |
| `aws.awsEfsCsiDriver.region`                           | Region for AWS EFS CSI Driver                | `""`                                        |
| `aws.awsEfsCsiDriver.roleArn`                          | Role ARN for AWS EFS CSI Driver              | `""`                                        |

### Parameters for tfyGpuOperator

| Name                         | Description                       | Value    |
| ---------------------------- | --------------------------------- | -------- |
| `tfyGpuOperator.enabled`     | Flag to enable Tfy GPU Operator   | `true`   |
| `tfyGpuOperator.clusterType` | Cluster type for Tfy GPU Operator | `awsEks` |

### Parameters for truefoundry

| Name                  | Description                         | Value   |
| --------------------- | ----------------------------------- | ------- |
| `truefoundry.enabled` | Flag to enable TrueFoundry          | `false` |
| `truefoundry.dev`     | Flag to enable TrueFoundry Dev mode | `true`  |

### Parameters for loki

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `loki.enabled` | Flag to enable Loki | `true` |

### Parameters for istio

| Name            | Description          | Value  |
| --------------- | -------------------- | ------ |
| `istio.enabled` | Flag to enable Istio | `true` |

### Parameters for tfyInferentiaOperator

| Name                            | Description                            | Value   |
| ------------------------------- | -------------------------------------- | ------- |
| `tfyInferentiaOperator.enabled` | Flag to enable Tfy Inferentia Operator | `false` |

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
