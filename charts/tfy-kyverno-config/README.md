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

| Name                                          | Description                                                                                                                                                        | Value   |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `replaceImageRegistry.enabled`                | Enable or disable replacing the image registry                                                                                                                     | `false` |
| `replaceImageRegistry.excludeNamespaces`      | Namespaces to exclude from replacing the image registry                                                                                                            | `[]`    |
| `replaceImageRegistry.includeNamespaces`      | Namespaces to include from replacing the image registry. When non-empty, only these namespaces will be included                                                    | `[]`    |
| `replaceImageRegistry.registryReplacementMap` | Map of source registry prefixes to target registries. Use `"*"` as wildcard default (strips source registry, keeps image path). Per-source overrides take priority | `{}`    |

### replaceArgoHelmRepo Configuration options for replacing the Argo Helm repository

| Name                                         | Description                                                                                                                                                      | Value   |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replaceArgoHelmRepo.enabled`                | Enable or disable replacing the Argo Helm repository                                                                                                             | `false` |
| `replaceArgoHelmRepo.excludeNamespaces`      | Namespaces to exclude from replacing the argo helm repo                                                                                                          | `[]`    |
| `replaceArgoHelmRepo.includeNamespaces`      | Namespaces to include for replacing the argo helm repo. When non-empty, only these namespaces will be included                                                  | `[]`    |
| `replaceArgoHelmRepo.registryReplacementMap` | Map of source repoURL prefixes to target registries. Use `"*"` as wildcard default (strips host, keeps path). Per-source overrides take priority                | `{}`    |

### syncConfigMaps Configuration options for syncing ConfigMaps across namespaces

| Name                               | Description                                                                                                                                                                                                | Value   |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `syncConfigMaps.enabled`           | Enable or disable syncing ConfigMaps across namespaces                                                                                                                                                     | `false` |
| `syncConfigMaps.useClusterPolicy`  | Use ClusterPolicy (`kyverno.io/v1`) instead of GeneratingPolicy (`policies.kyverno.io/v1`). ClusterPolicy supports wildcard namespace patterns (for example `tfy-*`) and mature `generateExisting` support | `true`  |
| `syncConfigMaps.excludeNamespaces` | Namespaces to exclude from syncing ConfigMaps. Supports wildcard patterns when `useClusterPolicy` is `true`                                                                                                | `[]`    |
| `syncConfigMaps.includeNamespaces` | Namespaces to include for syncing ConfigMaps. When non-empty, only these namespaces will be included. Supports wildcard patterns (for example `tfy-*`) when `useClusterPolicy` is `true`                      | `[]`    |
| `syncConfigMaps.items`             | List of ConfigMaps to sync. Each entry requires `namespace` (source) and `name`                                                                                                                            | `[]`    |

Example:

```yaml
syncConfigMaps:
  enabled: true
  includeNamespaces:
    - tfy-*
  items:
    - namespace: truefoundry
      name: ca-cert-bundle
```

### syncSecrets Configuration options for syncing Secrets across namespaces

Syncing secrets requires additional RBAC permissions for the Kyverno admission and background controllers. Configure those permissions in the Kyverno Helm chart values.

| Name                            | Description                                                                                                                                                                                                | Value   |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `syncSecrets.enabled`           | Enable or disable syncing Secrets across namespaces                                                                                                                                                        | `false` |
| `syncSecrets.useClusterPolicy`  | Use ClusterPolicy (`kyverno.io/v1`) instead of GeneratingPolicy (`policies.kyverno.io/v1`). ClusterPolicy supports wildcard namespace patterns (for example `tfy-*`) and mature `generateExisting` support | `true`  |
| `syncSecrets.excludeNamespaces` | Namespaces to exclude from syncing Secrets. Supports wildcard patterns when `useClusterPolicy` is `true`                                                                                                   | `[]`    |
| `syncSecrets.includeNamespaces` | Namespaces to include for syncing Secrets. When non-empty, only these namespaces will be included. Supports wildcard patterns (for example `tfy-*`) when `useClusterPolicy` is `true`                     | `[]`    |
| `syncSecrets.items`             | List of Secrets to sync. Each entry requires `namespace` (source) and `name`                                                                                                                               | `[]`    |

Example:

```yaml
syncSecrets:
  enabled: true
  includeNamespaces:
    - tfy-*
  items:
    - namespace: truefoundry
      name: my-tls-secret
