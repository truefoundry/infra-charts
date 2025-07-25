# Tfy-Otel_collector helm chart by Truefoundry

Tfy-Otel_collector Helm Chart 

## Parameters

### Configuration values for tfy-otel-collector

| Name                                          | Description                                                  | Value                                                |
| --------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| `global.resourceTier`                         | Resource deployment type                                     | `""`                                                 |
| `global.affinity`                             | Affinity rules for pod scheduling on a node                  | `{}`                                                 |
| `global.tolerations`                          | Tolerations for pod scheduling on a node                     | `[]`                                                 |
| `global.nodeSelector`                         | Node selector                                                | `{}`                                                 |
| `env`                                         | Environment variables for the tfyOtelCollector               | `{}`                                                 |
| `image.repository`                            | Image repository for tfyOTELCollector                        | `tfy.jfrog.io/tfy-private-images/tfy-otel-collector` |
| `image.tag`                                   | Image tag for the tfyOTELCollector                           | `539d55d1d269d97be031d48b75257a20515d6de9`           |
| `imagePullSecrets`                            | List of secrets to pull images                               | `[]`                                                 |
| `fullnameOverride`                            | Full name override for the tfy-otel-collector                | `""`                                                 |
| `environmentName`                             | The environment name                                         | `default`                                            |
| `envSecretName`                               | The environment secret name                                  | `""`                                                 |
| `imagePullPolicy`                             | Image pull policy                                            | `IfNotPresent`                                       |
| `nameOverride`                                | Name override                                                | `""`                                                 |
| `podAnnotations`                              | Pod annotations                                              | `{}`                                                 |
| `commonAnnotations`                           | Common annotations                                           | `{}`                                                 |
| `podSecurityContext`                          | Pod security context                                         | `{}`                                                 |
| `commonLabels`                                | Common labels                                                | `{}`                                                 |
| `securityContext`                             | Security context configuration                               | `{}`                                                 |
| `healthcheck.enabled`                         | Enable healthcheck                                           | `true`                                               |
| `healthcheck.readiness.port`                  | Port to probe                                                | `3000`                                               |
| `healthcheck.readiness.path`                  | Path to probe                                                | `/health/status`                                     |
| `healthcheck.readiness.initialDelaySeconds`   | Initial delay in seconds                                     | `30`                                                 |
| `healthcheck.readiness.periodSeconds`         | Period in seconds                                            | `10`                                                 |
| `healthcheck.readiness.timeoutSeconds`        | Timeout in seconds                                           | `1`                                                  |
| `healthcheck.readiness.successThreshold`      | Success threshold                                            | `1`                                                  |
| `healthcheck.readiness.failureThreshold`      | Failure threshold                                            | `3`                                                  |
| `healthcheck.liveness.port`                   | Port to probe                                                | `3000`                                               |
| `healthcheck.liveness.path`                   | Path to probe                                                | `/health/status`                                     |
| `healthcheck.liveness.initialDelaySeconds`    | Initial delay in seconds                                     | `600`                                                |
| `healthcheck.liveness.periodSeconds`          | Period in seconds                                            | `10`                                                 |
| `healthcheck.liveness.timeoutSeconds`         | Timeout in seconds                                           | `1`                                                  |
| `healthcheck.liveness.successThreshold`       | Success threshold                                            | `1`                                                  |
| `healthcheck.liveness.failureThreshold`       | Failure threshold                                            | `3`                                                  |
| `nodeSelector`                                | Node selector                                                | `{}`                                                 |
| `tolerations`                                 | Tolerations                                                  | `{}`                                                 |
| `affinity`                                    | Affinity                                                     | `{}`                                                 |
| `topologySpreadConstraints`                   | Topology spread constraints                                  | `{}`                                                 |
| `terminationGracePeriodSeconds`               | Termination grace period in seconds                          | `120`                                                |
| `service.type`                                | Service type                                                 | `ClusterIP`                                          |
| `service.port`                                | Service port                                                 | `4318`                                               |
| `service.annotations`                         | Service annotations                                          | `{}`                                                 |
| `serviceAccount.create`                       | Create service account                                       | `true`                                               |
| `serviceAccount.annotations`                  | Service account annotations                                  | `{}`                                                 |
| `serviceAccount.name`                         | Service account name                                         | `""`                                                 |
| `serviceAccount.automountServiceAccountToken` | Automount service account token                              | `true`                                               |
| `extraVolumes`                                | Extra volumes                                                | `[]`                                                 |
| `extraVolumeMounts`                           | Extra volume mounts                                          | `[]`                                                 |
| `rollout.enabled`                             | Enable rollout (rolling update)                              | `true`                                               |
| `rollout.maxUnavailable`                      | Maximum number of unavailable replicas during rolling update | `1`                                                  |
| `rollout.maxSurge`                            | Maximum number of surge replicas during rolling update       | `50%`                                                |
| `serviceMonitor.enabled`                      | Enable service monitor                                       | `true`                                               |
| `serviceMonitor.additionalLabels`             | Additional labels for the service monitor                    | `{}`                                                 |
| `serviceMonitor.additionalAnnotations`        | Additional annotations for the service monitor               | `{}`                                                 |
