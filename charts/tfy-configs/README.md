# TFY Configs helm chart packaged by TrueFoundry
TFY Configs is a Helm chart that allows configuring TrueFoundry Platform Features.

## Parameters

### configs Various Configurations

| Name                                          | Description                                                                                                                                                                                                                                 | Value     |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `configs.workbenchImages`                     | Workbench images configuration. Please refer to files/workbench-images.yaml for default values and format.                                                                                                                                  | `default` |
| `configs.imageMutationPolicyOverride`         | Image mutation configuration. Please refer to files/image-mutation-policy.yaml for default values and format.                                                                                                                               | `{}`      |
| `configs.k8sManifestValidationPolicyOverride` | K8s manifest validation policy configuration. Please refer to files/k8s-manifest-validation-policy.yaml for default values and format.                                                                                                      | `{}`      |
| `configs.cicdTemplates`                       | CICD templates configuration. Please refer to files/cicd-templates.yaml for default values and format. key of this map is yaml file name and value is the file contents. You must have a key named `cicd-providers.yaml` in this dictionary | `{}`      |
