# Tfy-notebook-controller helm chart packaged by TrueFoundry
This Helm chart package, provided by TrueFoundry, contains configurations and resources for deploying the Tfy Notebook Controller. The Tfy Notebook Controller manages and orchestrates notebooks within your Kubernetes environment.

## Parameters

#### Parameters for tfyBuildkitdService

| Name                                   | Description                                            | Value                       |
| -------------------------------------- | ------------------------------------------------------ | --------------------------- |
| `labels.app`                           | Label for the application.                             | `notebook-controller`       |
| `labels.kustomize.component`           | Label for the Kustomize component.                     | `notebook-controller`       |
| `namespaceOverride`                    | Namespace override for the notebook controller.        | `""`                        |
| `istioGateway`                         | Istio Gateway for the notebook controller.             | `istio-system/tfy-wildcard` |
| `imageTag`                             | Image tag for the notebook controller.                 | `0.1.0`                     |
| `resources.limits.cpu`                 | CPU limit for the notebook controller.                 | `100m`                      |
| `resources.limits.memory`              | Memory limit for the notebook controller.              | `256Mi`                     |
| `resources.limits.ephemeral-storage`   | Ephemeral storage limit for the notebook controller.   | `256Mi`                     |
| `resources.requests.cpu`               | CPU request for the notebook controller.               | `50m`                       |
| `resources.requests.memory`            | Memory request for the notebook controller.            | `128Mi`                     |
| `resources.requests.ephemeral-storage` | Ephemeral storage request for the notebook controller. | `128Mi`                     |
| `tolerations[0].key`                   | Key for the first toleration.                          | `CriticalAddonsOnly`        |
| `tolerations[0].value`                 | Value for the first toleration.                        | `true`                      |
| `tolerations[0].effect`                | Effect for the first toleration.                       | `NoSchedule`                |
| `tolerations[0].operator`              | Operator for the first toleration.                     | `Equal`                     |


| Name                                   | Description                                            | Value                       |
| -------------------------------------- | ------------------------------------------------------ | --------------------------- |
| `labels.app`                           | Label for the application.                             | `notebook-controller`       |
| `labels.kustomize.component`           | Label for the Kustomize component.                     | `notebook-controller`       |
| `namespaceOverride`                    | Namespace override for the notebook controller.        | `""`                        |
| `istioGateway`                         | Istio Gateway for the notebook controller.             | `istio-system/tfy-wildcard` |
| `imageTag`                             | Image tag for the notebook controller.                 | `0.1.0`                     |
| `resources.limits.cpu`                 | CPU limit for the notebook controller.                 | `100m`                      |
| `resources.limits.memory`              | Memory limit for the notebook controller.              | `256Mi`                     |
| `resources.limits.ephemeral-storage`   | Ephemeral storage limit for the notebook controller.   | `256Mi`                     |
| `resources.requests.cpu`               | CPU request for the notebook controller.               | `50m`                       |
| `resources.requests.memory`            | Memory request for the notebook controller.            | `128Mi`                     |
| `resources.requests.ephemeral-storage` | Ephemeral storage request for the notebook controller. | `128Mi`                     |
| `tolerations[0].key`                   | Key for the first toleration.                          | `CriticalAddonsOnly`        |
| `tolerations[0].value`                 | Value for the first toleration.                        | `true`                      |
| `tolerations[0].effect`                | Effect for the first toleration.                       | `NoSchedule`                |
| `tolerations[0].operator`              | Operator for the first toleration.                     | `Equal`                     |
