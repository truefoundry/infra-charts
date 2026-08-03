# tfy-kyverno-config helm chart packaged by TrueFoundry

A Helm chart for Kyverno cluster policies used in TrueFoundry deployments.

## Overview

This chart can deploy the following Kyverno policies:

| Policy                       | Values key                   | Description                                                               |
| ---------------------------- | ---------------------------- | ------------------------------------------------------------------------- |
| Image registry replacement   | `replaceImageRegistry`       | Rewrites container image registries on workloads                          |
| Argo Helm repo replacement   | `replaceArgoHelmRepo`        | Rewrites Argo CD `repoURL` values                                         |
| ConfigMap sync               | `syncConfigMaps`             | Clones ConfigMaps from a source namespace into matching target namespaces |
| Secret sync                  | `syncSecrets`                | Clones Secrets from a source namespace into matching target namespaces    |
| Pod volume mounts            | `podVolumeMounts`            | Injects volumes and volume mounts (ConfigMap or Secret) into pods         |
| Custom policies              | `additionalKyvernoPolicies`  | Renders additional raw Kyverno `ClusterPolicy` manifests                  |

### Custom CA certificate workflow

A common setup is to sync a CA bundle ConfigMap and mount it into application pods:

1. Create `ca-cert-bundle` in a source namespace (for example `truefoundry`).
2. Enable `syncConfigMaps` to clone it into target namespaces (for example `tfy-*`).
3. Enable `podVolumeMounts` to mount the synced ConfigMap and set SSL-related environment variables.

Chart defaults for the pod volume mount policy live in `files/default-pod-volume-mounts.yaml`. When `podVolumeMounts.mountDetails` is empty, those defaults are used. Override the ConfigMap name with `podVolumeMounts.configMapName` (defaults to `ca-cert-bundle`).

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

| Name                               | Description                                                                                                                                                                                          | Value   |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `syncConfigMaps.enabled`           | Enable or disable syncing ConfigMaps across namespaces                                                                                                                                               | `false` |
| `syncConfigMaps.useClusterPolicy`  | Use ClusterPolicy (kyverno.io/v1) instead of GeneratingPolicy (policies.kyverno.io/v1). ClusterPolicy has more mature generateExisting support and supports wildcard namespace patterns (e.g. tfy-*) | `true`  |
| `syncConfigMaps.excludeNamespaces` | Namespaces to exclude from syncing ConfigMaps                                                                                                                                                        | `[]`    |
| `syncConfigMaps.includeNamespaces` | Namespaces to include for syncing ConfigMaps. When non-empty, only these namespaces will be included. Supports wildcard patterns (e.g. tfy-*) when useClusterPolicy is true                          | `[]`    |
| `syncConfigMaps.items`             | List of ConfigMaps to sync across namespaces                                                                                                                                                         | `[]`    |

### syncSecrets Configuration options for syncing Secrets across namespaces

| Name                            | Description                                                                                                                                                                                          | Value   |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `syncSecrets.enabled`           | Enable or disable syncing Secrets across namespaces                                                                                                                                                  | `false` |
| `syncSecrets.useClusterPolicy`  | Use ClusterPolicy (kyverno.io/v1) instead of GeneratingPolicy (policies.kyverno.io/v1). ClusterPolicy has more mature generateExisting support and supports wildcard namespace patterns (e.g. tfy-*) | `true`  |
| `syncSecrets.excludeNamespaces` | Namespaces to exclude from syncing Secrets                                                                                                                                                           | `[]`    |
| `syncSecrets.includeNamespaces` | Namespaces to include for syncing Secrets. When non-empty, only these namespaces will be included. Supports wildcard patterns (e.g. tfy-*) when useClusterPolicy is true                             | `[]`    |
| `syncSecrets.items`             | List of Secrets to sync across namespaces                                                                                                                                                            | `[]`    |

### podVolumeMounts Configuration options for adding volume mounts to pods

| Name                                     | Description                                                                                                                                                                                                            | Value   |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `podVolumeMounts.enabled`                | Enable or disable adding volume mounts to pods                                                                                                                                                                         | `false` |
| `podVolumeMounts.useClusterPolicy`       | Use ClusterPolicy (kyverno.io/v1) instead of MutatingPolicy (policies.kyverno.io/v1). ClusterPolicy supports wildcard namespace patterns (e.g. tfy-*), configMap items, env vars, and readOnly volume mounts           | `true`  |
| `podVolumeMounts.policyName`             | Name of the ClusterPolicy when useClusterPolicy is true. Defaults to `<release-name>-pod-volume-mounts`                                                                                                                | `""`    |
| `podVolumeMounts.configMapName`          | Default ConfigMap name for the built-in CA volume mount. Used when mountDetails is not overridden                                                                                                                      | `""`    |
| `podVolumeMounts.mountInitContainers`    | Mount volumes into init containers when enabled                                                                                                                                                                        | `false` |
| `podVolumeMounts.excludeNamespaces`      | Namespaces to exclude from adding volume mounts to pods. Supports wildcard patterns (e.g. tfy-*) when useClusterPolicy is true                                                                                         | `[]`    |
| `podVolumeMounts.includeNamespaces`      | Namespaces to include for adding volume mounts to pods. When non-empty, only these namespaces will be included. Supports wildcard patterns (e.g. tfy-*) when useClusterPolicy is true                                  | `[]`    |
| `podVolumeMounts.objectSelector`         | Label selector to match specific pods. When set, only pods matching these labels will be mutated                                                                                                                       | `{}`    |
| `podVolumeMounts.mountDetails`           | Override the chart default volume mounts from files/default-pod-volume-mounts.yaml. When empty, chart defaults are used. Set configMapName on each entry or use podVolumeMounts.configMapName for the built-in default | `[]`    |
| `podVolumeMounts.additionalMountDetails` | Additional volume mounts appended to the effective mount list                                                                                                                                                          | `[]`    |
| `additionalKyvernoPolicies`              | Additional Kyverno clusterpolicies to apply                                                                                                                                                                            | `[]`    |
