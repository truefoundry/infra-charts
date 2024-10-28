# tfy-jspolicy-config helm chart packaged by TrueFoundry
A Helm chart for jspolicy configurations

## Parameters

### replaceImageRegistry Configuration options for replacing the image registry

| Name                                          | Description                                                                                                     | Value   |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceImageRegistry.enabled`                | Enable or disable replacing the image registry                                                                  | `false` |
| `replaceImageRegistry.excludeNamespaces`      | Namespaces to exclude from replacing the image registry                                                         | `[]`    |
| `replaceImageRegistry.includeNamespaces`      | Namespaces to include from replacing the image registry. When non-empty, only these namespaces will be included | `[]`    |
| `replaceImageRegistry.registryReplacementMap` | The image registry replacement map                                                                              | `{}`    |

### replaceArgoHelmRepo Configuration options for replacing the Argo Helm repository

| Name                                         | Description                                                                                                    | Value   |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceArgoHelmRepo.enabled`                | Enable or disable replacing the Argo Helm repository                                                           | `false` |
| `replaceArgoHelmRepo.excludeNamespaces`      | Namespaces to exclude from replacing the argo helm repo                                                        | `[]`    |
| `replaceArgoHelmRepo.includeNamespaces`      | Namespaces to include for replacing the argo helm repo. When non-empty, only these namespaces will be included | `[]`    |
| `replaceArgoHelmRepo.registryReplacementMap` | The argo helm repository replacement map                                                                       | `{}`    |

### syncSecrets Configuration options for syncing secrets

| Name                            | Description                                                                                       | Value   |
| ------------------------------- | ------------------------------------------------------------------------------------------------- | ------- |
| `syncSecrets.enabled`           | Enable or disable syncing secrets                                                                 | `false` |
| `syncSecrets.excludeNamespaces` | Namespaces to exclude from syncing secrets                                                        | `[]`    |
| `syncSecrets.includeNamespaces` | Namespaces to include for syncing secrets. When non-empty, only these namespaces will be included | `[]`    |
| `syncSecrets.secretNames`       | Label selector to filter secrets to sync                                                          | `[]`    |

### syncConfigMaps Configuration options for syncing secrets

| Name                               | Description                                                                                       | Value   |
| ---------------------------------- | ------------------------------------------------------------------------------------------------- | ------- |
| `syncConfigMaps.enabled`           | Enable or disable syncing secrets                                                                 | `false` |
| `syncConfigMaps.excludeNamespaces` | Namespaces to exclude from syncing secrets                                                        | `[]`    |
| `syncConfigMaps.includeNamespaces` | Namespaces to include for syncing secrets. When non-empty, only these namespaces will be included | `[]`    |
| `syncConfigMaps.configMapNames`    | Label selector to filter secrets to sync                                                          | `[]`    |

### podVolumeMounts Configuration options for adding volume mounts to pods

| Name                                | Description                                                                                                    | Value   |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `podVolumeMounts.enabled`           | Enable or disable adding volume mounts to pods                                                                 | `false` |
| `podVolumeMounts.excludeNamespaces` | Namespaces to exclude from adding volume mounts to pods                                                        | `[]`    |
| `podVolumeMounts.includeNamespaces` | Namespaces to include for adding volume mounts to pods. When non-empty, only these namespaces will be included | `[]`    |
| `podVolumeMounts.mountDetails`      | The details of the volume mount to add                                                                         | `[]`    |
