
# Tfy-agent helm chart packaged by TrueFoundry
Tfy-agent is an application that runs on the compute plane Kubernetes cluster to connect to the TrueFoundry control plane.

This application has two parts.
1. TFY Agent
    * This is used to stream the state of the compute plane cluster to the control plane.
2. TFY Agent Proxy
    * This enables the control plane to access the compute plane cluster's Kubernetes API server.

## Compute plane cluster authorization

### TFY Agent
* TFY Agent runs [informers](https://macias.info/entry/202109081800_k8s_informers.md) to stream kubernetes resource updates and send it to the control plane.
* To run informers, the TFY Agent needs to be able to `list` and `watch` [those resource types](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-clusterrole.yaml) across [all the namespaces](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-clusterrolebinding.yaml) in the cluster.
   *  The `config.allowedNamespaces` field allows you to configure a list of allowed namespaces. TFY Agent will filter out any namespaced resource's update if the resource is not part of the allowed namespaces.

### TFY Agent Proxy
* By default, the TFY Agent Proxy enables the control plane to access all resources on the compute cluster.
* If you want to give minimum authorization, please set the field `tfyAgentProxy.clusterRole.strictMode` to `true`.

#### Strict Mode
* In this mode, we set up minimum required authorization rules for the control plane to function correctly.
* If you give a list of allowed namespaces using the `config.allowedNamespaces` field, we will always run on strict mode, regardless of the value of the `tfyAgentProxy.clusterRole.strictMode` field.

##### Cluster Scope resource access
* [This file](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-clusterrole-cs.yaml) documents all the authorization rules we set for the resources for which we require cluster-scope access.
* Note that if you have configured a list of allowed namespaces, the control plane cannot create any new namespace in the cluster.

##### Namespace Scope resource access
* [This file](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-clusterrole-cs.yaml) documents all the authorization rules we set for the resources the control plane can work with namespace-scope access.
* If you give a list of allowed namespaces using the `config.allowedNamespaces` field, we use [setup role binding](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-rolebinding-ns.yaml) for only those namespaces.
* If the list of allowed namespaces is empty. We set up [cluster-wide access](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-clusterrolebinding-ns.yaml) for these namespaced resources.


## Parameters

### Configuration parameters

| Name                                     | Description                                                                                                         | Value                                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `config.clusterToken`                    | Token to connect to the control plane                                                                               | `""`                                                                             |
| `config.clusterTokenSecret`              | Secret of token to connect to control plane, secret key must be `CLUSTER_TOKEN`. This overrides config.clusterToken | `""`                                                                             |
| `config.controlPlaneURL`                 | URL of the control plane to connect agent (format: `https://`)                                                      | `""`                                                                             |
| `config.tenantName`                      | Tenant Name                                                                                                         | `""`                                                                             |
| `config.controlPlaneNatsClusterIP`       | ClusterIP at which nats should connect                                                                              | `ws://truefoundry-nats.truefoundry.svc.cluster.local:443`                        |
| `config.controlPlaneClusterIP`           | ClusterIP of the control plane to connect agent (format: `http://`)                                                 | `http://truefoundry-truefoundry-frontend-app.truefoundry.svc.cluster.local:5000` |
| `config.controlPlaneControllerClusterIP` | ClusterIP of the control plane controller to connect proxy (format: `http://`)                                      | `http://truefoundry-tfy-controller.truefoundry.svc.cluster.local:8123`           |
| `config.opencost.pollInterval`           | Time in milliseconds for opencost scraping                                                                          | `180000`                                                                         |
| `config.opencost.endpoint`               | Endpoint to connect to opencost                                                                                     | `http://opencost.opencost.svc.cluster.local:9003`                                |
| `config.prometheus.pollInterval`         | Time in milliseconds for prometheus scraping config                                                                 | `60000`                                                                          |
| `config.prometheus.endpoint`             | Endpoint to connect to prometheus                                                                                   | `http://prometheus-operated.prometheus.svc.cluster.local:9090`                   |
| `config.alertURL`                        | Truefoundry alert URL                                                                                               | `https://auth.truefoundry.com`                                                   |
| `config.nodeEnv`                         |                                                                                                                     | `production`                                                                     |
| `config.allowedNamespaces`               | A list of namespaces the control plane will have access to for namespaced resources.                                | `[]`                                                                             |
| `imagePullSecrets`                       | Secrets to pull images                                                                                              | `[]`                                                                             |
| `nameOverride`                           | String to override partial name passed in helm install command                                                      | `""`                                                                             |
| `fullnameOverride`                       | String to override full name passed in helm install command                                                         | `""`                                                                             |

### tfyAgent configuration parameters

| Name                                            | Description                                                                                                           | Value                                       |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `tfyAgent.enabled`                              | Bool value to deploy tfyAgent                                                                                         | `true`                                      |
| `tfyAgent.annotations`                          | Add annotations to tfyAgent pods                                                                                      | `{}`                                        |
| `tfyAgent.serviceAccount.create`                | Bool to enable serviceAccount creation                                                                                | `true`                                      |
| `tfyAgent.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                              | `{}`                                        |
| `tfyAgent.serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template     | `""`                                        |
| `tfyAgent.extraEnvVars`                         | Additional envrionment variables for tfyAgent                                                                         | `[]`                                        |
| `tfyAgent.service.annotations`                  | Annotations to add to the tfyAgent service                                                                            | `{}`                                        |
| `tfyAgent.service.labels`                       | Labels to add to the tfyAgent service                                                                                 | `{}`                                        |
| `tfyAgent.service.clusterIP`                    | Cluster IP for tfyAgent service                                                                                       | `""`                                        |
| `tfyAgent.service.port`                         | Port for tfyAgent service                                                                                             | `3000`                                      |
| `tfyAgent.service.nodePort`                     | Port to expose on each node. Only used if service.type is 'NodePort'                                                  | `""`                                        |
| `tfyAgent.service.sessionAffinity`              | SessionAffinity for tfyAgent Service                                                                                  | `""`                                        |
| `tfyAgent.service.type`                         | Type for tfyAgent Service                                                                                             | `ClusterIP`                                 |
| `tfyAgent.image.repository`                     | tfyAgent repository                                                                                                   | `public.ecr.aws/truefoundrycloud/tfy-agent` |
| `tfyAgent.image.pullPolicy`                     | Pull policy for tfyAgent                                                                                              | `IfNotPresent`                              |
| `tfyAgent.image.tag`                            | Overrides the image tag whose default is the chart appVersion.                                                        | `d903e3defe39c6c4b1f372d3a6ca8c7ab4248964`  |
| `tfyAgent.resources.limits.cpu`                 | CPU resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                   | `500m`                                      |
| `tfyAgent.resources.limits.memory`              | Memory Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                | `512Mi`                                     |
| `tfyAgent.resources.limits.ephemeral-storage`   | Ephemeral storage Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it     | `256Mi`                                     |
| `tfyAgent.resources.requests.cpu`               | CPU resource requests for tfyAgent container. Advised to only increase the requests and not decrease it               | `300m`                                      |
| `tfyAgent.resources.requests.memory`            | Memory Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it            | `256Mi`                                     |
| `tfyAgent.resources.requests.ephemeral-storage` | Ephemeral storage Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it | `128Mi`                                     |
| `tfyAgent.livenessProbe.failureThreshold`       | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                         |
| `tfyAgent.livenessProbe.httpGet.path`           | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                         |
| `tfyAgent.livenessProbe.httpGet.port`           | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                      |
| `tfyAgent.livenessProbe.httpGet.scheme`         | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                      |
| `tfyAgent.livenessProbe.periodSeconds`          | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                        |
| `tfyAgent.livenessProbe.successThreshold`       | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                         |
| `tfyAgent.livenessProbe.timeoutSeconds`         | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                         |
| `tfyAgent.livenessProbe.initialDelaySeconds`    | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                        |
| `tfyAgent.readinessProbe.failureThreshold`      | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                         |
| `tfyAgent.readinessProbe.httpGet.path`          | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                         |
| `tfyAgent.readinessProbe.httpGet.port`          | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                      |
| `tfyAgent.readinessProbe.httpGet.scheme`        | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                      |
| `tfyAgent.readinessProbe.periodSeconds`         | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                        |
| `tfyAgent.readinessProbe.successThreshold`      | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                         |
| `tfyAgent.readinessProbe.timeoutSeconds`        | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                         |
| `tfyAgent.readinessProbe.initialDelaySeconds`   | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                        |
| `tfyAgent.securityContext`                      | Security Context for the tfyAgent container                                                                           | `{}`                                        |
| `tfyAgent.tolerations`                          | Taints that pod can tolerate                                                                                          | `[]`                                        |
| `tfyAgent.nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                                  | `{}`                                        |
| `tfyAgent.extraVolumes`                         | Extra volume for tfyAgent container                                                                                   | `[]`                                        |
| `tfyAgent.extraVolumeMounts`                    | Extra volume mount for tfyAgent container                                                                             | `[]`                                        |
| `tfyAgent.affinity`                             | Affinity rules for pod scheduling on a node                                                                           | `{}`                                        |
| `tfyAgent.priorityClassName`                    | PriorityClass name for the pod.                                                                                       | `system-cluster-critical`                   |
| `tfyAgent.clusterRole.enable`                   | Create cluster role.                                                                                                  | `true`                                      |

### tfyAgentProxy configuration parameters

| Name                                                 | Description                                                                                                                | Value                                             |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `tfyAgentProxy.enabled`                              | Bool value to deploy tfyAgentProxy                                                                                         | `true`                                            |
| `tfyAgentProxy.annotations`                          | Add annotations to tfyAgentProxy pods                                                                                      | `{}`                                              |
| `tfyAgentProxy.image.repository`                     | tfyAgentProxy repository                                                                                                   | `public.ecr.aws/truefoundrycloud/tfy-agent-proxy` |
| `tfyAgentProxy.image.pullPolicy`                     | Pull policy for tfyAgentProxy                                                                                              | `IfNotPresent`                                    |
| `tfyAgentProxy.image.tag`                            | Image tag whose default is the chart appVersion.                                                                           | `733190d338b1d7dfbe9c68066891b540104e51c2`        |
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
| `tfyAgentProxy.serviceAccount.create`                | Bool to enable serviceAccount creation                                                                                     | `true`                                            |
| `tfyAgentProxy.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                                   | `{}`                                              |
| `tfyAgentProxy.serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template          | `""`                                              |
| `tfyAgentProxy.clusterRole.enable`                   | Create cluster role.                                                                                                       | `true`                                            |
| `tfyAgentProxy.clusterRole.strictMode`               | Only add required authz rules.                                                                                             | `false`                                           |

### resourceQuota Add a ResourceQuota to enable priority class in a namspace.

| Name                            | Description                | Value                         |
| ------------------------------- | -------------------------- | ----------------------------- |
| `resourceQuota.enabled`         | Create the ResourceQuota.  | `true`                        |
| `resourceQuota.priorityClasses` | PriorityClasses to enable. | `["system-cluster-critical"]` |
