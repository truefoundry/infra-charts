# Tfy-Otel_collector helm chart by Truefoundry
Tfy-Otel_collector Helm Chart 

## Parameters

### Configuration for Tfy-otel-collector

| Name                                            | Description                                                  | Value                                                |
| ----------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| `image.repository`                              | Image repository for tfyOTELCollector                        | `tfy.jfrog.io/tfy-private-images/tfy-otel-collector` |
| `image.tag`                                     | Image tag for the tfyOTELCollector                           | `b81d3f3694c700e5b3252920cad16613407ac2be`          |
| `fullnameOverride`                              | Full name override for the tfy-otel-collector                | `""`                                                 |
| `replicaCount`                                  | Number of replicas                                           | `2`                                                  |
| `environmentName`                               | The environment name                                         | `default`                                            |
| `envSecretName`                                 | The environment secret name                                  | `tfy-otel-collector-env-secret`                      |
| `imagePullPolicy`                               | Image pull policy                                            | `IfNotPresent`                                       |
| `nameOverride`                                  | Name override                                                | `""`                                                 |
| `podAnnotations`                                | Pod annotations                                              | `{}`                                                 |
| `commonAnnotations`                             | Common annotations                                           | `{}`                                                 |
| `podSecurityContext`                            | Pod security context                                         | `{}`                                                 |
| `commonLabels`                                  | Common labels                                                | `{}`                                                 |
| `securityContext`                               | Security context configuration                               | `{}`                                                 |
| `healthcheck.enabled`                           | Enable healthcheck                                           | `true`                                               |
| `healthcheck.liveness.port`                     | Port to probe                                                | `13133`                                              |
| `healthcheck.liveness.path`                     | Path to probe                                                | `/`                                                  |
| `healthcheck.liveness.initialDelaySeconds`      | Initial delay in seconds                                     | `30`                                                 |
| `healthcheck.liveness.periodSeconds`            | Period in seconds                                            | `10`                                                 |
| `healthcheck.liveness.timeoutSeconds`           | Timeout in seconds                                           | `5`                                                  |
| `healthcheck.liveness.successThreshold`         | Success threshold                                            | `1`                                                  |
| `healthcheck.liveness.failureThreshold`         | Failure threshold                                            | `3`                                                  |
| `resources.limits.cpu`                          | CPU limit                                                    | `2`                                                  |
| `resources.limits.memory`                       | Memory limit                                                 | `1024Mi`                                             |
| `resources.limits.ephemeral-storage`            | Ephemeral storage limit                                      | `512Mi`                                              |
| `resources.requests.cpu`                        | CPU request                                                  | `1`                                                  |
| `resources.requests.memory`                     | Memory request                                               | `512Mi`                                              |
| `resources.requests.ephemeral-storage`          | Ephemeral storage request                                    | `256Mi`                                              |
| `nodeSelector`                                  | Node selector                                                | `{}`                                                 |
| `tolerations`                                   | Tolerations                                                  | `{}`                                                 |
| `affinity`                                      | Affinity                                                     | `{}`                                                 |
| `topologySpreadConstraints`                     | Topology spread constraints                                  | `{}`                                                 |
| `terminationGracePeriodSeconds`                 | Termination grace period in seconds                          | `120`                                                |
| `ingress.enabled`                               | Enable ingress configuration                                 | `false`                                              |
| `ingress.annotations`                           | Ingress annotations                                          | `{}`                                                 |
| `ingress.labels`                                | Ingress labels                                               | `{}`                                                 |
| `ingress.ingressClassName`                      | Ingress class name                                           | `istio`                                              |
| `ingress.tls`                                   | Ingress TLS configuration                                    | `[]`                                                 |
| `ingress.hosts`                                 | Ingress hosts                                                | `[]`                                                 |
| `istio.virtualservice.enabled`                  | Enable virtual service                                       | `false`                                              |
| `istio.virtualservice.annotations`              | Virtual service annotations                                  | `{}`                                                 |
| `istio.virtualservice.gateways`                 | Virtual service gateways                                     | `[]`                                                 |
| `istio.virtualservice.hosts`                    | Virtual service hosts                                        | `[]`                                                 |
| `service.type`                                  | Service type                                                 | `ClusterIP`                                          |
| `service.port`                                  | Service port                                                 | `4318`                                               |
| `service.annotations`                           | Service annotations                                          | `{}`                                                 |
| `serviceAccount.create`                         | Create service account                                       | `true`                                               |
| `serviceAccount.annotations`                    | Service account annotations                                  | `{}`                                                 |
| `serviceAccount.name`                           | Service account name                                         | `tfy-otel-collector`                                 |
| `extraVolumes`                                  | Extra volumes                                                | `[]`                                                 |
| `extraVolumeMounts`                             | Extra volume mounts                                          | `[]`                                                 |
| `rbac.enabled`                                  | Enable rbac                                                  | `true`                                               |
| `autoscaling.enabled`                           | Enable autoscaling                                           | `true`                                               |
| `autoscaling.minReplicas`                       | Minimum number of replicas                                   | `2`                                                  |
| `autoscaling.maxReplicas`                       | Maximum number of replicas                                   | `100`                                                |
| `autoscaling.targetCPUUtilizationPercentage`    | Target CPU utilization percentage                            | `60`                                                 |
| `rollout.enabled`                               | Enable rollout (rolling update)                              | `true`                                               |
| `rollout.maxUnavailable`                        | Maximum number of unavailable replicas during rolling update | `0`                                                  |
| `rollout.maxSurge`                              | Maximum number of surge replicas during rolling update       | `100%`                                               |
