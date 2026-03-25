# tfy-kyverno-config helm chart packaged by TrueFoundry
A Helm chart for kyverno configurations

## Parameters

### replaceImageRegistry Configuration options for replacing the image registry

| Name                                          | Description                                                                                                     | Value   |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceImageRegistry.enabled`                | Enable or disable replacing the image registry                                                                  | `false` |
| `replaceImageRegistry.excludeNamespaces`      | Namespaces to exclude from replacing the image registry                                                         | `[]`    |
| `replaceImageRegistry.includeNamespaces`      | Namespaces to include from replacing the image registry. When non-empty, only these namespaces will be included | `[]`    |
| `replaceImageRegistry.registryReplacementMap` | Map of source registry prefixes to target registries.                                                           | `{}`    |

### replaceArgoHelmRepo Configuration options for replacing the Argo Helm repository

| Name                                         | Description                                                                                                    | Value   |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceArgoHelmRepo.enabled`                | Enable or disable replacing the Argo Helm repository                                                           | `false` |
| `replaceArgoHelmRepo.excludeNamespaces`      | Namespaces to exclude from replacing the argo helm repo                                                        | `[]`    |
| `replaceArgoHelmRepo.includeNamespaces`      | Namespaces to include for replacing the argo helm repo. When non-empty, only these namespaces will be included | `[]`    |
| `replaceArgoHelmRepo.registryReplacementMap` | Map of source repoURL prefixes to target registries.                                                           | `{}`    |

### syncConfigMaps Configuration options for syncing ConfigMaps across namespaces

| Name                               | Description                                                                                          | Value   |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------- | ------- |
| `syncConfigMaps.enabled`           | Enable or disable syncing ConfigMaps across namespaces                                               | `false` |
| `syncConfigMaps.excludeNamespaces` | Namespaces to exclude from syncing ConfigMaps                                                        | `[]`    |
| `syncConfigMaps.includeNamespaces` | Namespaces to include for syncing ConfigMaps. When non-empty, only these namespaces will be included | `[]`    |
| `syncConfigMaps.items`             | List of ConfigMaps to sync across namespaces                                                         | `[]`    |

### syncSecrets Configuration options for syncing Secrets across namespaces

| Name                            | Description                                                                                       | Value   |
| ------------------------------- | ------------------------------------------------------------------------------------------------- | ------- |
| `syncSecrets.enabled`           | Enable or disable syncing Secrets across namespaces                                               | `false` |
| `syncSecrets.excludeNamespaces` | Namespaces to exclude from syncing Secrets                                                        | `[]`    |
| `syncSecrets.includeNamespaces` | Namespaces to include for syncing Secrets. When non-empty, only these namespaces will be included | `[]`    |
| `syncSecrets.items`             | List of Secrets to sync across namespaces                                                         | `[]`    |

### podVolumeMounts Configuration options for adding volume mounts to pods

| Name                                | Description                                                                                                    | Value   |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `podVolumeMounts.enabled`           | Enable or disable adding volume mounts to pods                                                                 | `false` |
| `podVolumeMounts.excludeNamespaces` | Namespaces to exclude from adding volume mounts to pods                                                        | `[]`    |
| `podVolumeMounts.includeNamespaces` | Namespaces to include for adding volume mounts to pods. When non-empty, only these namespaces will be included | `[]`    |
| `podVolumeMounts.objectSelector`    | Label selector to match specific pods. When set, only pods matching these labels will be mutated               | `{}`    |
| `podVolumeMounts.mountDetails`      | The details of the volume mounts to add                                                                        | `[]`    |
| `additionalKyvernoPolicies`         | Additional Kyverno clusterpolicies to apply                                                                    | `[]`    |
