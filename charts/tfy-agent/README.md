
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
* [This file](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-clusterrole-ns.yaml) documents all the authorization rules we set for the resources the control plane can work with namespace-scope access.
* If you give a list of allowed namespaces using the `config.allowedNamespaces` field, we use [setup role binding](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-rolebinding-ns.yaml) for only those namespaces.
* If the list of allowed namespaces is empty. We set up [cluster-wide access](https://github.com/truefoundry/infra-charts/blob/main/charts/tfy-agent/templates/tfy-agent-proxy-clusterrolebinding-ns.yaml) for these namespaced resources.


## Troubleshoot

### Using self-signed certificate in control plane URL
If your control plane URL is using self-signed CA certificate, follow these steps:
1. Update CA bundle in the container by mounting your CA bundle. This can be done in two ways:
    1. using volume mounts
        - create a config map using your `ca-certificate.crt` file
            
            `kubectl create configmap tfy-ca-cert -n tfy-agent --from-file=ca-certificate.crt`

        - add following volume and volume mounts in both tfyAgent and tfyAgentProxy
            ```
            tfyAgent:
                extraVolumes:
                - name: ca-certificates-volume
                  configMap:
                    name: tfy-ca-cert 
                    items:
                    - key: ca-certificates.crt
                      path: ca-certificates.crt
                extraVolumeMounts:
                    - name: ca-certificates-volume
                      mountPath: /etc/ssl/certs/ca-certificates.crt
                      subPath: ca-certificates.crt
                      readOnly: true
            tfyAgentProxy:
                extraVolumes:
                - name: ca-certificates-volume
                  configMap:
                    name: tfy-ca-cert 
                    items:
                    - key: ca-certificates.crt
                      path: ca-certificates.crt
                extraVolumeMounts:
                    - name: ca-certificates-volume
                      mountPath: /etc/ssl/certs/ca-certificates.crt
                      subPath: ca-certificates.crt
                      readOnly: true
            ```
    2. using jspolicy - [link](https://artifacthub.io/packages/helm/truefoundry/tfy-jspolicy-config)

2. Add extraEnv in tfyAgent to allow insecure connection
    ```
    tfyAgent:
        extraEnvVars:
            - name: NODE_TLS_REJECT_UNAUTHORIZED
              value: '0'
    ```


## Parameters

### Configuration parameters

| Name                                     | Description                                                                                                         | Value                                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `config.clusterToken`                    | Token to connect to the control plane                                                                               | `""`                                                                             |
| `config.clusterTokenSecret`              | Secret of token to connect to control plane, secret key must be `CLUSTER_TOKEN`. This overrides config.clusterToken | `""`                                                                             |
| `config.controlPlaneURL`                 | URL of the control plane to connect agent (format: `https://`)                                                      | `""`                                                                             |
| `config.tenantName`                      | Tenant Name                                                                                                         | `""`                                                                             |
| `config.controlPlaneNatsClusterIP`       | ClusterIP at which nats should connect                                                                              | `ws://truefoundry-tfy-nats.truefoundry.svc.cluster.local:8080`                   |
| `config.controlPlaneClusterIP`           | ClusterIP of the control plane to connect agent (format: `http://`)                                                 | `http://truefoundry-truefoundry-frontend-app.truefoundry.svc.cluster.local:5000` |
| `config.controlPlaneControllerClusterIP` | ClusterIP of the control plane controller to connect proxy (format: `http://`)                                      | `http://truefoundry-tfy-controller.truefoundry.svc.cluster.local:8123`           |
| `config.opencost.pollInterval`           | Time in milliseconds for opencost scraping                                                                          | `180000`                                                                         |
| `config.opencost.endpoint`               | Endpoint to connect to opencost                                                                                     | `http://opencost.opencost.svc.cluster.local:9003`                                |
| `config.prometheus.pollInterval`         | Time in milliseconds for prometheus scraping config                                                                 | `60000`                                                                          |
| `config.prometheus.endpoint`             | Endpoint to connect to prometheus                                                                                   | `http://prometheus-operated.prometheus.svc.cluster.local:9090`                   |
| `config.alertURL`                        | Truefoundry alert URL                                                                                               | `https://auth.truefoundry.com`                                                   |
| `config.nodeEnv`                         |                                                                                                                     | `production`                                                                     |
| `config.nodeOptions`                     | Node options for tfyAgent                                                                                           | `""`                                                                             |
| `config.allowedNamespaces`               | A list of namespaces the control plane will have access to for namespaced resources.                                | `[]`                                                                             |
| `nameOverride`                           | String to override partial name passed in helm install command                                                      | `""`                                                                             |
| `fullnameOverride`                       | String to override full name passed in helm install command                                                         | `""`                                                                             |

### tfyAgent configuration parameters

| Name                                            | Description                                                                                                           | Value                                      |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `tfyAgent.enabled`                              | Bool value to deploy tfyAgent                                                                                         | `true`                                     |
| `tfyAgent.annotations`                          | Add annotations to tfyAgent pods                                                                                      | `{}`                                       |
| `tfyAgent.labels`                               | Add labels to tfyAgent pods                                                                                           | `{}`                                       |
| `tfyAgent.extraEnvVars`                         | Additional envrionment variables for tfyAgent                                                                         | `[]`                                       |
| `tfyAgent.imagePullSecrets`                     | Secrets to pull images for tfyAgent                                                                                   | `[]`                                       |
| `tfyAgent.service.clusterIP`                    | Cluster IP for tfyAgent service                                                                                       | `""`                                       |
| `tfyAgent.service.port`                         | Port for tfyAgent service                                                                                             | `3000`                                     |
| `tfyAgent.service.nodePort`                     | Port to expose on each node. Only used if service.type is 'NodePort'                                                  | `""`                                       |
| `tfyAgent.service.sessionAffinity`              | SessionAffinity for tfyAgent Service                                                                                  | `""`                                       |
| `tfyAgent.service.type`                         | Type for tfyAgent Service                                                                                             | `ClusterIP`                                |
| `tfyAgent.image.repository`                     | tfyAgent repository                                                                                                   | `tfy.jfrog.io/tfy-images/tfy-agent`        |
| `tfyAgent.image.pullPolicy`                     | Pull policy for tfyAgent                                                                                              | `IfNotPresent`                             |
| `tfyAgent.image.tag`                            | Overrides the image tag whose default is the chart appVersion.                                                        | `b86deb1148bf0debddb19fffca84d1bd0565c12c` |
| `tfyAgent.resources.limits.cpu`                 | CPU resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                   | `1.6`                                      |
| `tfyAgent.resources.limits.memory`              | Memory Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it                | `3800Mi`                                   |
| `tfyAgent.resources.limits.ephemeral-storage`   | Ephemeral storage Resource limits for tfyAgent container. Advised to only increase the limits and not decrease it     | `256Mi`                                    |
| `tfyAgent.resources.requests.cpu`               | CPU resource requests for tfyAgent container. Advised to only increase the requests and not decrease it               | `800m`                                     |
| `tfyAgent.resources.requests.memory`            | Memory Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it            | `1900Mi`                                   |
| `tfyAgent.resources.requests.ephemeral-storage` | Ephemeral storage Resource requests for tfyAgent container. Advised to only increase the requests and not decrease it | `128Mi`                                    |
| `tfyAgent.livenessProbe.failureThreshold`       | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                        |
| `tfyAgent.livenessProbe.httpGet.path`           | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                        |
| `tfyAgent.livenessProbe.httpGet.port`           | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                     |
| `tfyAgent.livenessProbe.httpGet.scheme`         | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                     |
| `tfyAgent.livenessProbe.periodSeconds`          | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                       |
| `tfyAgent.livenessProbe.successThreshold`       | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                        |
| `tfyAgent.livenessProbe.timeoutSeconds`         | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                        |
| `tfyAgent.livenessProbe.initialDelaySeconds`    | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                       |
| `tfyAgent.readinessProbe.failureThreshold`      | Failure threshhold value for liveness probe of tfyAgent container                                                     | `5`                                        |
| `tfyAgent.readinessProbe.httpGet.path`          | Path for http request for liveness probe of tfyAgent container                                                        | `/`                                        |
| `tfyAgent.readinessProbe.httpGet.port`          | Port for http request for liveness probe of tfyAgent container                                                        | `3000`                                     |
| `tfyAgent.readinessProbe.httpGet.scheme`        | Scheme for http request for liveness probe of tfyAgent container                                                      | `HTTP`                                     |
| `tfyAgent.readinessProbe.periodSeconds`         | Seconds for liveness probe of tfyAgent container                                                                      | `10`                                       |
| `tfyAgent.readinessProbe.successThreshold`      | Success threshold for liveness probe of tfyAgent container                                                            | `1`                                        |
| `tfyAgent.readinessProbe.timeoutSeconds`        | Timeout seconds value for liveness probe of tfyAgent container                                                        | `1`                                        |
| `tfyAgent.readinessProbe.initialDelaySeconds`   | Initial delay seconds value for liveness probe of tfyAgent container                                                  | `15`                                       |
| `tfyAgent.securityContext`                      | Security Context for the tfyAgent container                                                                           | `{}`                                       |
| `tfyAgent.tolerations`                          | Taints that pod can tolerate                                                                                          | `[]`                                       |
| `tfyAgent.nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                                  | `{}`                                       |
| `tfyAgent.extraVolumes`                         | Extra volume for tfyAgent container                                                                                   | `[]`                                       |
| `tfyAgent.extraVolumeMounts`                    | Extra volume mount for tfyAgent container                                                                             | `[]`                                       |
| `tfyAgent.affinity`                             | Affinity rules for pod scheduling on a node                                                                           | `{}`                                       |
| `tfyAgent.priorityClassName`                    | PriorityClass name for the pod.                                                                                       | `system-cluster-critical`                  |
| `tfyAgent.clusterRole.enable`                   | Create cluster role.                                                                                                  | `true`                                     |
| `tfyAgent.serviceAccount.create`                | Bool to enable serviceAccount creation                                                                                | `true`                                     |
| `tfyAgent.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                              | `{}`                                       |
| `tfyAgent.serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template     | `""`                                       |

### tfyAgentProxy configuration parameters

| Name                                                                | Description                                                                                                                | Value                                      |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `tfyAgentProxy.enabled`                                             | Bool value to deploy tfyAgentProxy                                                                                         | `true`                                     |
| `tfyAgentProxy.annotations`                                         | Add annotations to tfyAgentProxy pods                                                                                      | `{}`                                       |
| `tfyAgentProxy.labels`                                              | Add labels to tfyAgentProxy pods                                                                                           | `{}`                                       |
| `tfyAgentProxy.imagePullSecrets`                                    | Secrets to pull images for tfyAgentProxy                                                                                   | `[]`                                       |
| `tfyAgentProxy.image.repository`                                    | tfyAgentProxy repository                                                                                                   | `tfy.jfrog.io/tfy-images/tfy-agent-proxy`  |
| `tfyAgentProxy.image.pullPolicy`                                    | Pull policy for tfyAgentProxy                                                                                              | `IfNotPresent`                             |
| `tfyAgentProxy.image.tag`                                           | Image tag whose default is the chart appVersion.                                                                           | `681853ce38466345ae00b5051f98d7781fdc2edf` |
| `tfyAgentProxy.extraEnvVars`                                        | Additional envrionment variables for tfyAgentPRoxy                                                                         | `[]`                                       |
| `tfyAgentProxy.resources.limits.cpu`                                | CPU resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it                   | `200m`                                     |
| `tfyAgentProxy.resources.limits.memory`                             | Memory Resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it                | `360Mi`                                    |
| `tfyAgentProxy.resources.limits.ephemeral-storage`                  | Ephemeral storage Resource limits for tfyAgentProxy container. Advised to only increase the limits and not decrease it     | `500M`                                     |
| `tfyAgentProxy.resources.requests.cpu`                              | CPU resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it               | `100m`                                     |
| `tfyAgentProxy.resources.requests.memory`                           | Memory Resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it            | `180Mi`                                    |
| `tfyAgentProxy.resources.requests.ephemeral-storage`                | Ephemeral storage Resource requests for tfyAgentProxy container. Advised to only increase the requests and not decrease it | `200M`                                     |
| `tfyAgentProxy.securityContext`                                     | Security Context for the tfyAgentProxy container                                                                           | `{}`                                       |
| `tfyAgentProxy.tolerations`                                         | Taints that pod can tolerate                                                                                               | `[]`                                       |
| `tfyAgentProxy.nodeSelector`                                        | Parameters to select for scheduling of pod on a node                                                                       | `{}`                                       |
| `tfyAgentProxy.affinity`                                            | Affinity rules for pod scheduling on a node                                                                                | `{}`                                       |
| `tfyAgentProxy.priorityClassName`                                   | PriorityClass name for the pod.                                                                                            | `system-cluster-critical`                  |
| `tfyAgentProxy.serviceAccount.create`                               | Bool to enable serviceAccount creation                                                                                     | `true`                                     |
| `tfyAgentProxy.serviceAccount.annotations`                          | Annotations to add to the serviceAccount                                                                                   | `{}`                                       |
| `tfyAgentProxy.serviceAccount.name`                                 | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template          | `""`                                       |
| `tfyAgentProxy.extraVolumes`                                        | Extra volume for tfyAgentProxy container                                                                                   | `[]`                                       |
| `tfyAgentProxy.extraVolumeMounts`                                   | Extra volume mount for tfyAgentProxy container                                                                             | `[]`                                       |
| `tfyAgentProxy.clusterRole.enable`                                  | Create cluster role.                                                                                                       | `true`                                     |
| `tfyAgentProxy.clusterRole.strictMode`                              | Only add required authz rules.                                                                                             | `false`                                    |
| `tfyAgentProxy.clusterRole.clusterScopedAdditionalClusterRoleRules` | Additional rules to add to the cluster role for cluster-scoped resources.                                                  | `[]`                                       |

### resourceQuota Add a ResourceQuota to enable priority class in a namspace.

| Name                                             | Description                                                                                                       | Value                                      |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `resourceQuota.enabled`                          | Create the ResourceQuota.                                                                                         | `true`                                     |
| `resourceQuota.annotations`                      | Annotations to add to the ResourceQuota                                                                           | `{}`                                       |
| `resourceQuota.labels`                           | Labels to add to the ResourceQuota                                                                                | `{}`                                       |
| `resourceQuota.priorityClasses`                  | PriorityClasses to enable.                                                                                        | `["system-cluster-critical"]`              |
| `sdsServer.enabled`                              | Bool value to deploy sdsServer                                                                                    | `true`                                     |
| `sdsServer.replicas`                             | Number of replicas of sdsServer                                                                                   | `2`                                        |
| `sdsServer.annotations`                          | Add annotations to sdsServer pods                                                                                 | `{}`                                       |
| `sdsServer.labels`                               | Add labels to sdsServer pods                                                                                      | `{}`                                       |
| `sdsServer.nodeSelector`                         | Parameters to select for scheduling of pod on a node                                                              | `{}`                                       |
| `sdsServer.serviceAccount.create`                | Bool to enable serviceAccount creation                                                                            | `true`                                     |
| `sdsServer.serviceAccount.annotations`           | Annotations to add to the serviceAccount                                                                          | `{}`                                       |
| `sdsServer.serviceAccount.name`                  | Name of the serviceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                                       |
| `sdsServer.extraVolumes`                         | Additional volumes for sdsServer                                                                                  | `[]`                                       |
| `sdsServer.extraEnvVars`                         | Additional environment variables for sdsServer                                                                    | `[]`                                       |
| `sdsServer.service.clusterIP`                    | Cluster IP for sdsServer service                                                                                  | `""`                                       |
| `sdsServer.service.port`                         | Port for sdsServer service                                                                                        | `8000`                                     |
| `sdsServer.service.nodePort`                     | Port to expose on each node. Only used if service.type is 'NodePort'                                              | `""`                                       |
| `sdsServer.service.sessionAffinity`              | SessionAffinity for sdsServer Service                                                                             | `""`                                       |
| `sdsServer.service.type`                         | Type for sdsServer Service                                                                                        | `ClusterIP`                                |
| `sdsServer.image.repository`                     | Repository for sdsServer                                                                                          | `tfy.jfrog.io/tfy-images/sds-server`       |
| `sdsServer.image.pullPolicy`                     | Pull policy for sdsServer                                                                                         | `IfNotPresent`                             |
| `sdsServer.image.tag`                            | Tag for sdsServer                                                                                                 | `c3bb65485f56faaa236f4ee02074c6da7ab269a8` |
| `sdsServer.affinity`                             | Node affinity for sdsServer                                                                                       | `{}`                                       |
| `sdsServer.imagePullSecrets`                     | Image pull credentials for sdsServer                                                                              | `[]`                                       |
| `sdsServer.command`                              | Command and arguments to start the sdsServer application.                                                         | `["/app/sds-server","--port","8000"]`      |
| `sdsServer.readinessProbe.tcpSocket.port`        | Port for TCP socket used in readiness probe                                                                       | `8000`                                     |
| `sdsServer.readinessProbe.initialDelaySeconds`   | Initial delay before performing readiness probe                                                                   | `15`                                       |
| `sdsServer.readinessProbe.periodSeconds`         | Frequency of performing readiness probe                                                                           | `10`                                       |
| `sdsServer.livenessProbe.tcpSocket.port`         | Port for TCP socket used in liveness probe                                                                        | `8000`                                     |
| `sdsServer.livenessProbe.initialDelaySeconds`    | Initial delay before performing liveness probe                                                                    | `15`                                       |
| `sdsServer.livenessProbe.periodSeconds`          | Frequency of performing liveness probe                                                                            | `10`                                       |
| `sdsServer.resources.limits.cpu`                 | The maximum CPU resources allocated.                                                                              | `0.02`                                     |
| `sdsServer.resources.limits.ephemeral-storage`   | The maximum ephemeral storage allocated.                                                                          | `20M`                                      |
| `sdsServer.resources.limits.memory`              | The maximum memory resources allocated.                                                                           | `50M`                                      |
| `sdsServer.resources.requests.cpu`               | The minimum CPU resources requested.                                                                              | `0.01`                                     |
| `sdsServer.resources.requests.ephemeral-storage` | The minimum ephemeral storage requested.                                                                          | `10M`                                      |
| `sdsServer.resources.requests.memory`            | The minimum memory resources requested.                                                                           | `30M`                                      |
| `sdsServer.tolerations`                          | Tolerations for the sdsServer application                                                                         | `[]`                                       |
| `sdsServer.topologySpreadConstraints`            | topology spread constraints on sdsServer application                                                              | `[]`                                       |
