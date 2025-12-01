# karpenter helm chart packaged by TrueFoundry
A Helm chart for Karpenter, an open-source node provisioning project built for Kubernetes.

## Parameters

### eks-node-monitoring-agent configurations

| Name                                                 | Description                                          | Value                                                                             |
| ---------------------------------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| `eks-node-monitoring-agent.nodeAgent.image.override` | Override the image for the eks-node-monitoring-agent | `public.ecr.aws/truefoundrycloud/eks/eks-node-monitoring-agent:v1.2.0-eksbuild.1` |
| `eks-node-monitoring-agent.dcgmAgent.image.override` | Override the image for the dcgm-exporter             | `tfy.jfrog.io/tfy-images/eks/observability/dcgm-exporter:3.3.7-3.5.0-ubuntu22.04` |
| `eks-node-monitoring-agent.dcgmAgent.resources`      | Resources for eks-node-monitoring-agent              | `{}`                                                                              |
| `eks-node-monitoring-agent.dcgmAgent.tolerations`    | Tolerations for eks-node-monitoring-agent            | `[]`                                                                              |

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
