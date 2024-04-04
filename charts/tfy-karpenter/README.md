# karpenter helm chart packaged by TrueFoundry
A Helm chart for Karpenter, an open-source node provisioning project built for Kubernetes.

## Parameters

### Upstream karpenter configurations

| Name                                                              | Description                             | Value   |
| ----------------------------------------------------------------- | --------------------------------------- | ------- |
| `karpenter.serviceAccount.annotations.eks.amazonaws.com/role-arn` | Karpenter role ARN                      | `""`    |
| `karpenter.settings.aws.clusterName`                              | Name of the EKS cluster                 | `""`    |
| `karpenter.settings.aws.clusterName`                              | Name of the EKS cluster                 | `""`    |
| `karpenter.settings.aws.clusterEndpoint`                          | Endpoint URL of the EKS cluster         | `""`    |
| `karpenter.settings.aws.defaultInstanceProfile`                   | Instance profile of the karpenter       | `""`    |
| `karpenter.controller.resources.requests.cpu`                     | CPU requests for karpenter container    | `50m`   |
| `karpenter.controller.resources.requests.memory`                  | Memory requests for karpenter container | `100Mi` |
| `karpenter.controller.resources.limits.cpu`                       | CPU limits for karpenter container      | `200m`  |
| `karpenter.controller.resources.limits.memory`                    | Memory requests for karpenter container | `256Mi` |