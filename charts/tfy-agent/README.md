# Tfy-agent helm chart packaged by TrueFoundry
Tfy-agent is an applications that gets deployed on the kubernetes cluster to connect to the TrueFoundry Control plane

## Parameters

### Global parameters

| Name                  | Description          | Value  |
| --------------------- | -------------------- | ------ |
| `global.rbac.enabled` | Enable RBAC globally | `true` |

### Configuration parameters

| Name                             | Description                                                                                                         | Value                                                          |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `config.clusterToken`            | Token to connect to the control plane                                                                               | `""`                                                           |
| `config.clusterTokenSecret`      | Secret of token to connect to control plane, secret key must be `CLUSTER_TOKEN`. This overrides config.clusterToken | `""`                                                           |
| `config.controlPlaneURL`         | URL of the control plane to connect agent (format: `https://`)                                                      | `""`                                                           |
| `config.tenantName`              | Tenant Name                                                                                                         | `""`                                                           |
| `config.natsPort`                | Port at which nats should connect                                                                                   | `443`                                                          |
| `config.opencost.pollInterval`   | Time in milliseconds for opencost scraping                                                                          | `180000`                                                       |
| `config.opencost.endpoint`       | Endpoint to connect to opencost                                                                                     | `http://opencost.opencost.svc.cluster.local:9003`              |
| `config.prometheus.pollInterval` | Time in milliseconds for prometheus scraping config                                                                 | `60000`                                                        |
| `config.prometheus.endpoint`     | Endpoint to connect to prometheus                                                                                   | `http://prometheus-operated.prometheus.svc.cluster.local:9090` |
| `config.alertURL`                | Truefoundry alert URL                                                                                               | `https://auth.truefoundry.com`                                 |
| `config.nodeEnv`                 |                                                                                                                     | `production`                                                   |
| `imagePullSecrets`               | Secrets to pull images                                                                                              | `[]`                                                           |
| `nameOverride`                   | String to override partial name passed in helm install command                                                      | `""`                                                           |
| `fullnameOverride`               | String to override full name passed in helm install command                                                         | `""`                                                           |

### tfyAgent configuration parameters

| Name                                                   | Description                                                                                                           | Value                                       |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `tfyAgent.enabled`                                     | Bool value to deploy tfyAgent                                                                                         | `true`                                      |
| `tfyAgent.annotations`                                 | Add annotations to tfyAgent pods                                                                                      | `{}`                                        |
| `tfyAgent.serviceAccount.create`                       | Bool to enable serviceAccount creation                                                                                | `true`                                      |
| `tfyAgent.serviceAccount.annotations`                  | Annotations to add to the serviceAccount                                                                              | `{}`                                        |
| `tfyAgent.serviceAccount.name`                         | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template     | `""`                                        |
| `tfyAgent.serviceAccount.automountServiceAccountToken` | Enable automounting of service account token inside the pod                                                           | `true`                                      |
| `tfyAgent.extraEnvVars`                                | Additional envrionment variables for tfyAgent                                                                         | `[]`                                        |
| `tfyAgent.service.annotations`                         | Annotations to add to the tfyAgent service                                                                            | `{}`                                        |
| `tfyAgent.service.labels`                              | Labels to add to the tfyAgent service                                                                                 | `{}`                                        |
| `tfyAgent.service.clusterIP`                           | Cluster IP for tfyAgent service                                                                                       | `""`                                        |
| `tfyAgent.service.port`                                | Port for tfyAgent service                                                                                             | `3000`                                      |
| `tfyAgent.service.nodePort`                            | Port to expose on each node. Only used if service.type is 'NodePort'                                                  | `""`                                        |
| `tfyAgent.service.sessionAffinity`                     | SessionAffinity for tfyAgent Service                                                                                  | `""`                                        |
| `tfyAgent.service.type`                                | Type for tfyAgent Service                                                                                             | `ClusterIP`                                 |
| `tfyAgent.image.repository`                            | tfyAgent repository                                                                                                   | `public.ecr.aws/truefoundrycloud/tfy-agent` |
| `tfyAgent.image.pullPolicy`                            | Pull policy for tfyAgent                                                                                              | `IfNotPresent`                              |
| `tfyAgent.image.tag`                                   | Overrides the image tag whose default is the chart appVersion.                                                        | `7e5fb3b7fbaabfb6be5b7faa256a47e7a2e5654f`  |
| `tfyAgent.resources.limits.cpu`                        | CPU resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                   | `500m`                                      |
| `tfyAgent.resources.limits.memory`                     | Memory Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                | `512Mi`                                     |
| `tfyAgent.resources.limits.ephemeral-storage`          | Ephemeral storage Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it     | `256Mi`                                     |
| `tfyAgent.resources.requests.cpu`                      | CPU resource requests for tfyAgent container. Advised to only increase the requests and not decrease it               | `300m`                                      |
| `tfyAgent.resources.requests.memory`                   | Memory Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it            | `256Mi`                                     |
| `tfyAgent.resources.requests.ephemeral-storage`        | Ephemeral storage Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it | `128Mi`                                     |
| `tfyAgent.livenessProbe.failureThreshold`              | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                         |
| `tfyAgent.livenessProbe.httpGet.path`                  | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                         |
| `tfyAgent.livenessProbe.httpGet.port`                  | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                      |
| `tfyAgent.livenessProbe.httpGet.scheme`                | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                      |
| `tfyAgent.livenessProbe.periodSeconds`                 | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                        |
| `tfyAgent.livenessProbe.successThreshold`              | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                         |
| `tfyAgent.livenessProbe.timeoutSeconds`                | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                         |
| `tfyAgent.livenessProbe.initialDelaySeconds`           | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                        |
| `tfyAgent.readinessProbe.failureThreshold`             | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                         |
| `tfyAgent.readinessProbe.httpGet.path`                 | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                         |
| `tfyAgent.readinessProbe.httpGet.port`                 | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                      |
| `tfyAgent.readinessProbe.httpGet.scheme`               | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                      |
| `tfyAgent.readinessProbe.periodSeconds`                | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                        |
| `tfyAgent.readinessProbe.successThreshold`             | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                         |
| `tfyAgent.readinessProbe.timeoutSeconds`               | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                         |
| `tfyAgent.readinessProbe.initialDelaySeconds`          | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                        |
| `tfyAgent.securityContext`                             | Security Context for the tfyAgent container                                                                           | `{}`                                        |
| `tfyAgent.tolerations`                                 | Taints that pod can tolerate                                                                                          | `[]`                                        |
| `tfyAgent.nodeSelector`                                | Parameters to select for scheduling of pod on a node                                                                  | `{}`                                        |
| `tfyAgent.extraVolumes`                                | Extra volume for tfyAgent container                                                                                   | `[]`                                        |
| `tfyAgent.extraVolumeMounts`                           | Extra volume mount for tfyAgent container                                                                             | `[]`                                        |
| `tfyAgent.affinity`                                    | Affinity rules for pod scheduling on a node                                                                           | `{}`                                        |
| `tfyAgent.priorityClassName`                           | PriorityClass name for the pod.                                                                                       | `system-cluster-critical`                   |

