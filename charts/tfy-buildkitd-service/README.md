# Tfy-buildkitd-service helm chart packaged by TrueFoundry
Tfy-buildkitd-service is a Helm chart provided by TrueFoundry that facilitates the deployment and management of BuildKit services in Kubernetes clusters

## Parameters

############################################################### Parameters for tfyBuildkitdService

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `global.annotations`                          | Global annotations to be added to all resources                                                                   | `{}`                        |
| `global.labels`                               | Global labels to be added to all resources                                                                        | `{}`                        |
| `global.podLabels`                            | Labels to be added to statefulset pods                                                                            | `{}`                        |
| `global.podAnnotations`                       | Annotations to be added to statefulset pods                                                                       | `{}`                        |
| `global.statefulsetLabels`                    | Labels to be added to statefulset                                                                                 | `{}`                        |
| `global.statefulsetAnnotations`               | Annotations to be added to statefulset                                                                            | `{}`                        |
| `global.serviceAccount.name`                  | Service account name                                                                                              | `""`                        |
| `global.serviceAccount.labels`                | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `global.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `global.image.registry`                       | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                              | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.26.2`                   |
| `commonLabels`                                | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `commonAnnotations`                           | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `statefulsetLabels`                           | Labels to be added to the tfyBuildkitdService statefulset                                                         | `{}`                        |
| `statefulsetAnnotations`                      | Annotations to be added to the tfyBuildkitdService statefulset                                                    | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.labels`                       | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `global.annotations`                          | Global annotations to be added to all resources                                                                   | `{}`                        |
| `global.labels`                               | Global labels to be added to all resources                                                                        | `{}`                        |
| `global.podLabels`                            | Labels to be added to statefulset pods                                                                            | `{}`                        |
| `global.podAnnotations`                       | Annotations to be added to statefulset pods                                                                       | `{}`                        |
| `global.statefulsetLabels`                    | Labels to be added to statefulset                                                                                 | `{}`                        |
| `global.statefulsetAnnotations`               | Annotations to be added to statefulset                                                                            | `{}`                        |
| `global.serviceAccount.name`                  | Service account name                                                                                              | `""`                        |
| `global.serviceAccount.labels`                | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `global.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `global.image.registry`                       | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                              | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `commonLabels`                                | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `commonAnnotations`                           | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `statefulsetLabels`                           | Labels to be added to the tfyBuildkitdService statefulset                                                         | `{}`                        |
| `statefulsetAnnotations`                      | Annotations to be added to the tfyBuildkitdService statefulset                                                    | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.labels`                       | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `global.annotations`                          | Global annotations to be added to all resources                                                                   | `{}`                        |
| `global.labels`                               | Global labels to be added to all resources                                                                        | `{}`                        |
| `global.podLabels`                            | Labels to be added to statefulset pods                                                                            | `{}`                        |
| `global.podAnnotations`                       | Annotations to be added to statefulset pods                                                                       | `{}`                        |
| `global.statefulsetLabels`                    | Labels to be added to statefulset                                                                                 | `{}`                        |
| `global.statefulsetAnnotations`               | Annotations to be added to statefulset                                                                            | `{}`                        |
| `global.serviceAccount.name`                  | Service account name                                                                                              | `""`                        |
| `global.serviceAccount.labels`                | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `global.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `global.image.registry`                       | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                              | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `commonLabels`                                | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `commonAnnotations`                           | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `statefulsetLabels`                           | Labels to be added to the tfyBuildkitdService statefulset                                                         | `{}`                        |
| `statefulsetAnnotations`                      | Annotations to be added to the tfyBuildkitdService statefulset                                                    | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.labels`                       | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `global.annotations`                          | Global annotations to be added to all resources                                                                   | `{}`                        |
| `global.labels`                               | Global labels to be added to all resources                                                                        | `{}`                        |
| `global.podLabels`                            | Labels to be added to statefulset pods                                                                            | `{}`                        |
| `global.podAnnotations`                       | Annotations to be added to statefulset pods                                                                       | `{}`                        |
| `global.statefulsetLabels`                    | Labels to be added to statefulset                                                                                 | `{}`                        |
| `global.statefulsetAnnotations`               | Annotations to be added to statefulset                                                                            | `{}`                        |
| `global.serviceAccount.name`                  | Service account name                                                                                              | `""`                        |
| `global.serviceAccount.labels`                | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `global.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `global.image.registry`                       | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                              | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `statefulsetLabels`                           | Labels to be added to the tfyBuildkitdService statefulset                                                         | `{}`                        |
| `statefulsetAnnotations`                      | Annotations to be added to the tfyBuildkitdService statefulset                                                    | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.labels`                       | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `global.annotations`                          | Global annotations to be added to all resources                                                                   | `{}`                        |
| `global.labels`                               | Global labels to be added to all resources                                                                        | `{}`                        |
| `global.podLabels`                            | Labels to be added to statefulset pods                                                                            | `{}`                        |
| `global.podAnnotations`                       | Annotations to be added to statefulset pods                                                                       | `{}`                        |
| `global.statefulsetLabels`                    | Labels to be added to statefulset                                                                                 | `{}`                        |
| `global.statefulsetAnnotations`               | Annotations to be added to statefulset                                                                            | `{}`                        |
| `global.serviceAccount.name`                  | Service account name                                                                                              | `""`                        |
| `global.serviceAccount.labels`                | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `global.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `global.image.registry`                       | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                              | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `statefulsetLabels`                           | Labels to be added to the tfyBuildkitdService statefulset                                                         | `{}`                        |
| `statefulsetAnnotations`                      | Annotations to be added to the tfyBuildkitdService statefulset                                                    | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.labels`                       | Labels to add to the serviceAccount                                                                               | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `global.image.registry`                         | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                                | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `global.image.registry`                         | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                                | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `global.image.registry`                         | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                                | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `global.image.registry`                         | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                                | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `tfy-mirror/moby/buildkit`  |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `global.image.registry`                         | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `tfy.jfrog.io`              |
| `image.registry`                                | Image registry for tfyBuildkitdService (defaults to global.image.registry if not set)                             | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                            | Description                                                                                                       | Value                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                           | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                               | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                            | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                           | Node selector                                                                                                     | `{}`                        |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name                                                                       | `""`                        |
| `global.serviceAccount.name`                    | Service account name                                                                                              | `""`                        |
| `image.repository`                              | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                              | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                     | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                        | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                   | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                               | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                           | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                      | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                              | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                  | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                              | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                         | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                    | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken`   | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                           | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                     | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                                | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                            | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                    | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                  | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                  | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                  | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                             | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                     | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                  | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                   | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                      | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`             | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`             | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                   | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `false`                     |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `false`                     |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `true`                      |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `true`                      |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.23.2`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `true`                      |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                          | Description                                                                                                       | Value                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`                         | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`                         | Node selector                                                                                                     | `{}`                        |
| `image.repository`                            | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                            | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                                   | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                                      | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                                 | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                             | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                         | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`                    | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                            | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                                | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                            | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                                                                                   | `true`                      |
| `serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                                   | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                              | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                          | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`                  | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                                | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                                | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                                | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                           | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                                   | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                                 | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                                    | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`           | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`           | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                                 | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podLabels`                         | Labels to be added to the tfyBuildkitdService pod                                                                 | `{}`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `commonLabels`                      | Common labels to be added to the tfyBuildkitdService                                                              | `{}`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `commonLabels`                      | Common labels to be added to the tfyBuildkitdService                                                              | `{}`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `global.nodeSelector`               | Node selector                                                                                                     | `{}`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `global.affinity`                   | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `global.tolerations`                | Tolerations for pod scheduling on a node                                                                          | `[]`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                | Description                                                                                                       | Value                       |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `global.resourceTier`               | Resource deployment type                                                                                          | `""`                        |
| `image.repository`                  | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                  | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                         | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                            | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                       | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                   | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`               | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`          | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `imagePullSecrets`                  | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                      | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                  | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`             | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`        | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`               | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                    | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`        | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                      | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                      | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `extraVolumes`                      | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                 | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                         | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                      | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                       | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                          | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName` | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName` | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                       | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                               | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                          | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `labels`                               | Labels to be added to the tfyBuildkitdService                                                                     | `{}`                        |
| `annotations`                          | Annotations to be added to the tfyBuildkitdService                                                                | `{}`                        |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.17.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `true`                      |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.enabled`                      | Bool to enable storage for tfyBuildkitdService                                                                    | `false`                     |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `2000m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `8Gi`                       |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `2000m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `8Gi`                       |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `3500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `13.2Gi`                    |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `3500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `13.2Gi`                    |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |

