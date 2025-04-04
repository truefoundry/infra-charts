# Tfy-Otel_collector helm chart by Truefoundry

Tfy-Otel_collector Helm Chart 

## Parameters

### Configuration values for tfy-otel-collector

| Name                                        | Description                                                  | Value                                                |
| ------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| `env`                                       | Environment variables for the tfyOtelCollector               | `{}`                                                 |
| `image.repository`                          | Image repository for tfyOTELCollector                        | `tfy.jfrog.io/tfy-private-images/tfy-otel-collector` |
| `image.tag`                                 | Image tag for the tfyOTELCollector                           | `416fc71c5d729be2613a9b197e203cd5fdc1d8d4`           |
| `imagePullSecrets`                          | List of secrets to pull images                               | `[]`                                                 |
| `fullnameOverride`                          | Full name override for the tfy-otel-collector                | `""`                                                 |
| `replicaCount`                              | Number of replicas                                           | `2`                                                  |
| `environmentName`                           | The environment name                                         | `default`                                            |
| `envSecretName`                             | The environment secret name                                  | `""`                                                 |
| `imagePullPolicy`                           | Image pull policy                                            | `IfNotPresent`                                       |
| `nameOverride`                              | Name override                                                | `""`                                                 |
| `podAnnotations`                            | Pod annotations                                              | `{}`                                                 |
| `commonAnnotations`                         | Common annotations                                           | `{}`                                                 |
| `podSecurityContext`                        | Pod security context                                         | `{}`                                                 |
| `commonLabels`                              | Common labels                                                | `{}`                                                 |
| `securityContext`                           | Security context configuration                               | `{}`                                                 |
| `healthcheck.enabled`                       | Enable healthcheck                                           | `true`                                               |
| `healthcheck.readiness.port`                | Port to probe                                                | `3000`                                               |
| `healthcheck.readiness.path`                | Path to probe                                                | `/`                                                  |
| `healthcheck.readiness.initialDelaySeconds` | Initial delay in seconds                                     | `10`                                                 |
| `healthcheck.readiness.periodSeconds`       | Period in seconds                                            | `10`                                                 |
| `healthcheck.readiness.timeoutSeconds`      | Timeout in seconds                                           | `5`                                                  |
| `healthcheck.readiness.successThreshold`    | Success threshold                                            | `1`                                                  |
| `healthcheck.readiness.failureThreshold`    | Failure threshold                                            | `3`                                                  |
| `healthcheck.liveness.port`                 | Port to probe                                                | `3000`                                               |
| `healthcheck.liveness.path`                 | Path to probe                                                | `/`                                                  |
| `resources.limits.cpu`                      | CPU limit                                                    | `1`                                                  |
| `resources.limits.memory`                   | Memory limit                                                 | `512Mi`                                              |
| `resources.limits.ephemeral-storage`        | Ephemeral storage limit                                      | `512Mi`                                              |
| `resources.requests.cpu`                    | CPU request                                                  | `0.5`                                                |
| `resources.requests.memory`                 | Memory request                                               | `256Mi`                                              |
| `resources.requests.ephemeral-storage`      | Ephemeral storage request                                    | `256Mi`                                              |
| `nodeSelector`                              | Node selector                                                | `{}`                                                 |
| `tolerations`                               | Tolerations                                                  | `{}`                                                 |
| `affinity`                                  | Affinity                                                     | `{}`                                                 |
| `topologySpreadConstraints`                 | Topology spread constraints                                  | `{}`                                                 |
| `terminationGracePeriodSeconds`             | Termination grace period in seconds                          | `120`                                                |
| `service.type`                              | Service type                                                 | `ClusterIP`                                          |
| `service.port`                              | Service port                                                 | `4318`                                               |
| `service.annotations`                       | Service annotations                                          | `{}`                                                 |
| `serviceAccount.create`                     | Create service account                                       | `true`                                               |
| `serviceAccount.annotations`                | Service account annotations                                  | `{}`                                                 |
| `serviceAccount.name`                       | Service account name                                         | `""`                                                 |
| `extraVolumes`                              | Extra volumes                                                | `[]`                                                 |
| `extraVolumeMounts`                         | Extra volume mounts                                          | `[]`                                                 |
| `rollout.enabled`                           | Enable rollout (rolling update)                              | `true`                                               |
| `rollout.maxUnavailable`                    | Maximum number of unavailable replicas during rolling update | `1`                                                  |
| `rollout.maxSurge`                          | Maximum number of surge replicas during rolling update       | `50%`                                                |
