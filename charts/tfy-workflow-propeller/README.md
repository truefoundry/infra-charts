# Tfy-workflow-propeller helm chart packaged by TrueFoundry

This Helm chart package, provided by TrueFoundry, contains configurations and resources for deploying the Tfy workflow propeller.              

## Parameters

### Configuration for tfy-workflow-propeller

| Name                     | Description                  | Value              |
| ------------------------ | ---------------------------- | ------------------ |
| `global.tenantName`      | to set the tenant name       | `<to_be_provided>` |
| `global.controlPlaneUrl` | to set the control plane url | `<to_be_provided>` |

### flyte-core configurations

| Name                                                                                           | Description                                                                                       | Value                                                                        |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `flyte-core.common.ingress.enabled`                                                            | to enable the ingress                                                                             | `false`                                                                      |
| `flyte-core.secrets.adminOauthClientCredentials.enabled`                                       | to enable Oauth client credentials                                                                | `true`                                                                       |
| `flyte-core.storage.type`                                                                      | to define the storage type                                                                        | `<to_be_provided>`                                                           |
| `flyte-core.storage.limits.maxDownloadMBs`                                                     | to define the max download size                                                                   | `2`                                                                          |
| `flyte-core.storage.bucketName`                                                                | to define the storage bucket name                                                                 | `<to_be_provided>`                                                           |
| `flyte-core.storage.connection.region`                                                         | to define the storage connection region                                                           | `<to_be_provided>`                                                           |
| `flyte-core.storage.connection.auth-type`                                                      | to define the storage connection auth type                                                        | `<to_be_provided>`                                                           |
| `flyte-core.webhook.enabled`                                                                   | to enable the webhook                                                                             | `false`                                                                      |
| `flyte-core.configmap.k8s.plugins.k8s.default-env-vars[0].TFY_INTERNAL_SIGNED_URL_SERVER_HOST` | to set the signed url server host                                                                 | `http://tfy-signed-url-server.tfy-workflow-propeller.svc.cluster.local:3001` |
| `flyte-core.configmap.core.propeller.max-ttl-hours`                                            | to set the max ttl hours                                                                          | `1`                                                                          |
| `flyte-core.configmap.core.propeller.max-workflow-retries`                                     | to set the max workflow retries                                                                   | `5`                                                                          |
| `flyte-core.configmap.core.propeller.metadata-prefix`                                          | to set the storage uri path to set store the metadata, its values should be bucketName/metadata   | `<to_be_provided>/workflows/metadata`                                        |
| `flyte-core.configmap.core.propeller.rawoutput-prefix`                                         | to set the storage uri path to set store the raw output, its values should be bucketName/raw_data | `<to_be_provided>/workflows/raw_data`                                        |
| `flyte-core.configmap.core.propeller.publish-k8s-events`                                       | to publish kube events                                                                            | `true`                                                                       |
| `flyte-core.configmap.admin.admin.Command`                                                     | to set the external command                                                                       | `["echo","<to_be_provided>"]`                                                |
| `flyte-core.configmap.admin.admin.AuthType`                                                    | to set the auth type                                                                              | `ExternalCommand`                                                            |
| `flyte-core.configmap.admin.admin.endpoint`                                                    | to set the endpoint                                                                               | `<to_be_provided>`                                                           |
| `flyte-core.configmap.admin.admin.insecure`                                                    | to set the insecure flag                                                                          | `false`                                                                      |
| `flyte-core.configmap.admin.admin.AuthorizationHeader`                                         | to set the authorization header type                                                              | `authorization`                                                              |
| `flyte-core.configmap.admin.event.rate`                                                        | to set the rate                                                                                   | `500`                                                                        |
| `flyte-core.configmap.admin.event.type`                                                        | to set the type                                                                                   | `admin`                                                                      |
| `flyte-core.configmap.admin.event.capacity`                                                    | to set the capacity                                                                               | `100`                                                                        |
| `flyte-core.configmap.logger.level`                                                            | to set the log level                                                                              | `5`                                                                          |
| `flyte-core.configmap.logger.show-source`                                                      | to set the log format                                                                             | `true`                                                                       |
| `flyte-core.flyteadmin.enabled`                                                                | to enable the flyteadmin                                                                          | `false`                                                                      |
| `flyte-core.flyteadmin.serviceAccount.create`                                                  | to configure whether to create the service account or not                                         | `false`                                                                      |
| `flyte-core.datacatalog.enabled`                                                               | to enable the datacatalog                                                                         | `false`                                                                      |
| `flyte-core.flyteconsole.enabled`                                                              | to enable the flyteconsole                                                                        | `false`                                                                      |
| `flyte-core.flytepropeller.enabled`                                                            | to enable the flytepropeller                                                                      | `true`                                                                       |
| `flyte-core.flytepropeller.resources.limits.cpu`                                               | to set the cpu limit                                                                              | `1`                                                                          |
| `flyte-core.flytepropeller.resources.limits.memory`                                            | to set the memory limit                                                                           | `800Mi`                                                                      |
| `flyte-core.flytepropeller.resources.limits.ephemeral-storage`                                 | to set the ephemeral storage limit                                                                | `2Gi`                                                                        |
| `flyte-core.flytepropeller.resources.requests.cpu`                                             | to set the cpu request                                                                            | `0.5`                                                                        |
| `flyte-core.flytepropeller.resources.requests.memory`                                          | to set the memory request                                                                         | `500Mi`                                                                      |
| `flyte-core.flytepropeller.resources.requests.ephemeral-storage`                               | to set the ephemeral storage request                                                              | `1Gi`                                                                        |
| `flyte-core.flytepropeller.serviceAccount.create`                                              | to configure whether to create the service account or not                                         | `true`                                                                       |
| `flyte-core.flytepropeller.serviceAccount.annotations.eks.amazonaws.com/role-arn`              | to set the role arn to access service account                                                     | `<to_be_provided>`                                                           |
| `flyte-core.workflow_scheduler.enabled`                                                        | to enable workflow scheduler                                                                      | `false`                                                                      |
| `flyte-core.workflow_notifications.enabled`                                                    | to enable the workflow notifications                                                              | `false`                                                                      |
| `flyte-core.cluster_resource_manager.enabled`                                                  | to enable the cluster resource manager                                                            | `false`                                                                      |

