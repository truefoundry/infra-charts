# tfy-sandbox-server

Helm chart for deploying **tfy-sandbox-server**, a lightweight HTTP sandbox that executes shell commands for TrueFoundry AI agents.

## Installation

```bash
helm install tfy-sandbox-server charts/tfy-sandbox-server
```

## Integration with TrueFoundry LLM Gateway

Deploy this chart on the same cluster as the TrueFoundry LLM Gateway. Point the gateway to the sandbox server by setting the `SANDBOX_SERVER_URL` environment variable on the gateway to the internal service URL:

```
http://<release-name>-tfy-sandbox-server:8080
```

## Parameters

### Configuration values for tfy-sandbox-server

| Name                                   | Description                                                  | Value                                        |
| -------------------------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| `nameOverride`                         | Name override                                                | `""`                                         |
| `fullnameOverride`                     | Full name override                                           | `""`                                         |
| `commonLabels`                         | Common labels added to all resources                         | `{}`                                         |
| `commonAnnotations`                    | Common annotations added to all resources                    | `{}`                                         |
| `image.repository`                     | Image repository                                             | `tfy.jfrog.io/tfy-public/tfy-sandbox-server` |
| `image.tag`                            | Image tag                                                    | `0.1.0`                                      |
| `image.pullPolicy`                     | Image pull policy                                            | `IfNotPresent`                               |
| `imagePullSecrets`                     | Image pull secrets                                           | `[]`                                         |
| `sandbox.rootDir`                      | Root directory for sandbox workspaces                        | `/data/sandboxes`                            |
| `persistence.enabled`                  | Enable persistent storage for sandbox data                   | `true`                                       |
| `persistence.size`                     | Volume size                                                  | `50Gi`                                       |
| `persistence.storageClassName`         | Storage class name (empty string uses cluster default)       | `""`                                         |
| `persistence.accessModes`              | Volume access modes                                          | `[]`                                         |
| `persistence.mountPath`                | Mount path for the volume                                    | `/data/sandboxes`                            |
| `replicaCount`                         | Number of replicas (1 recommended — EBS is RWO)              | `1`                                          |
| `strategy`                             | Deployment strategy (Recreate recommended for RWO volumes)   | `{}`                                         |
| `extraEnv`                             | Extra environment variables for the sandbox server container | `[]`                                         |
| `pdb.enabled`                          | Create a PodDisruptionBudget                                 | `false`                                      |
| `pdb.minAvailable`                     | Minimum available replicas                                   | `1`                                          |
| `pdb.labels`                           | PDB labels                                                   | `{}`                                         |
| `pdb.annotations`                      | PDB annotations                                              | `{}`                                         |
| `serviceAccount.create`                | Create a dedicated service account                           | `false`                                      |
| `serviceAccount.name`                  | Service account name                                         | `""`                                         |
| `serviceAccount.labels`                | Service account labels                                       | `{}`                                         |
| `serviceAccount.annotations`           | Service account annotations                                  | `{}`                                         |
| `service.type`                         | Service type                                                 | `ClusterIP`                                  |
| `service.port`                         | Service port                                                 | `8080`                                       |
| `service.labels`                       | Service labels                                               | `{}`                                         |
| `service.annotations`                  | Service annotations                                          | `{}`                                         |
| `probes.startup.enabled`               | Enable the startup probe                                     | `true`                                       |
| `probes.startup.path`                  | Startup probe HTTP path                                      | `/health`                                    |
| `probes.startup.initialDelaySeconds`   | Startup probe initial delay in seconds                       | `0`                                          |
| `probes.startup.periodSeconds`         | Startup probe period in seconds                              | `10`                                         |
| `probes.startup.timeoutSeconds`        | Startup probe timeout in seconds                             | `1`                                          |
| `probes.startup.failureThreshold`      | Startup probe failure threshold                              | `3`                                          |
| `probes.liveness.enabled`              | Enable the liveness probe                                    | `true`                                       |
| `probes.liveness.path`                 | Liveness probe HTTP path                                     | `/health`                                    |
| `probes.liveness.initialDelaySeconds`  | Liveness probe initial delay in seconds                      | `0`                                          |
| `probes.liveness.periodSeconds`        | Liveness probe period in seconds                             | `10`                                         |
| `probes.liveness.timeoutSeconds`       | Liveness probe timeout in seconds                            | `1`                                          |
| `probes.liveness.failureThreshold`     | Liveness probe failure threshold                             | `3`                                          |
| `probes.readiness.enabled`             | Enable the readiness probe                                   | `true`                                       |
| `probes.readiness.path`                | Readiness probe HTTP path                                    | `/health`                                    |
| `probes.readiness.initialDelaySeconds` | Readiness probe initial delay in seconds                     | `0`                                          |
| `probes.readiness.periodSeconds`       | Readiness probe period in seconds                            | `10`                                         |
| `probes.readiness.timeoutSeconds`      | Readiness probe timeout in seconds                           | `1`                                          |
| `probes.readiness.failureThreshold`    | Readiness probe failure threshold                            | `3`                                          |
| `podSecurityContext`                   | Pod security context                                         | `{}`                                         |
| `securityContext`                      | Container security context                                   | `{}`                                         |
| `nodeSelector`                         | Node selector                                                | `{}`                                         |
| `tolerations`                          | Tolerations                                                  | `[]`                                         |
| `affinity`                             | Affinity                                                     | `{}`                                         |
| `topologySpreadConstraints`            | Topology spread constraints                                  | `[]`                                         |
| `priorityClassName`                    | PriorityClass name                                           | `""`                                         |
| `terminationGracePeriodSeconds`        | Termination grace period                                     | `30`                                         |
| `podLabels`                            | Pod labels                                                   | `{}`                                         |
| `podAnnotations`                       | Pod annotations                                              | `{}`                                         |
| `deploymentLabels`                     | Deployment labels                                            | `{}`                                         |
| `deploymentAnnotations`                | Deployment annotations                                       | `{}`                                         |
| `extraVolumes`                         | Extra volumes                                                | `[]`                                         |
| `extraVolumeMounts`                    | Extra volume mounts                                          | `[]`                                         |
| `extraManifests`                       | Extra manifests                                              | `[]`                                         |
