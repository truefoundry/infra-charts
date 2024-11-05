# llm-gateway helm chart by Truefoundry
LLM-Gateway Helm Chart 

## Parameters

### Configuration for LLM Gateway

| Name                                   | Description                        | Value                                             |
| -------------------------------------- | ---------------------------------- | ------------------------------------------------- |
| `global`                               | Truefoundry global values          | `{}`                                              |
| `image.repository`                     | Image repository for tfyLLMGateway | `tfy.jfrog.io/tfy-private-images/tfy-llm-gateway` |
| `image.tag`                            | Image tag for the tfyLLMGateway    | `be235b3aea5e5e9a651882250a488f91f32bef50`        |
| `replicaCount`                         | Number of replicas                 | `1`                                               |
| `environmentName`                      | The environment name               | `default`                                         |
| `envSecretName`                        | The environment secret name        | `tfy-llm-gateway-env-secret`                      |
| `imagePullPolicy`                      | Image pull policy                  | `IfNotPresent`                                    |
| `nameOverride`                         | Name override                      | `""`                                              |
| `fullnameOverride`                     | Fullname override                  | `""`                                              |
| `podAnnotations`                       | Pod annotations                    | `{}`                                              |
| `podSecurityContext`                   | Pod security context               | `{}`                                              |
| `commonLabels`                         | Common labels                      | `{}`                                              |
| `securityContext`                      | Security context configuration     | `{}`                                              |
| `healthcheck.enabled`                  | Enable healthcheck                 | `true`                                            |
| `healthcheck.readiness.port`           | Port to probe                      | `8787`                                            |
| `healthcheck.readiness.path`           | Path to probe                      | `/`                                               |
| `healthcheck.liveness.port`            | Port to probe                      | `8787`                                            |
| `healthcheck.liveness.path`            | Path to probe                      | `/`                                               |
| `resources.limits.cpu`                 | CPU limit                          | `400m`                                            |
| `resources.limits.memory`              | Memory limit                       | `512Mi`                                           |
| `resources.limits.ephemeral-storage`   | Ephemeral storage limit            | `256Mi`                                           |
| `resources.requests.cpu`               | CPU request                        | `200m`                                            |
| `resources.requests.memory`            | Memory request                     | `256Mi`                                           |
| `resources.requests.ephemeral-storage` | Ephemeral storage request          | `128Mi`                                           |
| `nodeSelector`                         | Node selector                      | `{}`                                              |
| `tolerations`                          | Tolerations                        | `{}`                                              |
| `affinity`                             | Affinity                           | `{}`                                              |
| `topologySpreadConstraints`            | Topology spread constraints        | `{}`                                              |
| `ingress.enabled`                      | Enable ingress configuration       | `false`                                           |
| `ingress.annotations`                  | Ingress annotations                | `{}`                                              |
| `ingress.labels`                       | Ingress labels                     | `{}`                                              |
| `ingress.ingressClassName`             | Ingress class name                 | `istio`                                           |
| `ingress.tls`                          | Ingress TLS configuration          | `[]`                                              |
| `ingress.hosts`                        | Ingress hosts                      | `[]`                                              |
| `istio.virtualservice.enabled`         | Enable virtual service             | `false`                                           |
| `istio.virtualservice.annotations`     | Virtual service annotations        | `{}`                                              |
| `istio.virtualservice.gateways`        | Virtual service gateways           | `[]`                                              |
| `istio.virtualservice.hosts`           | Virtual service hosts              | `[]`                                              |
| `service.type`                         | Service type                       | `ClusterIP`                                       |
| `service.port`                         | Service port                       | `8787`                                            |
| `service.annotations`                  | Service annotations                | `{}`                                              |
| `serviceAccount.create`                | Create service account             | `true`                                            |
| `serviceAccount.annotations`           | Service account annotations        | `{}`                                              |
| `serviceAccount.name`                  | Service account name               | `tfy-llm-gateway`                                 |
| `extraVolumes`                         | Extra volumes                      | `[]`                                              |
| `extraVolumeMounts`                    | Extra volume mounts                | `[]`                                              |
| `rbac.enabled`                         | Enable rbac                        | `true`                                            |
| `rateLimit.enabled`                    | Enable flag                        | `false`                                           |
| `rateLimit.config`                     | RL config                          | `{}`                                              |
| `autoscaling.enabled`                              | Enable autoscaling                           | `false` |
| `autoscaling.minReplicas`                          | Minimum number of replicas                   | `1`     |
| `autoscaling.maxReplicas`                          | Maximum number of replicas                   | `10`    |
| `autoscaling.targetCPUUtilizationPercentage`       | Target CPU utilization percentage            | `80`    |
| `healthcheck.readiness.initialDelaySeconds` | Initial delay before first probe | `10` |
| `healthcheck.readiness.periodSeconds` | How often to perform the probe | `10` |
| `healthcheck.readiness.timeoutSeconds` | When the probe times out | `5` |
| `healthcheck.readiness.successThreshold` | Minimum consecutive successes | `1` |
| `healthcheck.readiness.failureThreshold` | When to declare the pod unhealthy | `3` |
