# tfy-jspolicy-config helm chart packaged by TrueFoundry
A Helm chart for jspolicy configurations

## Parameters

### Global settings

| Name                 | Description                   | Value |
| -------------------- | ----------------------------- | ----- |
| `global.labels`      | Labels for all resources      | `{}`  |
| `global.annotations` | Annotations for all resources | `{}`  |

### replaceImageRegistry Configuration options for replacing the image registry

| Name                                          | Description                                                                                                                                              | Value   |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceImageRegistry.enabled`                | Enable or disable replacing the image registry                                                                                                           | `false` |
| `replaceImageRegistry.excludeNamespaces`      | Namespaces to exclude from replacing the image registry. Regular expressions are also supported.                                                         | `[]`    |
| `replaceImageRegistry.includeNamespaces`      | Namespaces to include from replacing the image registry. When non-empty, only these namespaces will be included. Regular expressions are also supported. | `[]`    |
| `replaceImageRegistry.registryReplacementMap` | The image registry replacement map                                                                                                                       | `{}`    |

### replaceArgoHelmRepo Configuration options for replacing the Argo Helm repository

| Name                                         | Description                                                                                                                                             | Value   |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceArgoHelmRepo.enabled`                | Enable or disable replacing the Argo Helm repository                                                                                                    | `false` |
| `replaceArgoHelmRepo.excludeNamespaces`      | Namespaces to exclude from replacing the argo helm repo. Regular expressions are also supported.                                                        | `[]`    |
| `replaceArgoHelmRepo.includeNamespaces`      | Namespaces to include for replacing the argo helm repo. When non-empty, only these namespaces will be included. Regular expressions are also supported. | `[]`    |
| `replaceArgoHelmRepo.registryReplacementMap` | The argo helm repository replacement map                                                                                                                | `{}`    |

### syncSecrets Configuration options for syncing secrets

| Name                            | Description                                                                                                                                | Value   |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `syncSecrets.enabled`           | Enable or disable syncing secrets                                                                                                          | `false` |
| `syncSecrets.excludeNamespaces` | Namespaces to exclude from syncing secrets. Regular expressions are also supported.                                                        | `[]`    |
| `syncSecrets.includeNamespaces` | Namespaces to include for syncing secrets. When non-empty, only these namespaces will be included. Regular expressions are also supported. | `[]`    |
| `syncSecrets.secretNames`       | Label selector to filter secrets to sync                                                                                                   | `[]`    |

### syncConfigMaps Configuration options for syncing secrets

| Name                               | Description                                                                                                                                | Value   |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `syncConfigMaps.enabled`           | Enable or disable syncing secrets                                                                                                          | `false` |
| `syncConfigMaps.excludeNamespaces` | Namespaces to exclude from syncing secrets. Regular expressions are also supported.                                                        | `[]`    |
| `syncConfigMaps.includeNamespaces` | Namespaces to include for syncing secrets. When non-empty, only these namespaces will be included. Regular expressions are also supported. | `[]`    |
| `syncConfigMaps.configMapNames`    | Label selector to filter secrets to sync                                                                                                   | `[]`    |

### podVolumeMounts Configuration options for adding volume mounts to pods

| Name                                | Description                                                                                                                                             | Value   |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `podVolumeMounts.enabled`           | Enable or disable adding volume mounts to pods                                                                                                          | `false` |
| `podVolumeMounts.excludeNamespaces` | Namespaces to exclude from adding volume mounts to pods. Regular expressions are also supported.                                                        | `[]`    |
| `podVolumeMounts.includeNamespaces` | Namespaces to include for adding volume mounts to pods. When non-empty, only these namespaces will be included. Regular expressions are also supported. | `[]`    |
| `podVolumeMounts.mountDetails`      | The details of the volume mount to add                                                                                                                  | `[]`    |
