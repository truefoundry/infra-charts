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
