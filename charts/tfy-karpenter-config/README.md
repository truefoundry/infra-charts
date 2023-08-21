# karpenter-config helm chart packaged by TrueFoundry
A Helm chart for Karpenter provisioners.

## Parameters

### Cluster configurations

| Name               | Description                 | Value |
| ------------------ | --------------------------- | ----- |
| `cluster.name`     | Name of the EKS cluster     | `""`  |
| `cluster.endpoint` | Endpoint of the EKS cluster | `""`  |

### Karpenter configurations

| Name                                                     | Description                                                                                                                     | Value                                      |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `karpenter.instanceProfile`                              | Instance profile of the karpenter                                                                                               | `""`                                       |
| `karpenter.defaultProvisionerSpec.consolidation.enabled` | Enable consolidation for default provisioner                                                                                    | `true`                                     |
| `karpenter.defaultProvisionerSpec.ttlSecondsAfterEmpty`  | Seconds after which node should be deleted once it is empty. Either one of consolidation or ttlSecondsAfterEmtpy should be used |                                            |
| `karpenter.defaultProvisionerSpec.providerRef.name`      | AWS node template name for default provisioner                                                                                  | `default`                                  |
| `karpenter.gpuProvisionerSpec.enabled`                   | Enable GPU provisioner for GPU nodes                                                                                            | `false`                                    |
| `karpenter.gpuProvisionerSpec.consolidation.enabled`     | Enable consolidation for GPU provisioner                                                                                        | `true`                                     |
| `karpenter.gpuProvisionerSpec.ttlSecondsAfterEmpty`      | Seconds after which node should be deleted once it is empty. Either one of consolidation or ttlSecondsAfterEmtpy should be used |                                            |
| `karpenter.gpuProvisionerSpec.capacityTypes`             | Capacity types for GPU provisioner                                                                                              | `["spot","on-demand"]`                     |
| `karpenter.gpuProvisionerSpec.zones`                     | Zones to launch instances for GPU provisioner                                                                                   | `["eu-west-1a","eu-west-1b","eu-west-1c"]` |
| `karpenter.gpuProvisionerSpec.instanceFamilies`          | Instance families to launch instances for GPU provisioner                                                                       | `["p2","p3","g4dn","g5","p4d","p4de"]`     |
| `karpenter.gpuProvisionerSpec.providerRefName`           | Name of AWS node template to be used for GPU provisioner                                                                        | `default`                                  |
