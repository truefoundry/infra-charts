# llm-gateway helm chart by Truefoundry
LLM-Gateway Helm Chart 

## Parameters

### Configuration for LLM Gateway

| Name                                         | Description                                | Value                                             |
| -------------------------------------------- | ------------------------------------------ | ------------------------------------------------- |
| `global.controlPlaneURL`                     | Control plane URL                          | `""`                                              |
| `global.truefoundryReleaseName`              | Truefoundry release name                   | `truefoundry`                                     |
| `global.llmGatewayInfra.enabled`             | Bool if llm gateway infra is enabled       | `false`                                           |
| `global.llmGatewayInfra.releaseName`         | Release name for the tfy-llm-gateway-infra | `tfy-llm-gateway-infra`                           |
| `global.llmGatewayInfra.natsAdminPassword`   | NATS admin password                        | `""`                                              |
| `image.repository`                           | Image repository for tfyLLMGateway         | `tfy.jfrog.io/tfy-private-images/tfy-llm-gateway` |
| `image.tag`                                  | Image tag for the tfyLLMGateway            | `bfc96b2a5ce10fce8a9af09821c8da911baa5ba7`        |
| `fullnameOverride`                           | Full name override for the tfy-llm-gateway | `""`                                              |
| `replicaCount`                               | Number of replicas                         | `1`                                               |
| `environmentName`                            | The environment name                       | `default`                                         |
| `envSecretName`                              | The environment secret name                | `tfy-llm-gateway-env-secret`                      |
| `imagePullPolicy`                            | Image pull policy                          | `IfNotPresent`                                    |
| `nameOverride`                               | Name override                              | `""`                                              |
| `podAnnotations`                             | Pod annotations                            | `{}`                                              |
| `podSecurityContext`                         | Pod security context                       | `{}`                                              |
| `commonLabels`                               | Common labels                              | `{}`                                              |
| `securityContext`                            | Security context configuration             | `{}`                                              |
| `healthcheck.enabled`                        | Enable healthcheck                         | `true`                                            |
| `healthcheck.readiness.port`                 | Port to probe                              | `8787`                                            |
| `healthcheck.readiness.path`                 | Path to probe                              | `/`                                               |
| `healthcheck.readiness.initialDelaySeconds`  | Initial delay in seconds                   | `10`                                              |
| `healthcheck.readiness.periodSeconds`        | Period in seconds                          | `10`                                              |
| `healthcheck.readiness.timeoutSeconds`       | Timeout in seconds                         | `5`                                               |
| `healthcheck.readiness.successThreshold`     | Success threshold                          | `1`                                               |
| `healthcheck.readiness.failureThreshold`     | Failure threshold                          | `3`                                               |
| `healthcheck.liveness.port`                  | Port to probe                              | `8787`                                            |
| `healthcheck.liveness.path`                  | Path to probe                              | `/`                                               |
| `resources.limits.cpu`                       | CPU limit                                  | `2`                                               |
| `resources.limits.memory`                    | Memory limit                               | `1024Mi`                                          |
| `resources.limits.ephemeral-storage`         | Ephemeral storage limit                    | `512Mi`                                           |
| `resources.requests.cpu`                     | CPU request                                | `1`                                               |
| `resources.requests.memory`                  | Memory request                             | `512Mi`                                           |
| `resources.requests.ephemeral-storage`       | Ephemeral storage request                  | `256Mi`                                           |
| `nodeSelector`                               | Node selector                              | `{}`                                              |
| `tolerations`                                | Tolerations                                | `{}`                                              |
| `affinity`                                   | Affinity                                   | `{}`                                              |
| `topologySpreadConstraints`                  | Topology spread constraints                | `{}`                                              |
| `ingress.enabled`                            | Enable ingress configuration               | `false`                                           |
| `ingress.annotations`                        | Ingress annotations                        | `{}`                                              |
| `ingress.labels`                             | Ingress labels                             | `{}`                                              |
| `ingress.ingressClassName`                   | Ingress class name                         | `istio`                                           |
| `ingress.tls`                                | Ingress TLS configuration                  | `[]`                                              |
| `ingress.hosts`                              | Ingress hosts                              | `[]`                                              |
| `istio.virtualservice.enabled`               | Enable virtual service                     | `false`                                           |
| `istio.virtualservice.annotations`           | Virtual service annotations                | `{}`                                              |
| `istio.virtualservice.gateways`              | Virtual service gateways                   | `[]`                                              |
| `istio.virtualservice.hosts`                 | Virtual service hosts                      | `[]`                                              |
| `service.type`                               | Service type                               | `ClusterIP`                                       |
| `service.port`                               | Service port                               | `8787`                                            |
| `service.annotations`                        | Service annotations                        | `{}`                                              |
| `serviceAccount.create`                      | Create service account                     | `true`                                            |
| `serviceAccount.annotations`                 | Service account annotations                | `{}`                                              |
| `serviceAccount.name`                        | Service account name                       | `tfy-llm-gateway`                                 |
| `extraVolumes`                               | Extra volumes                              | `[]`                                              |
| `extraVolumeMounts`                          | Extra volume mounts                        | `[]`                                              |
| `rbac.enabled`                               | Enable rbac                                | `true`                                            |
| `autoscaling.enabled`                        | Enable autoscaling                         | `true`                                            |
| `autoscaling.minReplicas`                    | Minimum number of replicas                 | `3`                                               |
| `autoscaling.maxReplicas`                    | Maximum number of replicas                 | `100`                                             |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage          | `60`                                              |
