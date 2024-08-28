# Tfy-workflow-propeller helm chart packaged by TrueFoundry

This Helm chart package, provided by TrueFoundry, contains configurations and resources for deploying the Tfy workflow propeller.              

## Parameters

### Configuration for tfy-workflow-propeller


### flyte-core configurations

| Name                                                                              | Description                                                                                       | Value                                 |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `flyte-core.common.ingress.enabled`                                               | to enable the ingress                                                                             | `false`                               |
| `flyte-core.secrets.adminOauthClientCredentials.enabled`                          | to enable Oauth client credentials                                                                | `true`                                |
| `flyte-core.storage.type`                                                         | to define the storage type                                                                        | `<to_be_provided>`                    |
| `flyte-core.storage.limits.maxDownloadMBs`                                        | to define the max download size                                                                   | `10`                                  |
| `flyte-core.storage.bucketName`                                                   | to define the storage bucket name                                                                 | `<to_be_provided>`                    |
| `flyte-core.storage.connection.region`                                            | to define the storage connection region                                                           | `<to_be_provided>`                    |
| `flyte-core.storage.connection.auth-type`                                         | to define the storage connection auth type                                                        | `<to_be_provided>`                    |
| `flyte-core.storage.enable-multicontainer`                                        | to enable the multicontainer                                                                      | `true`                                |
| `flyte-core.webhook.enabled`                                                      | to enable the webhook                                                                             | `true`                                |
| `flyte-core.configmap.core.propeller.metadata-prefix`                             | to set the storage uri path to set store the metadata, its values should be bucketName/metadata   | `<to_be_provided>/workflows/metadata` |
| `flyte-core.configmap.core.propeller.rawoutput-prefix`                            | to set the storage uri path to set store the raw output, its values should be bucketName/raw_data | `<to_be_provided>/workflows/raw_data` |
| `flyte-core.configmap.core.propeller.publish-k8s-events`                          | to publish kube events                                                                            | `true`                                |
| `flyte-core.configmap.admin.admin.Command`                                        | to set the external command                                                                       | `["echo","<to_be_provided>"]`         |
| `flyte-core.configmap.admin.admin.AuthType`                                       | to set the auth type                                                                              | `ExternalCommand`                     |
| `flyte-core.configmap.admin.admin.endpoint`                                       | to set the endpoint                                                                               | `<to_be_provided>`                    |
| `flyte-core.configmap.admin.admin.insecure`                                       | to set the insecure flag                                                                          | `false`                               |
| `flyte-core.configmap.admin.admin.AuthorizationHeader`                            | to set the authorization header type                                                              | `authorization`                       |
| `flyte-core.configmap.admin.event.rate`                                           | to set the rate                                                                                   | `500`                                 |
| `flyte-core.configmap.admin.event.type`                                           | to set the type                                                                                   | `admin`                               |
| `flyte-core.configmap.admin.event.capacity`                                       | to set the capacity                                                                               | `100`                                 |
| `flyte-core.configmap.logger.level`                                               | to set the log level                                                                              | `5`                                   |
| `flyte-core.configmap.logger.show-source`                                         | to set the log format                                                                             | `true`                                |
| `flyte-core.flyteadmin.enabled`                                                   | to enable the flyteadmin                                                                          | `false`                               |
| `flyte-core.datacatalog.enabled`                                                  | to enable the datacatalog                                                                         | `false`                               |
| `flyte-core.flyteconsole.enabled`                                                 | to enable the flyteconsole                                                                        | `false`                               |
| `flyte-core.flytepropeller.enabled`                                               | to enable the flytepropeller                                                                      | `true`                                |
| `flyte-core.flytepropeller.serviceAccount.create`                                 | to configure whether to create the service account or not                                         | `true`                                |
| `flyte-core.flytepropeller.serviceAccount.annotations.eks.amazonaws.com/role-arn` | to set the role arn to access service account                                                     | `<to_be_provided>`                    |
| `flyte-core.workflow_scheduler.enabled`                                           | to enable workflow scheduler                                                                      | `false`                               |
| `flyte-core.workflow_notifications.enabled`                                       | to enable the workflow notifications                                                              | `false`                               |
| `flyte-core.cluster_resource_manager.enabled`                                     | to enable the cluster resource manager                                                            | `false`                               |
