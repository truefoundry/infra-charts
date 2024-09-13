# tfy-kyverno-config helm chart packaged by TrueFoundry
A Helm chart for kyverno configurations

## Parameters

### Configuration options for adding a CA certificate volume

| Name                                               | Description                                                                    | Value   |
| -------------------------------------------------- | ------------------------------------------------------------------------------ | ------- |
| `addCaCertificateVolume.enabled`                   | Enable or disable adding the CA certificate volume                             | `false` |
| `addCaCertificateVolume.sourceNamespace`           | The namespace where the source ConfigMap is located                            | `""`    |
| `addCaCertificateVolume.sourceConfigMap.name`      | The source ConfigMap name that contains the CA certificate                     | `""`    |
| `addCaCertificateVolume.sourceConfigMap.subPath`   | The subPath in the source ConfigMap where the CA certificate is located        | `""`    |
| `addCaCertificateVolume.destinationConfigMap.name` | The destination ConfigMap name where the CA certificate volume will be mounted | `""`    |
| `addCaCertificateVolume.excludeNamespaces`         | Namespaces to exclude from adding the CA certificate volume                    | `[]`    |
| `addCaCertificateVolume.injectionConfigs`          | Configuration options for injecting the CA certificate volume                  | `[]`    |
| `addCaCertificateVolume.envs`                      | Env variables to inject to the selected containers                             | `[]`    |

### replaceImageRegistry Configuration options for replacing the image registry

| Name                                     | Description                                                                                                     | Value                |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------- |
| `replaceImageRegistry.enabled`           | Enable or disable replacing the image registry                                                                  | `false`              |
| `replaceImageRegistry.excludeNamespaces` | Namespaces to exclude from replacing the image registry                                                         | `[]`                 |
| `replaceImageRegistry.includeNamespaces` | Namespaces to include from replacing the image registry. When non-empty, only these namespaces will be included | `[""]`               |
| `replaceImageRegistry.newRegistry`       | The new image registry to use                                                                                   | `random.example.com` |

### replaceArgoHelmRepo Configuration options for replacing the Argo Helm repository

| Name                                    | Description                                                                                                    | Value   |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceArgoHelmRepo.enabled`           | Enable or disable replacing the Argo Helm repository                                                           | `false` |
| `replaceArgoHelmRepo.excludeNamespaces` | Namespaces to exclude from replacing the argo helm repo                                                        | `[]`    |
| `replaceArgoHelmRepo.includeNamespaces` | Namespaces to include for replacing the argo helm repo. When non-empty, only these namespaces will be included | `[""]`  |
| `replaceArgoHelmRepo.newRegistry`       | The new Argo Helm registry URL                                                                                 | `""`    |
| `additionalKyvernoPolicies`             | Additional Kyverno clusterpolicies to apply                                                                    | `[]`    |
