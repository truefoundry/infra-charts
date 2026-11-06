# EKS Node Monitoring Agent

This chart installs the [`eks-node-monitoring-agent`](https://github.com/aws/eks-node-monitoring-agent).

## Parameters

### Global parameters

| Name                         | Description                         | Value                       |
| ---------------------------- | ----------------------------------- | --------------------------- |
| `imagePullSecrets`           | Image pull secret                   | `[]`                        |
| `nameOverride`               | Name override for the chart         | `eks-node-monitoring-agent` |
| `fullnameOverride`           | Fullname override for the chart     | `eks-node-monitoring-agent` |
| `serviceAccount.create`      | Create the service account          | `true`                      |
| `serviceAccount.name`        | Name of the service account         | `nil`                       |
| `serviceAccount.annotations` | Annotations for the service account | `{}`                        |
| `updateStrategy`             | Update strategy for all daemon sets | `{}`                        |

### Node agent parameters

| Name                         | Description                                        | Value                                              |
| ---------------------------- | -------------------------------------------------- | -------------------------------------------------- |
| `nodeAgent.image.repository` | Repository for the image                           | `quay.io/tfy-images/eks/eks-node-monitoring-agent` |
| `nodeAgent.image.tag`        | Tag for the image                                  | `v1.7.1-eksbuild.1`                                |
| `nodeAgent.image.pullPolicy` | Pull policy for the image                          | `IfNotPresent`                                     |
| `nodeAgent.additionalArgs`   | Additional arguments for the image                 | `[]`                                               |
| `nodeAgent.affinity`         | Affinity for the image                             | `{}`                                               |
| `nodeAgent.resources`        | Resources for the eks-node-monitoring-agent        | `{}`                                               |
| `nodeAgent.securityContext`  | Security context for the eks-node-monitoring-agent | `{}`                                               |
| `nodeAgent.tolerations`      | Tolerations for the eks-node-monitoring-agent      | `[]`                                               |

### DCGM agent parameters

| Name                         | Description                                                          | Value          |
| ---------------------------- | -------------------------------------------------------------------- | -------------- |
| `dcgmAgent.image.repository` | Repository for the dcgm-server image. Empty uses the nodeAgent image | `""`           |
| `dcgmAgent.image.tag`        | Tag for the dcgm-server image. Empty uses the nodeAgent tag          | `""`           |
| `dcgmAgent.image.pullPolicy` | Pull policy for the image                                            | `IfNotPresent` |
| `dcgmAgent.affinity`         | Affinity for the dcgm-exporter                                       | `{}`           |
| `dcgmAgent.resources`        | Resources for the dcgm-exporter                                      | `{}`           |
| `dcgmAgent.tolerations`      | Tolerations for the dcgm-exporter                                    | `[]`           |


## Prerequisites

- Kubernetes v{?} running on AWS
- Helm v3

## Installing the Chart

```shell
# using the github chart repository
helm repo add eks-node-monitoring-agent https://aws.github.io/eks-node-monitoring-agent
helm install eks-node-monitoring-agent eks-node-monitoring-agent/eks-node-monitoring-agent --namespace kube-system
```

**OR**

```shell
# using the chart sources
git clone https://github.com/aws/eks-node-monitoring-agent.git
cd eks-node-monitoring-agent
helm install eks-node-monitoring-agent ./charts/eks-node-monitoring-agent --namespace kube-system
```

To uninstall:

```shell
helm uninstall eks-node-monitoring-agent --namespace kube-system
```
