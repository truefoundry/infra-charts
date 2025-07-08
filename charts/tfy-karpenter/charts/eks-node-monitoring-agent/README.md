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

| Name                         | Description                                        | Value               |
| ---------------------------- | -------------------------------------------------- | ------------------- |
| `nodeAgent.image.tag`        | Tag for the image                                  | `v1.2.0-eksbuild.1` |
| `nodeAgent.image.domain`     | Domain for the image                               | `amazonaws.com`     |
| `nodeAgent.image.region`     | Region for the image                               | `us-west-2`         |
| `nodeAgent.image.endpoint`   | Endpoint for the image                             | `ecr`               |
| `nodeAgent.image.account`    | Account for the image                              | `602401143452`      |
| `nodeAgent.image.pullPolicy` | Pull policy for the image                          | `IfNotPresent`      |
| `nodeAgent.additionalArgs`   | Additional arguments for the image                 | `[]`                |
| `nodeAgent.affinity`         | Affinity for the image                             | `{}`                |
| `nodeAgent.resources`        | Resources for the eks-node-monitoring-agent        | `{}`                |
| `nodeAgent.securityContext`  | Security context for the eks-node-monitoring-agent | `{}`                |
| `nodeAgent.tolerations`      | Tolerations for the eks-node-monitoring-agent      | `[]`                |

### DCGM agent parameters

| Name                         | Description                       | Value                     |
| ---------------------------- | --------------------------------- | ------------------------- |
| `dcgmAgent.image.tag`        | Tag for the image                 | `3.3.7-3.5.0-ubuntu22.04` |
| `dcgmAgent.image.domain`     | Domain for the image              | `amazonaws.com`           |
| `dcgmAgent.image.region`     | Region for the image              | `us-west-2`               |
| `dcgmAgent.image.endpoint`   | Endpoint for the image            | `ecr`                     |
| `dcgmAgent.image.account`    | Account for the image             | `602401143452`            |
| `dcgmAgent.image.pullPolicy` | Pull policy for the image         | `IfNotPresent`            |
| `dcgmAgent.affinity`         | Affinity for the dcgm-exporter    | `{}`                      |
| `dcgmAgent.resources`        | Resources for the dcgm-exporter   | `{}`                      |
| `dcgmAgent.tolerations`      | Tolerations for the dcgm-exporter | `[]`                      |


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
