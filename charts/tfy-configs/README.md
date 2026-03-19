# TFY Configs helm chart packaged by TrueFoundry
TFY Configs is a Helm chart that allows configuring TrueFoundry Platform Features.

## Parameters

### Global parameters for Various Configurations

| Name                       | Description                                                                      | Value |
| -------------------------- | -------------------------------------------------------------------------------- | ----- |
| `global.namespaceOverride` | Override namespace for the image configurations (defaults to .Release.Namespace) | `""`  |

### configs Various Configurations

| Name                                          | Description                                                                                                                                                                                                                                 | Value     |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `configs.workbenchImages`                     | Workbench images configuration. Please refer to files/workbench-images.yaml for default values and format.                                                                                                                                  | `default` |
| `configs.imageMutationPolicyOverride`         | Image mutation configuration. Please refer to files/image-mutation-policy.yaml for default values and format.                                                                                                                               | `{}`      |
| `configs.k8sManifestValidationPolicyOverride` | K8s manifest validation policy configuration. Please refer to files/k8s-manifest-validation-policy.yaml for default values and format.                                                                                                      | `{}`      |
| `configs.cicdTemplates`                       | CICD templates configuration. Please refer to files/cicd-templates.yaml for default values and format. key of this map is yaml file name and value is the file contents. You must have a key named `cicd-providers.yaml` in this dictionary | `{}`      |
| `configs.codeSnippet.chat`                    | Chat templates configuration. Please refer to files/llm-gateway-codesnippet/chat/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                                      | `{}`      |
| `configs.codeSnippet.embedding`               | Embedding templates configuration. Please refer to files/llm-gateway-codesnippet/embedding/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                            | `{}`      |
| `configs.codeSnippet.image`                   | Image templates configuration. Please refer to files/llm-gateway-codesnippet/image/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                                    | `{}`      |
| `configs.codeSnippet.realtime`                | Realtime templates configuration. Please refer to files/llm-gateway-codesnippet/realtime/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                              | `{}`      |
| `configs.codeSnippet.rerank`                  | Rerank templates configuration. Please refer to files/llm-gateway-codesnippet/rerank/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                                  | `{}`      |
| `configs.codeSnippet.speech`                  | Speech templates configuration. Please refer to files/llm-gateway-codesnippet/speech/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                                  | `{}`      |
| `configs.codeSnippet.transcription`           | Transcription templates configuration. Please refer to files/llm-gateway-codesnippet/transcription/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                    | `{}`      |
| `configs.codeSnippet.translation`             | Translation templates configuration. Please refer to files/llm-gateway-codesnippet/translation/*.ejs for default values and format. key of this map is ejs file name and value is the file contents.                                        | `{}`      |
