# Tfy-gpu-operator helm chart packaged by TrueFoundry
Tfy-gpu-operator is a Helm chart that facilitates the deployment and management of GPU resources in Kubernetes clusters.

## Parameters

### Configuration for the cluster type flags.

| Name                          | Description                                     | Value   |
| ----------------------------- | ----------------------------------------------- | ------- |
| `clusterType.awsEks`          | Flag indicating AWS EKS cluster type.           | `false` |
| `clusterType.gcpGkeStandard`  | Flag indicating GCP GKE Standard cluster type.  | `false` |
| `clusterType.gcpGkeAutopilot` | Flag indicating GCP GKE Autopilot cluster type. | `false` |
| `clusterType.azureAks`        | Flag indicating Azure AKS cluster type.         | `false` |
| `clusterType.civoTalos`       | Flag indicating Civo Talos cluster type.        | `false` |