### tfyAgentProxy configuration parameters

| Name                                                 | Description                                                                                                                | Value                                             |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `tfyAgentProxy.enabled`                              | Bool value to deploy tfyAgentProxy                                                                                         | `true`                                            |
| `tfyAgentProxy.annotations`                          | Add annotations to tfyAgentProxy pods                                                                                      | `{}`                                              |
| `tfyAgentProxy.image.repository`                     | tfyAgentProxy repository                                                                                                   | `public.ecr.aws/truefoundrycloud/tfy-agent-proxy` |
| `tfyAgentProxy.image.pullPolicy`                     | Pull policy for tfyAgentProxy                                                                                              | `IfNotPresent`                                    |
| `tfyAgentProxy.image.tag`                            | Image tag whose default is the chart appVersion.                                                                           | `0fab3616bf162ecf86e23bb6bf67dfd85b718144`        |
| `tfyAgentProxy.extraEnvVars`                         | Additional envrionment variables for tfyAgentPRoxy                                                                         | `[]`                                              |
| `tfyAgentProxy.resources.limits.cpu`                 | CPU resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it                   | `500m`                                            |
| `tfyAgentProxy.resources.limits.memory`              | Memory Resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it                | `512Mi`                                           |
| `tfyAgentProxy.resources.limits.ephemeral-storage`   | Ephemeral storage Resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it     | `500M`                                            |
| `tfyAgentProxy.resources.requests.cpu`               | CPU resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it               | `50m`                                             |
| `tfyAgentProxy.resources.requests.memory`            | Memory Resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it            | `128Mi`                                           |
| `tfyAgentProxy.resources.requests.ephemeral-storage` | Ephemeral storage Resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it | `200M`                                            |
| `tfyAgentProxy.securityContext`                      | Security Context for the tfyAgentProxy container                                                                           | `{}`                                              |
| `tfyAgentProxy.tolerations`                          | Taints that pod can tolerate                                                                                               | `[]`                                              |
| `tfyAgentProxy.nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                                       | `{}`                                              |
| `tfyAgentProxy.affinity`                             | Affinity rules for pod scheduling on a node                                                                                | `{}`                                              |
| `tfyAgentProxy.priorityClassName`                    | PriorityClass name for the pod.                                                                                            | `system-cluster-critical`                         |

### resourceQuota Add a ResourceQuota to enable priority class in a namspace.

| Name                            | Description                | Value                         |
| ------------------------------- | -------------------------- | ----------------------------- |
| `resourceQuota.enabled`         | Create the ResourceQuota.  | `true`                        |
| `resourceQuota.priorityClasses` | PriorityClasses to enable. | `["system-cluster-critical"]` |