```

### podVolumeMounts Configuration options for adding volume mounts to pods

Supports mounting **ConfigMaps** and **Secrets**. When `useClusterPolicy` is `true` (default), the chart renders a `ClusterPolicy` with wildcard namespace support, optional env vars, `readOnly` mounts, and ConfigMap `items`. Set `useClusterPolicy: false` to use a `MutatingPolicy` instead (simpler volume-only mounts, no wildcards).

| Name                                       | Description                                                                                                                                                            | Value   |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `podVolumeMounts.enabled`                  | Enable or disable adding volume mounts to pods                                                                                                                         | `false` |
| `podVolumeMounts.useClusterPolicy`         | Use ClusterPolicy (`kyverno.io/v1`) instead of MutatingPolicy (`policies.kyverno.io/v1`)                                                                             | `true`  |
| `podVolumeMounts.policyName`               | Name of the ClusterPolicy when `useClusterPolicy` is `true`. Defaults to `<release-name>-pod-volume-mounts`                                                            | `""`    |
| `podVolumeMounts.configMapName`            | ConfigMap name for the built-in default CA mount from `files/default-pod-volume-mounts.yaml`. Used when `mountDetails` is not overridden. Defaults to `ca-cert-bundle` | `""`    |
| `podVolumeMounts.mountInitContainers`      | Also mount volumes into init containers                                                                                                                                | `false` |
| `podVolumeMounts.excludeNamespaces`        | Namespaces to exclude. Supports wildcard patterns when `useClusterPolicy` is `true`                                                                                    | `[]`    |
| `podVolumeMounts.includeNamespaces`        | Namespaces to include. When non-empty, only these namespaces are matched. Supports wildcard patterns (for example `tfy-*`) when `useClusterPolicy` is `true`           | `[]`    |
| `podVolumeMounts.objectSelector`           | Label selector to match specific pods                                                                                                                                  | `{}`    |
| `podVolumeMounts.mountDetails`             | Override chart default volume mounts from `files/default-pod-volume-mounts.yaml`. When empty, chart defaults are used                                                  | `[]`    |
| `podVolumeMounts.additionalMountDetails`   | Additional volume mounts appended to the effective mount list                                                                                                          | `[]`    |

#### Mount entry fields

Each item in `mountDetails` or `additionalMountDetails` supports:

| Field            | Required      | Description                                                         |
| ---------------- | ------------- | ------------------------------------------------------------------- |
| `type`           | Yes           | `configMap` or `secret`                                             |
| `configMapName`  | For ConfigMap | Name of the ConfigMap to mount                                      |
| `secretName`     | For Secret    | Name of the Secret to mount                                         |
| `volumeName`     | No            | Kubernetes volume name. Defaults to `configMapName` or `secretName` |
| `mountPath`      | Yes           | Container mount path                                                |
| `subPath`        | No            | Sub-path within the volume                                          |
| `readOnly`       | No            | Mount as read-only                                                  |
| `configMapItems` | No            | ConfigMap key/path mapping (ConfigMap only)                         |
| `envVars`        | No            | Environment variables to inject (map of name to value)              |

#### Examples

Use chart defaults (CA bundle ConfigMap mount):

```yaml
podVolumeMounts:
  enabled: true
  includeNamespaces:
    - tfy-*
  configMapName: ca-cert-bundle
```

Override the default ConfigMap name only:

```yaml
podVolumeMounts:
  enabled: true
  configMapName: my-company-ca-bundle
```

Append a Secret mount alongside the default CA mount:

```yaml
podVolumeMounts:
  enabled: true
  includeNamespaces:
    - tfy-*
  additionalMountDetails:
    - type: secret
      secretName: my-tls-secret
      mountPath: /etc/tls
      readOnly: true
```

Replace defaults with a custom mount list:

```yaml
podVolumeMounts:
  enabled: true
  mountDetails:
    - type: secret
      secretName: my-secret
      mountPath: /var/run/secrets/my-secret
      subPath: token
      readOnly: true
```

Full custom CA + init container mounts:

```yaml
podVolumeMounts:
  enabled: true
  policyName: custom-ca-cert-policy
  configMapName: ca-cert-bundle
  mountInitContainers: true
  includeNamespaces:
    - tfy-*
```

### additionalKyvernoPolicies

| Name                          | Description                                               | Value |
| ----------------------------- | --------------------------------------------------------- | ----- |
| `additionalKyvernoPolicies`   | Additional raw Kyverno ClusterPolicy manifests to apply   | `[]`  |
