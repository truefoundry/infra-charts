# karpenter helm chart packaged by TrueFoundry
A Helm chart for Karpenter, an open-source node provisioning project built for Kubernetes.

## Parameters

### eks-node-monitoring-agent configurations

| Name                                                   | Description                                                           | Value                                      |
| ------------------------------------------------------ | --------------------------------------------------------------------- | ------------------------------------------ |
| `eks-node-monitoring-agent.imagePullSecrets`           | Image pull secrets for eks-node-monitoring-agent and dcgm-server      | `[]`                                       |
| `eks-node-monitoring-agent.nodeAgent.image.registry`   | Registry for the eks-node-monitoring-agent image                      | `quay.io`                                  |
| `eks-node-monitoring-agent.nodeAgent.image.repository` | Repository for the eks-node-monitoring-agent image                    | `tfy-images/eks/eks-node-monitoring-agent` |
| `eks-node-monitoring-agent.nodeAgent.image.tag`        | Tag for the eks-node-monitoring-agent image                           | `v1.7.1-eksbuild.1`                        |
| `eks-node-monitoring-agent.nodeAgent.resources`        | Resources for eks-node-monitoring-agent                               | `{}`                                       |
| `eks-node-monitoring-agent.dcgmAgent.image.registry`   | Registry for the dcgm-server image. Empty uses the nodeAgent registry | `""`                                       |
| `eks-node-monitoring-agent.dcgmAgent.image.repository` | Repository for the dcgm-server image. Empty uses the nodeAgent image  | `""`                                       |
| `eks-node-monitoring-agent.dcgmAgent.image.tag`        | Tag for the dcgm-server image. Empty uses the nodeAgent tag           | `""`                                       |
| `eks-node-monitoring-agent.dcgmAgent.resources`        | Resources for eks-node-monitoring-agent                               | `{}`                                       |
| `eks-node-monitoring-agent.dcgmAgent.tolerations`      | Tolerations for eks-node-monitoring-agent                             | `[]`                                       |

### Upstream karpenter configurations

| Name                                                              | Description                                       | Value          |
| ----------------------------------------------------------------- | ------------------------------------------------- | -------------- |
| `karpenter.serviceAccount.annotations.eks.amazonaws.com/role-arn` | Karpenter role ARN                                | `""`           |
| `karpenter.logLevel`                                              | Log level for karpenter                           | `debug`        |
| `karpenter.settings.clusterName`                                  | Name of the EKS cluster                           | `cluster-name` |
| `karpenter.settings.clusterEndpoint`                              | Endpoint URL of the EKS cluster                   | `""`           |
| `karpenter.settings.interruptionQueue`                            | Name of the interruption queue for spot instances | `""`           |
| `karpenter.settings.reservedENIs`                                 | reserved ENIs for the custom networking CNI setup | `0`            |
| `karpenter.settings.featureGates.nodeRepair`                      | Enable node repair feature gate                   | `true`         |
| `karpenter.controller.resources.requests.cpu`                     | CPU requests for karpenter container              | `0.5`          |
| `karpenter.controller.resources.requests.memory`                  | Memory requests for karpenter container           | `2000Mi`       |
| `karpenter.controller.resources.limits.cpu`                       | CPU limits for karpenter container                | `1`            |
| `karpenter.controller.resources.limits.memory`                    | Memory requests for karpenter container           | `4000Mi`       |
| `karpenter.serviceMonitor.enabled`                                | Enable service monitor for karpenter              | `true`         |
