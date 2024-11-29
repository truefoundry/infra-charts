# Tfy-buildkitd-service helm chart packaged by TrueFoundry
Tfy-buildkitd-service is a Helm chart provided by TrueFoundry that facilitates the deployment and management of BuildKit services in Kubernetes clusters

## Parameters

########### Parameters for tfyBuildkitdService

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
