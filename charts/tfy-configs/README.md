# TFY Configs helm chart packaged by TrueFoundry
TFY Configs is a Helm chart that allows configuring TrueFoundry Platform Features.

## Parameters

### configs Various Configurations

| Name                                 | Description                                                                                                                          | Value     |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| `configs.workbenchImages`            | Workbench images configuration. Please refer to files/workbench-images.yaml for default values and format.                           | `default` |
| `configs.imageMutationConfig`        | Image mutation configuration. Please refer to files/image-mutation-config.yaml for default values and format.                        | `default` |
| `configs.k8sManifestValidationRules` | K8s manifest validation rules configuration. Please refer to files/k8s-manifest-validation-rules.yaml for default values and format. | `default` |
