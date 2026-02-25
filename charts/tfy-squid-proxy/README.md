# Tfy-squid-proxy helm chart packaged by TrueFoundry
Tfy-squid-proxy is a Helm chart that facilitates the deployment and management of Squid forward proxy for HTTP/HTTPS traffic forwarding.

## Parameters

### Squid Proxy Configuration

| Name                                         | Description                                                    | Value                     |
| -------------------------------------------- | -------------------------------------------------------------- | ------------------------- |
| `global.resourceTier`                        | Resource deployment type                                       | `medium`                  |
| `global.imagePullSecrets`                    | Existing truefoundry image pull secret name                    | `[]`                      |
| `global.truefoundryImagePullConfigJSON`      | Truefoundry image pull secret JSON                             | `""`                      |
| `global.affinity`                            | Affinity rules for pod scheduling on a node                    | `{}`                      |
| `global.labels`                              | Global labels                                                  | `{}`                      |
| `global.annotations`                         | Global annotations                                             | `{}`                      |
| `global.podLabels`                           | Global pod labels                                              | `{}`                      |
| `global.podAnnotations`                      | Global pod annotations                                         | `{}`                      |
| `global.deploymentLabels`                    | Global deployment labels                                       | `{}`                      |
| `global.deploymentAnnotations`               | Global deployment annotations                                  | `{}`                      |
| `global.serviceAnnotations`                  | Global service annotations                                     | `{}`                      |
| `global.serviceLabels`                       | Global service labels                                          | `{}`                      |
| `global.tolerations`                         | Tolerations for pod scheduling on a node                       | `[]`                      |
| `global.nodeSelector`                        | Node selector                                                  | `{}`                      |
| `global.image.registry`                      | Global image registry override                                 | `tfy.jfrog.io`            |
| `global.namespaceOverride`                   | Namespace override (defaults to .Release.Namespace if not set) | `""`                      |
| `fullnameOverride`                           | Full name override for the tfy-squid-proxy                     | `""`                      |
| `nameOverride`                               | Name override                                                  | `""`                      |
| `replicas`                                   | Number of replicas of squid proxy service                      | `3`                       |
| `commonLabels`                               | Common labels                                                  | `{}`                      |
| `commonAnnotations`                          | Common annotations                                             | `{}`                      |
| `podLabels`                                  | Pod labels                                                     | `{}`                      |
| `podAnnotations`                             | Pod annotations                                                | `{}`                      |
| `deploymentLabels`                           | Deployment labels                                              | `{}`                      |
| `deploymentAnnotations`                      | Deployment annotations                                         | `{}`                      |
| `image.registry`                             | Image registry for squid proxy                                 | `""`                      |
| `image.repository`                           | Image repository for squid proxy                               | `tfy-mirror/ubuntu/squid` |
| `image.tag`                                  | Image tag for squid proxy                                      | `6.6-24.04_edge`          |
| `image.pullPolicy`                           | Image pull policy                                              | `IfNotPresent`            |
| `imagePullSecrets`                           | Image pull secrets                                             | `[]`                      |
| `service.type`                               | Service type                                                   | `ClusterIP`               |
| `service.port`                               | Service port                                                   | `3128`                    |
| `service.annotations`                        | Service annotations                                            | `{}`                      |
| `service.labels`                             | Service labels                                                 | `{}`                      |
| `autoscaling.enabled`                        | Enable autoscaling                                             | `false`                   |
| `autoscaling.minReplicas`                    | Minimum number of replicas                                     | `3`                       |
| `autoscaling.maxReplicas`                    | Maximum number of replicas                                     | `100`                     |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage                              | `60`                      |
| `tolerations`                                | Tolerations                                                    | `[]`                      |
| `affinity`                                   | Affinity                                                       | `{}`                      |
| `nodeSelector`                               | Node selector                                                  | `{}`                      |
| `containerSecurityContext`                   | Container Security Context                                     | `{}`                      |
| `podSecurityContext`                         | Pod Security Context                                           | `{}`                      |