### tfySignedURLServer configurations

| Name                                                      | Description                                   | Value                                           |
| --------------------------------------------------------- | --------------------------------------------- | ----------------------------------------------- |
| `tfySignedURLServer.enabled`                              | to enable the tfySignedURLServer              | `true`                                          |
| `tfySignedURLServer.serviceAccountName`                   | to set the service account name               | `flytepropeller`                                |
| `tfySignedURLServer.tolerations`                          | to set the tolerations                        | `[]`                                            |
| `tfySignedURLServer.image.repository`                     | to set the image repository                   | `tfy.jfrog.io/tfy-images/tfy-signed-url-server` |
| `tfySignedURLServer.image.tag`                            | to set the image tag                          | `0.0.1`                                         |
| `tfySignedURLServer.replicaCount`                         | to set the replica count                      | `2`                                             |
| `tfySignedURLServer.imagePullPolicy`                      | to set the image pull policy                  | `IfNotPresent`                                  |
| `tfySignedURLServer.nameOverride`                         | Override name for the tfySignedURLServer      | `""`                                            |
| `tfySignedURLServer.fullnameOverride`                     | Full name override for the tfySignedURLServer | `""`                                            |
| `tfySignedURLServer.envSecretName`                        | to set the environment secret name            | `tfy-signed-url-server-env`                     |
| `tfySignedURLServer.podAnnotations`                       | to set the pod annotations                    | `{}`                                            |
| `tfySignedURLServer.podSecurityContext`                   | to set the pod security context               | `{}`                                            |
| `tfySignedURLServer.commonLabels`                         | to set the common labels                      | `{}`                                            |
| `tfySignedURLServer.securityContext`                      | to set the security context                   | `{}`                                            |
| `tfySignedURLServer.resources.limits.cpu`                 | to set the cpu limit                          | `100m`                                          |
| `tfySignedURLServer.resources.limits.memory`              | to set the memory limit                       | `200Mi`                                         |
| `tfySignedURLServer.resources.limits.ephemeral-storage`   | to set the ephemeral storage limit            | `256Mi`                                         |
| `tfySignedURLServer.resources.requests.cpu`               | to set the cpu request                        | `100m`                                          |
| `tfySignedURLServer.resources.requests.memory`            | to set the memory request                     | `100Mi`                                         |
| `tfySignedURLServer.resources.requests.ephemeral-storage` | to set the ephemeral storage request          | `128Mi`                                         |
| `tfySignedURLServer.nodeSelector`                         | to set the node selector                      | `{}`                                            |
| `tfySignedURLServer.affinity`                             | to set the affinity                           | `{}`                                            |
| `tfySignedURLServer.topologySpreadConstraints`            | to set the topology spread constraints        | `{}`                                            |
| `tfySignedURLServer.service.type`                         | to set the service type                       | `ClusterIP`                                     |
| `tfySignedURLServer.service.port`                         | to set the service port                       | `3001`                                          |
| `tfySignedURLServer.service.annotations`                  | to set the annotations                        | `{}`                                            |
| `tfySignedURLServer.imagePullSecrets`                     | to set the image pull secrets                 | `[]`                                            |
| `tfySignedURLServer.extraVolumes`                         | to set the extra volumes                      | `[]`                                            |
| `tfySignedURLServer.extraVolumeMounts`                    | to set the extra volume mounts                | `[]`                                            |
