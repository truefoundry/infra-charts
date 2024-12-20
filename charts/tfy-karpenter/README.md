# karpenter helm chart packaged by TrueFoundry
A Helm chart for Karpenter, an open-source node provisioning project built for Kubernetes.

## Parameters

### Upstream karpenter configurations

| Name                                                              | Description                                       | Value   |
| ----------------------------------------------------------------- | ------------------------------------------------- | ------- |
| `karpenter.serviceAccount.annotations.eks.amazonaws.com/role-arn` | Karpenter role ARN                                | `""`    |
| `karpenter.settings.clusterName`                                  | Name of the EKS cluster                           | `""`    |
| `karpenter.settings.clusterEndpoint`                              | Endpoint URL of the EKS cluster                   | `""`    |
| `karpenter.settings.interruptionQueue`                            | Name of the interruption queue for spot instances | `""`    |
| `karpenter.settings.reservedENIs`                                 | reserved ENIs for the custom networking CNI setup | `0`     |
| `karpenter.controller.resources.requests.cpu`                     | CPU requests for karpenter container              | `50m`   |
| `karpenter.controller.resources.requests.memory`                  | Memory requests for karpenter container           | `100Mi` |
| `karpenter.controller.resources.limits.cpu`                       | CPU limits for karpenter container                | `200m`  |
| `karpenter.controller.resources.limits.memory`                    | Memory requests for karpenter container           | `256Mi` |

### Upstream karpenter-crd configurations

| Name                            | Description                      | Value  |
| ------------------------------- | -------------------------------- | ------ |
| `karpenter-crd.webhook.enabled` | Enable webhook in karpenter CRDs | `true` |