| Name                                   | Description                                                                                                       | Value                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                         | Number of replicas of  Value kept for future use, kept 1                                                          | `1`                         |
| `image.repository`                     | tfyBuildkitdService repository                                                                                    | `moby/buildkit`             |
| `image.pullPolicy`                     | Pull policy for tfyBuildkitdService                                                                               | `IfNotPresent`              |
| `image.tag`                            | Image tag whose default is the chart appVersion.                                                                  | `v0.16.0`                   |
| `storage.accessModes`                  | Access mode for tfyBuildkitdService                                                                               | `["ReadWriteOnce"]`         |
| `storage.storageClassName`             | Storage class name for tfyBuildkitdService                                                                        | `""`                        |
| `storage.size`                         | Size of the storage for tfyBuildkitdService                                                                       | `200Gi`                     |
| `imagePullSecrets`                     | Secrets to pull images                                                                                            | `[]`                        |
| `nameOverride`                         | String to override partial name passed in helm install command                                                    | `""`                        |
| `fullnameOverride`                     | String to override full name passed in helm install command                                                       | `""`                        |
| `serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                      |
| `serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                        |
| `serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                        |
| `podAnnotations`                       | Annotations to be added to the pod                                                                                | `{}`                        |
| `podSecurityContext`                   | Security context for the pod                                                                                      | `{}`                        |
| `securityContext.privileged`           | Security Context for the tfyBuildkitdServiceProxy container                                                       | `true`                      |
| `service.type`                         | Type for tfyBuildkitdService Service                                                                              | `ClusterIP`                 |
| `service.port`                         | Port for tfyBuildkitdService service                                                                              | `1234`                      |
| `resources.limits.cpu`                 | CPU resource limits for tfyBuildkitdService container.                                                            | `3500m`                     |
| `resources.limits.memory`              | Memory Resource limits for tfyBuildkitdService container.                                                         | `13.2Gi`                    |
| `resources.limits.ephemeral-storage`   | Ephemeral Storage limits for tfyBuildkitdService container.                                                       | `100Mi`                     |
| `resources.requests.cpu`               | CPU resource requests for tfyBuildkitdService container.                                                          | `3500m`                     |
| `resources.requests.memory`            | Memory Resource requests for tfyBuildkitdService container.                                                       | `13.2Gi`                    |
| `resources.requests.ephemeral-storage` | Ephemeral Storage requests for tfyBuildkitdService container.                                                     | `100Mi`                     |
| `extraVolumes`                         | List of Volumes to attach to tfyBuildkitdService container                                                        | `[]`                        |
| `extraVolumeMounts`                    | List of Volume Mounts to attach to tfyBuildkitdService container                                                  | `[]`                        |
| `extraEnvs`                            | List of Environment Variables to attach to tfyBuildkitdService container                                          | `[]`                        |
| `nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                        |
| `tolerations`                          | Taints that pod can tolerate                                                                                      | `[]`                        |
| `affinity`                             | Affinity rules for pod scheduling on a node                                                                       | `{}`                        |
| `tls.buildkitDaemonCertsSecretName`    | Name of secret containing the buildkit daemon certs                                                               | `tfy-buildkit-daemon-certs` |
| `tls.buildkitClientCertsSecretName`    | Name of secret containing the buildkit client certs                                                               | `tfy-buildkit-client-certs` |
| `tls.enabled`                          | Enable TLS for buildkitd                                                                                          | `false`                     |
