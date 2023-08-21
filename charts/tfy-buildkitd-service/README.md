# Tfy-buildkitd-service helm chart packaged by TrueFoundry
Tfy-buildkitd-service is an <empty>

## Parameters

### image Image of tfyBuildkitdService

| Name                                         | Description                                                                                                           | Value           |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------- |
| `image.repository`                           | tfyBuildkitdService repository                                                                                        | `moby/buildkit` |
| `image.pullPolicy`                           | Pull policy for tfyBuildkitdService                                                                                   | `IfNotPresent`  |
| `image.tag`                                  | Image tag whose default is the chart appVersion.                                                                      | `v0.12.0`       |
| `imagePullSecrets`                           | Secrets to pull images                                                                                                | `[]`            |
| `nameOverride`                               | String to override partial name passed in helm install command                                                        | `""`            |
| `fullnameOverride`                           | String to override full name passed in helm install command                                                           | `""`            |
| `serviceAccount.create`                      | Bool to enable serviceAccount creation                                                                                | `true`          |
| `serviceAccount.annotations`                 | Annotations to add to the serviceAccount                                                                              | `{}`            |
| `serviceAccount.name`                        | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template     | `""`            |
| `podAnnotations`                             | Annotations to be added to the pod                                                                                    | `{}`            |
| `podSecurityContext`                         | Security context for the pod                                                                                          | `{}`            |
| `securityContext.privileged`                 | Security Context for the tfyBuildkitdServiceProxy container                                                           | `true`          |
| `service.type`                               | Type for tfyBuildkitdService Service                                                                                  | `ClusterIP`     |
| `service.port`                               | Port for tfyBuildkitdService service                                                                                  | `1234`          |
| `resources.limits.cpu`                       | CPU resource limits for tfyBuildkitdService container. Advised to only increase the limits and not decrease it        | `2`             |
| `resources.limits.memory`                    | Memory Resource limits for tfyBuildkitdService container. Advised to only increase the limits and not decrease it     | `8Gi`           |
| `resources.requests.cpu`                     | CPU resource requests for tfyBuildkitdService container. Advised to only increase the requests and not decrease it    | `2`             |
| `resources.requests.memory`                  | Memory Resource requests for tfyBuildkitdService container. Advised to only increase the requests and not decrease it | `8Gi`           |
| `autoscaling.enabled`                        | Enable or disable autoscaling for the deployment.                                                                     | `true`          |
| `autoscaling.minReplicas`                    | Minimum number of replicas for autoscaling.                                                                           | `1`             |
| `autoscaling.maxReplicas`                    | Maximum number of replicas for autoscaling.                                                                           | `4`             |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling.                                                                    | `70`            |
| `nodeSelector`                               | Parameters to select for scheduling of pod on a node                                                                  | `{}`            |
| `tolerations`                                | Taints that pod can tolerate                                                                                          | `[]`            |
| `affinity`                                   | Affinity rules for pod scheduling on a node                                                                           | `{}`            |
