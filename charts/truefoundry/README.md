# truefoundry helm chart packaged by TrueFoundry

truefoundry is an applications that gets deployed on the kubernetes cluster to spin up the TrueFoundry Control plane

## Order of Installation

The TrueFoundry Helm chart components are installed in the following order:

1. **Bootstrap Resources**

   - ConfigMap
   - ServiceAccount
   - Role
   - RoleBinding

2. **Sync-wave: 0**

   - All stateful dependencies and non-Deployment resources including:
     - Namespace
     - ServiceAccount
     - Role
     - RoleBinding
     - tfy-nats
     - ClickHouse
     - PostgreSQL
     - Zookeeper
     - Any component without a defined sync-wave

3. **Sync-wave: 1**

   - Deployment of servicefoundry-server

4. **Sync-wave: 2**
   - Deployment of other components including:
     - mlfoundry-server
     - truefoundry-frontend-app
     - tfy-llm-gateway
     - s3proxy
     - Additional control plane services

## Using K8s secret for required fields

For control plane installation, you need to provide licence key and DB credentials in the values. This can be done either by adding the values as plain text in the values file or using a externally created K8s secret in the same namespace.

Following are the K8s secrets that are required for the TrueFoundry installation.

1. `truefoundry-creds` secret containing the following keys:
   - TFY_API_KEY - Licence key provided by TrueFoundry team
   - DB_HOST - Hostname of the database
   - DB_NAME - Name of the database
   - DB_USERNAME - Username of the database
   - DB_PASSWORD - Password of the database
2. `truefoundry-image-pull-secret` secret of type `kubernetes.io/dockerconfigjson` containing the following key:
   - .dockerconfigjson - Docker config json for the TrueFoundry images

In order to use these secrets in the TrueFoundry installation, you need to pass the secret name in the values file as follows:

```yaml
global:
  existingTruefoundryCredsSecret: "truefoundry-creds"
  existingTruefoundryImagePullSecretName: "truefoundry-image-pull-secret"
```

## Using K8s secret for additional fields

In case, you would like to use secret for some additional field in the values, please pass the secret name and key in the values file in following format:
`${k8s-secret/<K8S_SECRET_NAME>/<KEY_NAME>}`

For example,

1. to pass the `awsAccessKeyId` under `global.config.storageConfiguration.awsAccessKeyId` from the `my-truefoundry-secrets` secret, you can use the following format:

```yaml
global:
  config:
    storageConfiguration:
      awsAccessKeyId: ${k8s-secret/my-truefoundry-secrets/awsAccessKeyId}
```

2. to pass `GITHUB_PRIVATE_KEY` env under `servicefoundryServer.env.GITHUB_PRIVATE_KEY` from the `my-truefoundry-secrets` secret, you can use the following format:

```yaml
servicefoundryServer:
  env:
    GITHUB_PRIVATE_KEY: ${k8s-secret/my-truefoundry-secrets/GITHUB_PRIVATE_KEY}
```

## Parameters

### Global prameters for Truefoundry

| Name                                                                         | Description                                                                            | Value                                                                            |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `global.resourceTier`                                                        | Resource deployment tier for the control plane, either small, medium or large accepted | `medium`                                                                         |
| `global.existingTruefoundryImagePullSecretName`                              | Name of the existing image pull secret                                                 | `""`                                                                             |
| `global.truefoundryImagePullConfigJSON`                                      | JSON config for image pull secret                                                      | `""`                                                                             |
| `global.tenantName`                                                          | Name of the tenant                                                                     | `""`                                                                             |
| `global.controlPlaneURL`                                                     | URL of the control plane                                                               | `http://truefoundry-truefoundry-frontend-app.truefoundry.svc.cluster.local:5000` |
| `global.controlPlaneChartVersion`                                            | Version of control-plane chart                                                         | `0.80.0-rc.1`                                                                    |
| `global.existingTruefoundryCredsSecret`                                      | Name of the existing truefoundry creds secret                                          | `""`                                                                             |
| `global.database.host`                                                       | Control plane database hostname when dev mode is not enabled                           | `""`                                                                             |
| `global.database.name`                                                       | Control plane database name when dev mode is not enabled                               | `""`                                                                             |
| `global.database.username`                                                   | Control plane database username when dev mode is not enabled                           | `""`                                                                             |
| `global.database.password`                                                   | Control plane database password when dev mode is not enabled                           | `""`                                                                             |
| `global.tfyApiKey`                                                           | API key for truefoundry                                                                | `""`                                                                             |
| `global.image.registry`                                                      | Default registry for all images                                                        | `tfy.jfrog.io`                                                                   |
| `global.nodeSelector`                                                        | Node selector for all services                                                         | `{}`                                                                             |
| `global.affinity`                                                            | Affinity for all services                                                              | `{}`                                                                             |
| `global.labels`                                                              | Labels for all services                                                                | `{}`                                                                             |
| `global.annotations`                                                         | Annotations for all services                                                           | `{}`                                                                             |
| `global.serviceAccount.create`                                               | Bool to enable service account                                                         | `true`                                                                           |
| `global.serviceAccount.name`                                                 | Name of the service account                                                            | `truefoundry`                                                                    |
| `global.serviceAccount.annotations`                                          | Annotations for the service account                                                    | `{}`                                                                             |
| `global.serviceAccount.automountServiceAccountToken`                         | Automount service account token for the service account                                | `true`                                                                           |
| `global.config.defaultCloudProvider`                                         | Default Cloud provider                                                                 | `""`                                                                             |
| `global.config.storageConfiguration.awsS3BucketName`                         | AWS S3 bucket name                                                                     | `""`                                                                             |
| `global.config.storageConfiguration.awsRegion`                               | AWS region                                                                             | `""`                                                                             |
| `global.config.storageConfiguration.awsAssumeRoleArn`                        | AWS assume role ARN                                                                    | `""`                                                                             |
| `global.config.storageConfiguration.azureBlobUri`                            | Azure blob URI                                                                         | `""`                                                                             |
| `global.config.storageConfiguration.azureBlobConnectionString`               | Azure blob connection string                                                           | `""`                                                                             |
| `global.config.storageConfiguration.googleCloudProjectId`                    | Google cloud project ID                                                                | `""`                                                                             |
| `global.config.storageConfiguration.googleCloudStorageBucketName`            | Google cloud storage bucket name                                                       | `""`                                                                             |
| `global.config.storageConfiguration.googleCloudServiceAccountKeyFileContent` | Google cloud service account key file content                                          | `""`                                                                             |
| `tags.llmGateway`                                                            | Bool to enable llmGateway infra                                                        | `false`                                                                          |
| `tags.llmGatewayRequestLogging`                                              | Bool to enable request logging feature in LLM gateway                                  | `false`                                                                          |
| `tags.tracing`                                                               | Bool to enable OTEL tracing feature                                                    | `false`                                                                          |
| `devMode.enabled`                                                            | Bool to enable dev mode                                                                | `false`                                                                          |

### Monitoring Config values

| Name                                                          | Description                                     | Value                                    |
| ------------------------------------------------------------- | ----------------------------------------------- | ---------------------------------------- |
| `monitoring.enabled`                                          | Bool to enable monitoring for the control plane | `false`                                  |
| `monitoring.tenantNameOverride`                               | Override tenant name for the monitoring         | `""`                                     |
| `monitoring.alertManager.enabled`                             | Bool to enable alert manager                    | `true`                                   |
| `monitoring.alertManager.name`                                | Name of the alert manager configuration         | `tfy-control-plane-alert-manager`        |
| `monitoring.alertManager.additionalLabels`                    | Additional labels for alert manager             | `{}`                                     |
| `monitoring.alertManager.additionalAnnotations`               | Additional annotations for alert manager        | `{}`                                     |
| `monitoring.alertManager.slackConfigs.enabled`                | Bool to enable Slack notifications              | `true`                                   |
| `monitoring.alertManager.slackConfigs.channel`                | Slack channel to send alerts to                 | `#customer-cp-alerts`                    |
| `monitoring.alertManager.slackConfigs.apiURL.name`            | Name of secret containing Slack API URL         | `tfy-control-plane-alert-manager-secret` |
| `monitoring.alertManager.slackConfigs.apiURL.key`             | Key in secret containing Slack API URL          | `API_URL`                                |
| `monitoring.alertManager.slackConfigs.additionalSlackConfigs` | Additional Slack configurations                 | `[]`                                     |
| `monitoring.alertManager.additionalReceivers`                 | Additional alert receivers                      | `[]`                                     |
| `monitoring.alertManager.secret.create`                       | Bool to create secret for alert manager         | `false`                                  |
| `monitoring.alertManager.secret.name`                         | Name of the secret                              | `tfy-control-plane-alert-manager-secret` |
| `monitoring.alertManager.secret.data`                         | Data to be stored in secret                     | `{}`                                     |
| `monitoring.alertRules.enabled`                               | Bool to enable alert rules                      | `true`                                   |
| `monitoring.alertRules.name`                                  | Name of the alert rules configuration           | `tfy-control-plane-alert-rules`          |
| `monitoring.alertRules.additionalLabels`                      | Additional labels for alert rules               | `{}`                                     |
| `monitoring.alertRules.additionalAnnotations`                 | Additional annotations for alert rules          | `{}`                                     |

### Truefoundry bootstrap values

| Name                                                               | Description                                                               | Value                              |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------- | ---------------------------------- |
| `truefoundryBootstrap.enabled`                                     | Bool to enable truefoundry bootstrap                                      | `true`                             |
| `truefoundryBootstrap.serviceAccount.automountServiceAccountToken` | Automount service account token for the bootstrap container               | `true`                             |
| `truefoundryBootstrap.podSecurityContext`                          | Pod security context for the bootstrap container                          | `{}`                               |
| `truefoundryBootstrap.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the bootstrap container                     | `true`                             |
| `truefoundryBootstrap.image.registry`                              | Registry for the bootstrap image (overrides global.registry if specified) | `""`                               |
| `truefoundryBootstrap.image.repository`                            | Truefoundry bootstrap image repository (without registry)                 | `tfy-images/truefoundry-bootstrap` |
| `truefoundryBootstrap.image.tag`                                   | Truefoundry bootstrap image tag                                           | `0.1.5`                            |
| `truefoundryBootstrap.natsConfigmapName`                           | Truefoundry nats configmap name                                           | `tfy-nats-accounts`                |
| `truefoundryBootstrap.annotations`                                 | Annotations for the bootstrap job                                         | `{}`                               |
| `truefoundryBootstrap.commonLabels`                                | Common labels for the bootstrap job                                       | `{}`                               |
| `truefoundryBootstrap.extraEnvVars`                                | Extra environment variables for the bootstrap container                   | `[]`                               |
| `truefoundryBootstrap.extraVolumeMounts`                           | Extra volume mounts for the bootstrap container                           | `[]`                               |
| `truefoundryBootstrap.extraVolumes`                                | Extra volumes for the bootstrap container                                 | `[]`                               |
| `truefoundryBootstrap.affinity`                                    | Affinity for the bootstrap container                                      | `{}`                               |
| `truefoundryBootstrap.nodeSelector`                                | Node selector for the bootstrap container                                 | `{}`                               |
| `truefoundryBootstrap.tolerations`                                 | Tolerations specific to the bootstrap container                           | `[]`                               |
| `truefoundryBootstrap.imagePullSecrets`                            | Image pull secrets for the bootstrap container                            | `[]`                               |
| `truefoundryBootstrap.createdBuildkitServiceTlsCerts`              | Bool to install TLS certificates                                          | `true`                             |

### Truefoundry Frontend App values

| Name                                                                 | Description                                                                  | Value                                                                                      |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `truefoundryFrontendApp.enabled`                                     | Bool to enable the frontend app                                              | `true`                                                                                     |
| `truefoundryFrontendApp.tolerations`                                 | Tolerations specific to the frontend app                                     | `[]`                                                                                       |
| `truefoundryFrontendApp.annotations`                                 | Annotations for the frontend app                                             | `{}`                                                                                       |
| `truefoundryFrontendApp.image.registry`                              | Registry for the frontend app image (overrides global.registry if specified) | `""`                                                                                       |
| `truefoundryFrontendApp.image.repository`                            | Image repository for the frontend app (without registry)                     | `tfy-private-images/truefoundry-frontend-app`                                              |
| `truefoundryFrontendApp.image.tag`                                   | Image tag for the frontend app                                               | `v0.80.0`                                                                                  |
| `truefoundryFrontendApp.envSecretName`                               | Secret name for the frontend app environment variables                       | `truefoundry-frontend-app-env-secret`                                                      |
| `truefoundryFrontendApp.imagePullPolicy`                             | Image pull policy for the frontend app                                       | `IfNotPresent`                                                                             |
| `truefoundryFrontendApp.nameOverride`                                | Override name for the frontend app                                           | `""`                                                                                       |
| `truefoundryFrontendApp.fullnameOverride`                            | Full name override for the frontend app                                      | `""`                                                                                       |
| `truefoundryFrontendApp.podAnnotations`                              | Annotations for the frontend app pods                                        | `{}`                                                                                       |
| `truefoundryFrontendApp.podSecurityContext`                          | Security context for the frontend app pods                                   | `{}`                                                                                       |
| `truefoundryFrontendApp.commonLabels`                                | Common labels for the frontend app pods                                      | `{}`                                                                                       |
| `truefoundryFrontendApp.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the frontend app                               | `true`                                                                                     |
| `truefoundryFrontendApp.resources`                                   | Resource requests and limits for the frontend app                            | `{}`                                                                                       |
| `truefoundryFrontendApp.livenessProbe.initialDelaySeconds`           | Initial delay seconds for the liveness probe                                 | `600`                                                                                      |
| `truefoundryFrontendApp.livenessProbe.periodSeconds`                 | Period seconds for the liveness probe                                        | `30`                                                                                       |
| `truefoundryFrontendApp.livenessProbe.timeoutSeconds`                | Timeout seconds for the liveness probe                                       | `5`                                                                                        |
| `truefoundryFrontendApp.livenessProbe.failureThreshold`              | Failure threshold for the liveness probe                                     | `3`                                                                                        |
| `truefoundryFrontendApp.livenessProbe.successThreshold`              | Success threshold for the liveness probe                                     | `1`                                                                                        |
| `truefoundryFrontendApp.readinessProbe.initialDelaySeconds`          | Initial delay seconds for the readiness probe                                | `30`                                                                                       |
| `truefoundryFrontendApp.readinessProbe.periodSeconds`                | Period seconds for the readiness probe                                       | `30`                                                                                       |
| `truefoundryFrontendApp.readinessProbe.timeoutSeconds`               | Timeout seconds for the readiness probe                                      | `5`                                                                                        |
| `truefoundryFrontendApp.readinessProbe.failureThreshold`             | Failure threshold for the readiness probe                                    | `3`                                                                                        |
| `truefoundryFrontendApp.readinessProbe.successThreshold`             | Success threshold for the readiness probe                                    | `1`                                                                                        |
| `truefoundryFrontendApp.nodeSelector`                                | Node selector for the frontend app                                           | `{}`                                                                                       |
| `truefoundryFrontendApp.affinity`                                    | Affinity settings for the frontend app                                       | `{}`                                                                                       |
| `truefoundryFrontendApp.topologySpreadConstraints`                   | Topology spread constraints for the frontend app                             | `{}`                                                                                       |
| `truefoundryFrontendApp.service.type`                                | Service type for the frontend app                                            | `ClusterIP`                                                                                |
| `truefoundryFrontendApp.service.port`                                | Service port for the frontend app                                            | `5000`                                                                                     |
| `truefoundryFrontendApp.service.annotations`                         | Annotations for the frontend app service                                     | `{}`                                                                                       |
| `truefoundryFrontendApp.ingress.enabled`                             | Enable ingress for the frontend app                                          | `false`                                                                                    |
| `truefoundryFrontendApp.ingress.annotations`                         | Annotations for the frontend app ingress                                     | `{}`                                                                                       |
| `truefoundryFrontendApp.ingress.labels`                              | Labels for the frontend app ingress                                          | `{}`                                                                                       |
| `truefoundryFrontendApp.ingress.ingressClassName`                    | Ingress class name for the frontend app                                      | `istio`                                                                                    |
| `truefoundryFrontendApp.ingress.tls`                                 | TLS settings for the frontend app                                            | `[]`                                                                                       |
| `truefoundryFrontendApp.ingress.hosts`                               | Hosts for the frontend app                                                   | `[]`                                                                                       |
| `truefoundryFrontendApp.istio.virtualservice.enabled`                | Enable virtual service for the frontend app                                  | `false`                                                                                    |
| `truefoundryFrontendApp.istio.virtualservice.annotations`            | Annotations for the frontend app virtual service                             | `{}`                                                                                       |
| `truefoundryFrontendApp.istio.virtualservice.gateways`               | Gateways for the frontend app virtual service                                | `[]`                                                                                       |
| `truefoundryFrontendApp.istio.virtualservice.hosts`                  | Hosts for the frontend app virtual service                                   | `[]`                                                                                       |
| `truefoundryFrontendApp.servicefoundryServerHost`                    | Servicefoundry server host for the frontend app                              | `{{ .Release.Name }}-servicefoundry-server.{{ .Release.Namespace }}.svc.cluster.local`     |
| `truefoundryFrontendApp.tfyWorkflowAdminHost`                        | tfy workflow admin host for the frontend app                                 | `{{ .Release.Name }}-tfy-workflow-admin-server.{{ .Release.Namespace }}.svc.cluster.local` |
| `truefoundryFrontendApp.s3proxyHost`                                 | s3 proxy host for the frontend app                                           | `{{ .Release.Name }}-s3proxy.{{ .Release.Namespace }}.svc.cluster.local`                   |
| `truefoundryFrontendApp.tfyOtelCollectorHost`                        | otel collector host for the frontend app                                     | `{{ .Release.Name }}-tfy-otel-collector.{{ .Release.Namespace }}.svc.cluster.local`        |
| `truefoundryFrontendApp.llmGateway.external`                         | Make LLMGateway external                                                     | `false`                                                                                    |
| `truefoundryFrontendApp.llmGateway.backendHost`                      | Backend Host for the LLM gateway                                             | `{{ .Release.Name }}-tfy-llm-gateway.{{ .Release.Namespace }}.svc.cluster.local`           |
| `truefoundryFrontendApp.llmGateway.backendPort`                      | Backend Port for the LLM gateway                                             | `8787`                                                                                     |
| `truefoundryFrontendApp.proxyServerHost`                             | Proxy server host for the frontend app                                       | `{{ .Release.Name }}-tfy-controller.{{ .Release.Namespace }}.svc.cluster.local`            |
| `truefoundryFrontendApp.serviceAccount.annotations`                  | Annotations for the frontend app service account                             | `{}`                                                                                       |
| `truefoundryFrontendApp.serviceAccount.automountServiceAccountToken` | Automount service account token for the frontend app                         | `true`                                                                                     |
| `truefoundryFrontendApp.extraVolumes`                                | Extra volumes for the frontend app                                           | `[]`                                                                                       |
| `truefoundryFrontendApp.extraVolumeMounts`                           | Extra volume mounts for the frontend app                                     | `[]`                                                                                       |
| `truefoundryFrontendApp.imagePullSecrets`                            | Image pull secrets for the frontend app                                      | `[]`                                                                                       |
| `truefoundryFrontendApp.env`                                         | Environment variables for the frontend app                                   | `{}`                                                                                       |

### mlfoundryServer Truefoundry mlfoundry server values

| Name                                                          | Description                                                                      | Value                                 |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- |
| `mlfoundryServer.enabled`                                     | Bool to enable the mlfoundry server                                              | `true`                                |
| `mlfoundryServer.tolerations`                                 | Tolerations specific to the mlfoundry server                                     | `[]`                                  |
| `mlfoundryServer.annotations`                                 | Annotations for the mlfoundry server                                             | `{}`                                  |
| `mlfoundryServer.image.registry`                              | Registry for the mlfoundry server image (overrides global.registry if specified) | `""`                                  |
| `mlfoundryServer.image.repository`                            | Image repository for the mlfoundry server (without registry)                     | `tfy-private-images/mlfoundry-server` |
| `mlfoundryServer.image.tag`                                   | Image tag for the mlfoundry server                                               | `v0.80.0`                             |
| `mlfoundryServer.environmentName`                             | Environment name for the mlfoundry server                                        | `default`                             |
| `mlfoundryServer.envSecretName`                               | Secret name for the mlfoundry server environment variables                       | `mlfoundry-server-env-secret`         |
| `mlfoundryServer.imagePullPolicy`                             | Image pull policy for the mlfoundry server                                       | `IfNotPresent`                        |
| `mlfoundryServer.nameOverride`                                | Override name for the mlfoundry server                                           | `""`                                  |
| `mlfoundryServer.fullnameOverride`                            | Full name override for the mlfoundry server                                      | `""`                                  |
| `mlfoundryServer.podAnnotations`                              | Annotations for the mlfoundry server pods                                        | `{}`                                  |
| `mlfoundryServer.podSecurityContext`                          | Security context for the mlfoundry server pods                                   | `{}`                                  |
| `mlfoundryServer.commonLabels`                                | Common labels for the mlfoundry server pods                                      | `{}`                                  |
| `mlfoundryServer.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the mlfoundry server                               | `true`                                |
| `mlfoundryServer.resources`                                   | Resource requests and limits for the mlfoundry server                            | `{}`                                  |
| `mlfoundryServer.livenessProbe.failureThreshold`              | Liveness probe failure threshold for mlfoundry server                            | `3`                                   |
| `mlfoundryServer.livenessProbe.initialDelaySeconds`           | Liveness probe initial delay for mlfoundry server                                | `600`                                 |
| `mlfoundryServer.livenessProbe.periodSeconds`                 | Liveness probe period for mlfoundry server                                       | `10`                                  |
| `mlfoundryServer.livenessProbe.successThreshold`              | Liveness probe success threshold for mlfoundry server                            | `1`                                   |
| `mlfoundryServer.livenessProbe.timeoutSeconds`                | Liveness probe timeout for mlfoundry server                                      | `1`                                   |
| `mlfoundryServer.readinessProbe.failureThreshold`             | Readiness probe failure threshold for mlfoundry server                           | `3`                                   |
| `mlfoundryServer.readinessProbe.initialDelaySeconds`          | Readiness probe initial delay for mlfoundry server                               | `30`                                  |
| `mlfoundryServer.readinessProbe.periodSeconds`                | Readiness probe period for mlfoundry server                                      | `10`                                  |
| `mlfoundryServer.readinessProbe.successThreshold`             | Readiness probe success threshold for mlfoundry server                           | `1`                                   |
| `mlfoundryServer.readinessProbe.timeoutSeconds`               | Readiness probe timeout for mlfoundry server                                     | `1`                                   |
| `mlfoundryServer.nodeSelector`                                | Node selector for the mlfoundry server                                           | `{}`                                  |
| `mlfoundryServer.affinity`                                    | Affinity settings for the mlfoundry server                                       | `{}`                                  |
| `mlfoundryServer.topologySpreadConstraints`                   | Topology spread constraints for the mlfoundry server                             | `{}`                                  |
| `mlfoundryServer.service.type`                                | Service type for the mlfoundry server                                            | `ClusterIP`                           |
| `mlfoundryServer.service.port`                                | Service port for the mlfoundry server                                            | `5000`                                |
| `mlfoundryServer.service.annotations`                         | Annotations for the mlfoundry server service                                     | `{}`                                  |
| `mlfoundryServer.serviceAccount.create`                       | Bool to create a service account for the mlfoundry server                        | `false`                               |
| `mlfoundryServer.serviceAccount.name`                         | Name of the mlfoundry server service account                                     | `""`                                  |
| `mlfoundryServer.serviceAccount.annotations`                  | Annotations for the mlfoundry server service account                             | `{}`                                  |
| `mlfoundryServer.serviceAccount.automountServiceAccountToken` | Automount service account token for the mlfoundry server                         | `true`                                |
| `mlfoundryServer.imagePullSecrets`                            | Image pull credentials for mlfoundry server                                      | `[]`                                  |
| `mlfoundryServer.extraVolumes`                                | Extra volumes for the mlfoundry server                                           | `[]`                                  |
| `mlfoundryServer.extraVolumeMounts`                           | Extra volume mounts for the mlfoundry server                                     | `[]`                                  |
| `mlfoundryServer.env`                                         | Environment variables for the mlfoundry server                                   | `{}`                                  |

### sparkHistoryServer Truefoundry spark history server values

| Name                                         | Description                                                              | Value                                                                                 |
| -------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `s3proxy.enabled`                            | Bool to enable the s3 proxy                                              | `false`                                                                               |
| `s3proxy.tolerations`                        | Tolerations specific to the s3 proxy                                     | `[]`                                                                                  |
| `s3proxy.annotations`                        | Annotations for the s3 proxy                                             | `{}`                                                                                  |
| `s3proxy.image.registry`                     | Registry for the s3 proxy image (overrides global.registry if specified) | `""`                                                                                  |
| `s3proxy.image.repository`                   | Image repository for the s3 proxy (without registry)                     | `tfy-private-images/s3proxy`                                                          |
| `s3proxy.image.tag`                          | Image tag for the s3 proxy                                               | `v0.57.0`                                                                             |
| `s3proxy.environmentName`                    | Environment name for the s3 proxy                                        | `default`                                                                             |
| `s3proxy.envSecretName`                      | Secret name for the s3 proxy environment variables                       | `s3proxy-env-secret`                                                                  |
| `s3proxy.imagePullPolicy`                    | Image pull policy for the s3 proxy                                       | `IfNotPresent`                                                                        |
| `s3proxy.nameOverride`                       | Override name for the s3 proxy                                           | `""`                                                                                  |
| `s3proxy.fullnameOverride`                   | Full name override for the s3 proxy                                      | `""`                                                                                  |
| `s3proxy.podAnnotations`                     | Annotations for the s3 proxy pods                                        | `{}`                                                                                  |
| `s3proxy.podSecurityContext`                 | Security context for the s3 proxy pods                                   | `{}`                                                                                  |
| `s3proxy.commonLabels`                       | Common labels for the s3 proxy pods                                      | `{}`                                                                                  |
| `s3proxy.securityContext`                    | Security context for the s3 proxy                                        | `{}`                                                                                  |
| `s3proxy.livenessProbe.failureThreshold`     | Liveness probe failure threshold for s3 proxy                            | `3`                                                                                   |
| `s3proxy.livenessProbe.initialDelaySeconds`  | Liveness probe initial delay for s3 proxy                                | `600`                                                                                 |
| `s3proxy.livenessProbe.periodSeconds`        | Liveness probe period for s3 proxy                                       | `10`                                                                                  |
| `s3proxy.livenessProbe.successThreshold`     | Liveness probe success threshold for s3 proxy                            | `1`                                                                                   |
| `s3proxy.livenessProbe.timeoutSeconds`       | Liveness probe timeout for s3 proxy                                      | `1`                                                                                   |
| `s3proxy.readinessProbe.failureThreshold`    | Readiness probe failure threshold for s3 proxy                           | `3`                                                                                   |
| `s3proxy.readinessProbe.initialDelaySeconds` | Readiness probe initial delay for s3 proxy                               | `30`                                                                                  |
| `s3proxy.readinessProbe.periodSeconds`       | Readiness probe period for s3 proxy                                      | `10`                                                                                  |
| `s3proxy.readinessProbe.successThreshold`    | Readiness probe success threshold for s3 proxy                           | `1`                                                                                   |
| `s3proxy.readinessProbe.timeoutSeconds`      | Readiness probe timeout for s3 proxy                                     | `1`                                                                                   |
| `s3proxy.nodeSelector`                       | Node selector for the s3 proxy                                           | `{}`                                                                                  |
| `s3proxy.affinity`                           | Affinity settings for the s3 proxy                                       | `{}`                                                                                  |
| `s3proxy.topologySpreadConstraints`          | Topology spread constraints for the s3 proxy                             | `{}`                                                                                  |
| `s3proxy.service.type`                       | Service type for the s3 proxy                                            | `ClusterIP`                                                                           |
| `s3proxy.service.port`                       | Service port for the s3 proxy                                            | `8080`                                                                                |
| `s3proxy.service.annotations`                | Annotations for the s3 proxy service                                     | `{}`                                                                                  |
| `s3proxy.serviceAccount.create`              | Bool to create the s3 proxy service account                              | `false`                                                                               |
| `s3proxy.serviceAccount.name`                | Name of the s3 proxy service account                                     | `""`                                                                                  |
| `s3proxy.serviceAccount.annotations`         | Annotations for the s3 proxy service account                             | `{}`                                                                                  |
| `s3proxy.extraVolumes`                       | Extra volumes for the s3 proxy                                           | `[]`                                                                                  |
| `s3proxy.extraVolumeMounts`                  | Extra volume mounts for the s3 proxy                                     | `[]`                                                                                  |
| `s3proxy.imagePullSecrets`                   | Image pull credentials for s3 proxy                                      | `[]`                                                                                  |
| `s3proxy.config.jcloudsEndpoint`             | JClouds endpoint for the s3 proxy                                        | `https://s3.{{ .Values.global.config.storageConfiguration.awsRegion }}.amazonaws.com` |
| `s3proxy.config.jcloudsProvider`             | JClouds provider for the s3 proxy                                        | `aws-s3`                                                                              |
| `s3proxy.env`                                | Environment variables for the s3 proxy                                   | `{}`                                                                                  |

### servicefoundryServer Truefoundry servicefoundry server values

| Name                                                               | Description                                                                           | Value                                                   |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `servicefoundryServer.enabled`                                     | Bool to enable the servicefoundry server                                              | `true`                                                  |
| `servicefoundryServer.tolerations`                                 | Tolerations specific to the servicefoundry server                                     | `[]`                                                    |
| `servicefoundryServer.annotations`                                 | Annotations for the mlfoundry server                                                  | `{}`                                                    |
| `servicefoundryServer.image.registry`                              | Registry for the servicefoundry server image (overrides global.registry if specified) | `""`                                                    |
| `servicefoundryServer.image.repository`                            | Image repository for the servicefoundry server (without registry)                     | `tfy-private-images/servicefoundry-server`              |
| `servicefoundryServer.image.tag`                                   | Image tag for the servicefoundry server                                               | `v0.80.0`                                               |
| `servicefoundryServer.environmentName`                             | Environment name for the servicefoundry server                                        | `default`                                               |
| `servicefoundryServer.envSecretName`                               | Secret name for the servicefoundry server environment variables                       | `servicefoundry-server-env-secret`                      |
| `servicefoundryServer.imagePullPolicy`                             | Image pull policy for the servicefoundry server                                       | `IfNotPresent`                                          |
| `servicefoundryServer.nameOverride`                                | Override name for the servicefoundry server                                           | `""`                                                    |
| `servicefoundryServer.fullnameOverride`                            | Full name override for the servicefoundry server                                      | `""`                                                    |
| `servicefoundryServer.podAnnotations`                              | Annotations for the servicefoundry server pods                                        | `{}`                                                    |
| `servicefoundryServer.podSecurityContext`                          | Security context for the servicefoundry server pods                                   | `{}`                                                    |
| `servicefoundryServer.commonLabels`                                | Common labels for the servicefoundry server pods                                      | `{}`                                                    |
| `servicefoundryServer.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the servicefoundry server                               | `true`                                                  |
| `servicefoundryServer.resources`                                   | Resource requests and limits for the servicefoundry server                            | `{}`                                                    |
| `servicefoundryServer.livenessProbe.failureThreshold`              | Liveness probe failure threshold for servicefoundry server                            | `3`                                                     |
| `servicefoundryServer.livenessProbe.initialDelaySeconds`           | Liveness probe initial delay for servicefoundry server                                | `600`                                                   |
| `servicefoundryServer.livenessProbe.periodSeconds`                 | Liveness probe period for servicefoundry server                                       | `10`                                                    |
| `servicefoundryServer.livenessProbe.successThreshold`              | Liveness probe success threshold for servicefoundry server                            | `1`                                                     |
| `servicefoundryServer.livenessProbe.timeoutSeconds`                | Liveness probe timeout for servicefoundry server                                      | `1`                                                     |
| `servicefoundryServer.readinessProbe.failureThreshold`             | Readiness probe failure threshold for servicefoundry server                           | `3`                                                     |
| `servicefoundryServer.readinessProbe.initialDelaySeconds`          | Readiness probe initial delay for servicefoundry server                               | `30`                                                    |
| `servicefoundryServer.readinessProbe.periodSeconds`                | Readiness probe period for servicefoundry server                                      | `10`                                                    |
| `servicefoundryServer.readinessProbe.successThreshold`             | Readiness probe success threshold for servicefoundry server                           | `1`                                                     |
| `servicefoundryServer.readinessProbe.timeoutSeconds`               | Readiness probe timeout for servicefoundry server                                     | `1`                                                     |
| `servicefoundryServer.nodeSelector`                                | Node selector for the servicefoundry server                                           | `{}`                                                    |
| `servicefoundryServer.affinity`                                    | Affinity settings for the servicefoundry server                                       | `{}`                                                    |
| `servicefoundryServer.topologySpreadConstraints`                   | Topology spread constraints for the servicefoundry server                             | `{}`                                                    |
| `servicefoundryServer.service.type`                                | Service type for the servicefoundry server                                            | `ClusterIP`                                             |
| `servicefoundryServer.service.port`                                | Service port for the servicefoundry server                                            | `3000`                                                  |
| `servicefoundryServer.service.annotations`                         | Annotations for the servicefoundry server service                                     | `{}`                                                    |
| `servicefoundryServer.serviceAccount.create`                       | Bool to create a service account for the servicefoundry server                        | `false`                                                 |
| `servicefoundryServer.serviceAccount.name`                         | Name of the servicefoundry server service account                                     | `""`                                                    |
| `servicefoundryServer.serviceAccount.annotations`                  | Annotations for the servicefoundry server service account                             | `{}`                                                    |
| `servicefoundryServer.serviceAccount.automountServiceAccountToken` | Automount service account token for the servicefoundry server                         | `true`                                                  |
| `servicefoundryServer.extraVolumes`                                | Extra volumes for the servicefoundry server                                           | `[]`                                                    |
| `servicefoundryServer.extraVolumeMounts`                           | Extra volume mounts for the servicefoundry server                                     | `[]`                                                    |
| `servicefoundryServer.imagePullSecrets`                            | Image pull credentials for servicefoundry server                                      | `[]`                                                    |
| `servicefoundryServer.rbac.enabled`                                | Enable RBAC for the servicefoundry server                                             | `true`                                                  |
| `servicefoundryServer.serviceMonitor.enabled`                      | Enable ServiceMonitor for the servicefoundry server                                   | `true`                                                  |
| `servicefoundryServer.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                              | `{}`                                                    |
| `servicefoundryServer.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                         | `{}`                                                    |
| `servicefoundryServer.env`                                         | Environment variables for the servicefoundry server                                   | `{}`                                                    |
| `servicefoundryServer.configs.cicdTemplates`                       | CICD Template for servicefoundry server                                               | `{{ .Release.Name }}-cicd-templates-cm`                 |
| `servicefoundryServer.configs.workbenchImages`                     | Workbench Images for workbench deployments                                            | `{{ .Release.Name }}-workbench-images-cm`               |
| `servicefoundryServer.configs.imageMutationPolicy`                 | Image Mutations policy for workloads                                                  | `{{ .Release.Name }}-image-mutation-policy-cm`          |
| `servicefoundryServer.configs.k8sManifestValidationPolicy`         | K8s Manifest Validation policy for workloads                                          | `{{ .Release.Name }}-k8s-manifest-validation-policy-cm` |

### sparkHistoryServer Truefoundry spark history server values

| Name                                                    | Description                                                                          | Value                                     |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------------------------------- |
| `sparkHistoryServer.enabled`                            | Bool to enable the spark history server                                              | `false`                                   |
| `sparkHistoryServer.tolerations`                        | Tolerations specific to the spark history server                                     | `[]`                                      |
| `sparkHistoryServer.annotations`                        | Annotations for the spark history server                                             | `{}`                                      |
| `sparkHistoryServer.image.registry`                     | Registry for the spark history server image (overrides global.registry if specified) | `""`                                      |
| `sparkHistoryServer.image.repository`                   | Image repository for the spark history server (without registry)                     | `tfy-private-images/spark-history-server` |
| `sparkHistoryServer.image.tag`                          | Image tag for the spark history server                                               | `v0.76.0`                                 |
| `sparkHistoryServer.environmentName`                    | Environment name for the spark history server                                        | `default`                                 |
| `sparkHistoryServer.envSecretName`                      | Secret name for the spark history server environment variables                       | `spark-history-server-env-secret`         |
| `sparkHistoryServer.imagePullPolicy`                    | Image pull policy for the spark history server                                       | `IfNotPresent`                            |
| `sparkHistoryServer.nameOverride`                       | Override name for the spark history server                                           | `""`                                      |
| `sparkHistoryServer.fullnameOverride`                   | Full name override for the spark history server                                      | `""`                                      |
| `sparkHistoryServer.podAnnotations`                     | Annotations for the spark history server pods                                        | `{}`                                      |
| `sparkHistoryServer.podSecurityContext`                 | Security context for the spark history server pods                                   | `{}`                                      |
| `sparkHistoryServer.commonLabels`                       | Common labels for the spark history server pods                                      | `{}`                                      |
| `sparkHistoryServer.securityContext`                    | Security context for the spark history server                                        | `{}`                                      |
| `sparkHistoryServer.livenessProbe.failureThreshold`     | Liveness probe failure threshold for spark history server                            | `3`                                       |
| `sparkHistoryServer.livenessProbe.initialDelaySeconds`  | Liveness probe initial delay for spark history server                                | `20`                                      |
| `sparkHistoryServer.livenessProbe.periodSeconds`        | Liveness probe period for spark history server                                       | `10`                                      |
| `sparkHistoryServer.livenessProbe.successThreshold`     | Liveness probe success threshold for spark history server                            | `1`                                       |
| `sparkHistoryServer.livenessProbe.timeoutSeconds`       | Liveness probe timeout for spark history server                                      | `1`                                       |
| `sparkHistoryServer.readinessProbe.failureThreshold`    | Readiness probe failure threshold for spark history server                           | `3`                                       |
| `sparkHistoryServer.readinessProbe.initialDelaySeconds` | Readiness probe initial delay for spark history server                               | `10`                                      |
| `sparkHistoryServer.readinessProbe.periodSeconds`       | Readiness probe period for spark history server                                      | `10`                                      |
| `sparkHistoryServer.readinessProbe.successThreshold`    | Readiness probe success threshold for spark history server                           | `1`                                       |
| `sparkHistoryServer.readinessProbe.timeoutSeconds`      | Readiness probe timeout for spark history server                                     | `1`                                       |
| `sparkHistoryServer.nodeSelector`                       | Node selector for the spark history server                                           | `{}`                                      |
| `sparkHistoryServer.affinity`                           | Affinity settings for the spark history server                                       | `{}`                                      |
| `sparkHistoryServer.topologySpreadConstraints`          | Topology spread constraints for the spark history server                             | `{}`                                      |
| `sparkHistoryServer.service.type`                       | Service type for the spark history server                                            | `ClusterIP`                               |
| `sparkHistoryServer.service.port`                       | Service port for the spark history server                                            | `18080`                                   |
| `sparkHistoryServer.service.annotations`                | Annotations for the spark history server service                                     | `{}`                                      |
| `sparkHistoryServer.serviceAccount.create`              | Bool to create the spark history server service account                              | `false`                                   |
| `sparkHistoryServer.serviceAccount.name`                | Name of the spark history server service account                                     | `""`                                      |
| `sparkHistoryServer.serviceAccount.annotations`         | Annotations for the spark history server service account                             | `{}`                                      |
| `sparkHistoryServer.extraVolumes`                       | Extra volumes for the spark history server                                           | `[]`                                      |
| `sparkHistoryServer.extraVolumeMounts`                  | Extra volume mounts for the spark history server                                     | `[]`                                      |
| `sparkHistoryServer.imagePullSecrets`                   | Image pull credentials for spark history server                                      | `[]`                                      |
| `sparkHistoryServer.rbac.enabled`                       | Enable RBAC for the spark history server                                             | `true`                                    |
| `sparkHistoryServer.env`                                | Environment variables for the spark history server                                   | `{}`                                      |

### tfyK8sController Truefoundry tfy k8s controller values

| Name                                                           | Description                                                                      | Value                                   |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------- |
| `tfyK8sController.enabled`                                     | Bool to enable the tfyK8sController                                              | `true`                                  |
| `tfyK8sController.tolerations`                                 | Tolerations specific to the tfyK8sController                                     | `[]`                                    |
| `tfyK8sController.annotations`                                 | Annotations for the tfyK8sController                                             | `{}`                                    |
| `tfyK8sController.image.registry`                              | Registry for the tfyK8sController image (overrides global.registry if specified) | `""`                                    |
| `tfyK8sController.image.repository`                            | Image repository for the tfyK8sController (without registry)                     | `tfy-private-images/tfy-k8s-controller` |
| `tfyK8sController.image.tag`                                   | Image tag for the tfyK8sController                                               | `v0.80.0`                               |
| `tfyK8sController.environmentName`                             | Environment name for tfyK8sController                                            | `default`                               |
| `tfyK8sController.envSecretName`                               | Secret name for the tfyK8sController environment variables                       | `tfy-k8s-controller-env-secret`         |
| `tfyK8sController.imagePullPolicy`                             | Image pull policy for the tfyK8sController                                       | `IfNotPresent`                          |
| `tfyK8sController.nameOverride`                                | Override name for the tfyK8sController                                           | `""`                                    |
| `tfyK8sController.fullnameOverride`                            | Full name override for the tfyK8sController                                      | `""`                                    |
| `tfyK8sController.podAnnotations`                              | Annotations for the tfyK8sController pods                                        | `{}`                                    |
| `tfyK8sController.podSecurityContext`                          | Security context for the tfyK8sController pods                                   | `{}`                                    |
| `tfyK8sController.commonLabels`                                | Common labels for the tfyK8sController pods                                      | `{}`                                    |
| `tfyK8sController.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the tfyK8sController                               | `true`                                  |
| `tfyK8sController.resources`                                   | Resource requests and limits for the tfyK8sController                            | `{}`                                    |
| `tfyK8sController.livenessProbe.failureThreshold`              | Liveness probe failure threshold for tfyK8sController                            | `3`                                     |
| `tfyK8sController.livenessProbe.initialDelaySeconds`           | Liveness probe initial delay for tfyK8sController                                | `600`                                   |
| `tfyK8sController.livenessProbe.periodSeconds`                 | Liveness probe period for tfyK8sController                                       | `10`                                    |
| `tfyK8sController.livenessProbe.successThreshold`              | Liveness probe success threshold for tfyK8sController                            | `1`                                     |
| `tfyK8sController.livenessProbe.timeoutSeconds`                | Liveness probe timeout for tfyK8sController                                      | `1`                                     |
| `tfyK8sController.readinessProbe.failureThreshold`             | Readiness probe failure threshold for tfyK8sController                           | `3`                                     |
| `tfyK8sController.readinessProbe.initialDelaySeconds`          | Readiness probe initial delay for tfyK8sController                               | `30`                                    |
| `tfyK8sController.readinessProbe.periodSeconds`                | Readiness probe period for tfyK8sController                                      | `10`                                    |
| `tfyK8sController.readinessProbe.successThreshold`             | Readiness probe success threshold for tfyK8sController                           | `1`                                     |
| `tfyK8sController.readinessProbe.timeoutSeconds`               | Readiness probe timeout for tfyK8sController                                     | `1`                                     |
| `tfyK8sController.nodeSelector`                                | Node selector for the tfyK8sController                                           | `{}`                                    |
| `tfyK8sController.affinity`                                    | Affinity settings for the tfyK8sController                                       | `{}`                                    |
| `tfyK8sController.topologySpreadConstraints`                   | Topology spread constraints for the tfyK8sController                             | `{}`                                    |
| `tfyK8sController.service.type`                                | Service type for the tfyK8sController                                            | `ClusterIP`                             |
| `tfyK8sController.service.port`                                | Service port for the tfyK8sController                                            | `3002`                                  |
| `tfyK8sController.service.annotations`                         | Annotations for the tfyK8sController service                                     | `{}`                                    |
| `tfyK8sController.serviceAccount.annotations`                  | Annotations for the tfyK8sController service account                             | `{}`                                    |
| `tfyK8sController.serviceAccount.automountServiceAccountToken` | Automount service account token for the tfyK8sController service account         | `true`                                  |
| `tfyK8sController.extraVolumes`                                | Extra volumes for the tfyK8sController                                           | `[]`                                    |
| `tfyK8sController.extraVolumeMounts`                           | Extra volume mounts for the tfyK8sController                                     | `[]`                                    |
| `tfyK8sController.serviceMonitor.enabled`                      | Enable ServiceMonitor for the tfyK8sController                                   | `true`                                  |
| `tfyK8sController.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                         | `{}`                                    |
| `tfyK8sController.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                    | `{}`                                    |
| `tfyK8sController.imagePullSecrets`                            | Image pull secrets for the tfyK8sController                                      | `[]`                                    |
| `tfyK8sController.env`                                         | Environment variables for the tfyK8sController                                   | `{}`                                    |

### sfyManifestService Truefoundry sfy manifest service values

| Name                                                             | Description                                                                          | Value                                     |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------------------------------- |
| `sfyManifestService.enabled`                                     | Bool to enable the sfy manifest service                                              | `true`                                    |
| `sfyManifestService.annotations`                                 | Annotations for the sfy manifest service                                             | `{}`                                      |
| `sfyManifestService.tolerations`                                 | Tolerations specific to the sfy manifest service                                     | `[]`                                      |
| `sfyManifestService.image.registry`                              | Registry for the sfy manifest service image (overrides global.registry if specified) | `""`                                      |
| `sfyManifestService.image.repository`                            | Image repository for the sfy manifest service (without registry)                     | `tfy-private-images/sfy-manifest-service` |
| `sfyManifestService.image.tag`                                   | Image tag for the sfy manifest service                                               | `v0.79.0`                                 |
| `sfyManifestService.environmentName`                             | Environment name for the sfy manifest service                                        | `default`                                 |
| `sfyManifestService.envSecretName`                               | Secret name for the sfy manifest service environment variables                       | `sfy-manifest-service-env-secret`         |
| `sfyManifestService.imagePullPolicy`                             | Image pull policy for the sfy manifest service                                       | `IfNotPresent`                            |
| `sfyManifestService.nameOverride`                                | Override name for the sfy manifest service                                           | `""`                                      |
| `sfyManifestService.fullnameOverride`                            | Full name override for the sfy manifest service                                      | `""`                                      |
| `sfyManifestService.podAnnotations`                              | Annotations for the sfy manifest service pods                                        | `{}`                                      |
| `sfyManifestService.podSecurityContext`                          | Security context for the sfy manifest service pods                                   | `{}`                                      |
| `sfyManifestService.commonLabels`                                | Common labels for the sfy manifest service pods                                      | `{}`                                      |
| `sfyManifestService.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the sfy manifest service                               | `false`                                   |
| `sfyManifestService.resources`                                   | Resource requests and limits for the sfy manifest service                            | `{}`                                      |
| `sfyManifestService.livenessProbe.failureThreshold`              | Liveness probe failure threshold for sfy manifest service                            | `3`                                       |
| `sfyManifestService.livenessProbe.initialDelaySeconds`           | Liveness probe initial delay for sfy manifest service                                | `600`                                     |
| `sfyManifestService.livenessProbe.periodSeconds`                 | Liveness probe period for sfy manifest service                                       | `10`                                      |
| `sfyManifestService.livenessProbe.successThreshold`              | Liveness probe success threshold for sfy manifest service                            | `1`                                       |
| `sfyManifestService.livenessProbe.timeoutSeconds`                | Liveness probe timeout for sfy manifest service                                      | `1`                                       |
| `sfyManifestService.readinessProbe.failureThreshold`             | Readiness probe failure threshold for sfy manifest service                           | `3`                                       |
| `sfyManifestService.readinessProbe.initialDelaySeconds`          | Readiness probe initial delay for sfy manifest service                               | `30`                                      |
| `sfyManifestService.readinessProbe.periodSeconds`                | Readiness probe period for sfy manifest service                                      | `10`                                      |
| `sfyManifestService.readinessProbe.successThreshold`             | Readiness probe success threshold for sfy manifest service                           | `1`                                       |
| `sfyManifestService.readinessProbe.timeoutSeconds`               | Readiness probe timeout for sfy manifest service                                     | `1`                                       |
| `sfyManifestService.nodeSelector`                                | Node selector for the sfy manifest service                                           | `{}`                                      |
| `sfyManifestService.affinity`                                    | Affinity settings for the sfy manifest service                                       | `{}`                                      |
| `sfyManifestService.topologySpreadConstraints`                   | Topology spread constraints for the sfy manifest service                             | `{}`                                      |
| `sfyManifestService.serviceMonitor.enabled`                      | Enable ServiceMonitor for the sfy manifest service                                   | `true`                                    |
| `sfyManifestService.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                             | `{}`                                      |
| `sfyManifestService.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                        | `{}`                                      |
| `sfyManifestService.service.type`                                | Service type for the sfy manifest service                                            | `ClusterIP`                               |
| `sfyManifestService.service.port`                                | Service port for the sfy manifest service                                            | `8080`                                    |
| `sfyManifestService.service.annotations`                         | Annotations for the sfy manifest service                                             | `{}`                                      |
| `sfyManifestService.serviceAccount.annotations`                  | Annotations for the sfy manifest service service account                             | `{}`                                      |
| `sfyManifestService.serviceAccount.automountServiceAccountToken` | Automount service account token for the sfy manifest service                         | `true`                                    |
| `sfyManifestService.extraVolumes`                                | Extra volumes for the sfy manifest service                                           | `[]`                                      |
| `sfyManifestService.extraVolumeMounts`                           | Extra volume mounts for the sfy manifest service                                     | `[]`                                      |
| `sfyManifestService.imagePullSecrets`                            | Image pull credentials for the sfy manifest service                                  | `[]`                                      |
| `sfyManifestService.env`                                         | Environment variables for the sfy manifest service                                   | `{}`                                      |

### tfyBuild Truefoundry tfy build settings

| Name                                                                            | Description                                                                               | Value                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tfyBuild.enabled`                                                              | Bool to enable the tfyBuild server                                                        | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.annotations`                                                          | Annotations for the tfyBuild server                                                       | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.labels`                                                               | Labels for the tfyBuild server                                                            | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.nameOverride`                                                         | Override name for the tfyBuild server                                                     | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.fullnameOverride`                                                     | Full name override for the tfyBuild server                                                | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.serviceAccount.create`                                                | Bool to create a service account for the tfyBuild server                                  | `false`                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `tfyBuild.serviceAccount.name`                                                  | Name of the tfyBuild server service account                                               | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.serviceAccount.annotations`                                           | Annotations for the tfyBuild server service account                                       | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.serviceAccount.automountServiceAccountToken`                          | Automount service account token for the tfyBuild server                                   | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.preemptibleDeployment.enabled`                                        | Bool to enable preemptible deployment for the tfyBuild server                             | `false`                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `tfyBuild.preemptibleDeployment.imagePullSecrets`                               | Image pull secrets for the preemptible deployment                                         | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.affinity`                                       | Affinity settings for the preemptible deployment                                          | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.nodeSelector`                                   | Node selector for the preemptible deployment                                              | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.tolerations`                                    | Tolerations for the preemptible deployment                                                | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.extraEnvs`                                      | Extra environment variables for the tfyBuild server                                       | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.extraVolumeMounts`                              | Extra volume mounts for the tfyBuild server                                               | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.preemptibleDeployment.extraVolumes`                                   | Extra volumes for the tfyBuild server                                                     | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.extraEnvs`                            | Extra environment variables for sfyBuilder                                                | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.image.registry`                       | Registry for the sfyBuilder image (overrides global.registry if specified)                | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.image.repository`                     | Repository for the sfyBuilder (without registry)                                          | `tfy-images/sfy-builder`                                                                                                                                                                                                                                                                                                                                                                                                         |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.image.tag`                            | Tag for the sfyBuilder                                                                    | `v0.8.17`                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.imagePullSecrets`                     | Image pull secrets for the sfyBuilder                                                     | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.baseImagePullSecret`                  | baseImagePullSecret for the docker config                                                 | `truefoundry-image-pull-secret`                                                                                                                                                                                                                                                                                                                                                                                                  |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.script`                               | script for the sfyBuilder to be executed                                                  | `# Code will be downloaded in the directory set by the SOURCE_CODE_DOWNLOAD_PATH environment variable
download-code.sh
registry-login.sh
wait-for-builder.sh
build-and-push.sh

# This script will be executed only when all the above scripts are successfully executed. If any of the above scripts fail, this script will not be executed, and the build will be marked as failed.
update-build.sh '{"status":"SUCCEEDED"}'
` |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.limits.cpu`                 | CPU limit for the sfyBuilder                                                              | `1`                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.limits.ephemeral-storage`   | Ephemeral storage limit for the sfyBuilder                                                | `20Gi`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.limits.memory`              | Memory limit for the sfyBuilder                                                           | `2Gi`                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.requests.cpu`               | CPU request for the sfyBuilder                                                            | `200m`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.requests.ephemeral-storage` | Ephemeral storage request for the sfyBuilder                                              | `10Gi`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.resources.requests.memory`            | Memory request for the sfyBuilder                                                         | `500Mi`                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `tfyBuild.truefoundryWorkflows.sfyBuilder.buildSecrets`                         | Build secrets for the sfyBuilder                                                          | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.extraEnvs`                                       | Extra environment variables for the tfyBuild server                                       | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.extraVolumeMounts`                               | Extra volume mounts for the tfyBuild server                                               | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.extraVolumes`                                    | Extra volumes for the tfyBuild server                                                     | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.affinity`                                        | Affinity settings for the tfyBuild server                                                 | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.nodeSelector`                                    | Node selector for the tfyBuild server                                                     | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.logMarkers.error`                                | Error log marker for the tfyBuild server                                                  | `\033[31m[Error]\033[0m`                                                                                                                                                                                                                                                                                                                                                                                                         |
| `tfyBuild.truefoundryWorkflows.logMarkers.done`                                 | Done log marker for the tfyBuild server                                                   | `\033[32m[Done]\033[0m`                                                                                                                                                                                                                                                                                                                                                                                                          |
| `tfyBuild.truefoundryWorkflows.logMarkers.start`                                | Start log marker for the tfyBuild server                                                  | `\033[36m[Start]\033[0m`                                                                                                                                                                                                                                                                                                                                                                                                         |
| `tfyBuild.truefoundryWorkflows.logMarkers.clientPrefix`                         | Client prefix for the tfyBuild server                                                     | `["TFY-CLIENT"]`                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `tfyBuild.truefoundryWorkflows.logMarkers.supportSlack`                         | Slack support URL for the tfyBuild server                                                 | `https://join.slack.com/t/truefoundry/shared_invite/zt-11ht512jq-nDJq~HJMqc6wBw90JVlo7g`                                                                                                                                                                                                                                                                                                                                         |
| `tfyBuild.truefoundryWorkflows.logMarkers.serviceFoundryUiUrl`                  | Service foundry UI URL                                                                    | `https://app.truefoundry.com/workspace`                                                                                                                                                                                                                                                                                                                                                                                          |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.enabled`                   | Bool to enable SOCI index build and push                                                  | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.image.registry`            | Registry for the SOCI index build and push image (overrides global.registry if specified) | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.image.repository`          | Repository for the SOCI index build and push (without registry)                           | `tfy-images/sfy-builder`                                                                                                                                                                                                                                                                                                                                                                                                         |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.image.tag`                 | Tag for the SOCI index build and push                                                     | `v0.8.17`                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.imagePullSecrets`          | Image pull secrets for the sociIndexBuildAndPush                                          | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.imageSizeThresholdBytes`   | Image size threshold for the SOCI index build and push                                    | `419430400`                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.extraEnvs`                 | Extra environment variables for the SOCI index build and push                             | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.extraVolumeMounts`         | Extra volume mounts for the SOCI index build and push                                     | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfyBuild.truefoundryWorkflows.sociIndexBuildAndPush.extraVolumes`              |                                                                                           | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfy-buildkitd-service.enabled`                                                 | Bool to enable the tfy-buildkitd service                                                  | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfy-buildkitd-service.serviceAccount.automountServiceAccountToken`             | Automount service account token for the tfy-buildkitd service                             | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfy-buildkitd-service.service.port`                                            | port number for the tfy-buildkitd service                                                 | `1234`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfy-buildkitd-service.image.registry`                                          | Registry for the tfy-buildkitd-service image (overrides global.registry if specified)     | `""`                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tfy-buildkitd-service.image.repository`                                        | tfyBuildkitdService repository (without registry)                                         | `tfy-mirror/moby/buildkit`                                                                                                                                                                                                                                                                                                                                                                                                       |
| `tfy-buildkitd-service.replicaCount`                                            | Number of replicas Value kept for future use, kept 1                                      | `1`                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `tfy-buildkitd-service.tls.enabled`                                             | Enable TLS for the tfy-buildkitd service                                                  | `true`                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `tfy-buildkitd-service.tls.buildkitClientCertsSecretName`                       | Name of the secret containing the TLS certificate                                         | `tfy-buildkit-client-certs`                                                                                                                                                                                                                                                                                                                                                                                                      |
| `postgresql.auth.existingSecret`                                                | Name of the existing secret for PostgreSQL authentication                                 | `truefoundry-creds`                                                                                                                                                                                                                                                                                                                                                                                                              |
| `postgresql.auth.database`                                                      | Name of the database for PostgreSQL                                                       | `truefoundry`                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `postgresql.image.registry`                                                     | Registry for the PostgreSQL image (overrides global.registry if specified)                | `tfy.jfrog.io`                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `postgresql.image.repository`                                                   | Repository for the PostgreSQL image (without registry)                                    | `tfy-mirror/bitnami/postgresql`                                                                                                                                                                                                                                                                                                                                                                                                  |
| `postgresql.image.tag`                                                          |                                                                                           | `16.6.0-debian-12-r2`                                                                                                                                                                                                                                                                                                                                                                                                            |

### tfyController Truefoundry tfy controller settings

| Name                                                        | Description                                                                   | Value                               |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------- |
| `tfyController.enabled`                                     | Bool to enable the tfyController                                              | `true`                              |
| `tfyController.annotations`                                 | Annotations for the tfyController                                             | `{}`                                |
| `tfyController.image.registry`                              | Registry for the tfyController image (overrides global.registry if specified) | `""`                                |
| `tfyController.image.repository`                            | Image repository for the tfyController (without registry)                     | `tfy-private-images/tfy-controller` |
| `tfyController.image.tag`                                   | Image tag for the tfyController                                               | `v0.79.0`                           |
| `tfyController.environmentName`                             | Environment name for the tfyController                                        | `default`                           |
| `tfyController.envSecretName`                               | Secret name for the tfyController environment variables                       | `sfy-manifest-service-env-secret`   |
| `tfyController.imagePullPolicy`                             | Image pull policy for the tfyController                                       | `IfNotPresent`                      |
| `tfyController.nameOverride`                                | Override name for the tfyController                                           | `""`                                |
| `tfyController.fullnameOverride`                            | Full name override for the tfyController                                      | `""`                                |
| `tfyController.podAnnotations`                              | Annotations for the tfyController pods                                        | `{}`                                |
| `tfyController.podSecurityContext`                          | Security context for the tfyController pods                                   | `{}`                                |
| `tfyController.commonLabels`                                | Common labels for the tfyController pods                                      | `{}`                                |
| `tfyController.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the tfyController                               | `true`                              |
| `tfyController.imagePullSecrets`                            | Image pull secrets for the tfycontroller                                      | `[]`                                |
| `tfyController.serviceMonitor.enabled`                      | Enable ServiceMonitor for the tfyController                                   | `true`                              |
| `tfyController.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                      | `{}`                                |
| `tfyController.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                 | `{}`                                |
| `tfyController.resources`                                   | Resource requests and limits for the tfyController                            | `{}`                                |
| `tfyController.livenessProbe.failureThreshold`              | Liveness probe failure threshold for tfyController                            | `3`                                 |
| `tfyController.livenessProbe.initialDelaySeconds`           | Liveness probe initial delay for tfyController                                | `600`                               |
| `tfyController.livenessProbe.periodSeconds`                 | Liveness probe period for the tfyController                                   | `10`                                |
| `tfyController.livenessProbe.successThreshold`              | Liveness probe success threshold for tfyController                            | `1`                                 |
| `tfyController.livenessProbe.timeoutSeconds`                | Liveness probe timeout for tfyController                                      | `1`                                 |
| `tfyController.readinessProbe.failureThreshold`             | Readiness probe failure threshold for tfyController                           | `3`                                 |
| `tfyController.readinessProbe.initialDelaySeconds`          | Readiness probe initial delay for tfyController                               | `30`                                |
| `tfyController.readinessProbe.periodSeconds`                | Readiness probe period for tfyController                                      | `10`                                |
| `tfyController.readinessProbe.successThreshold`             | Readiness probe success threshold for tfyController                           | `1`                                 |
| `tfyController.readinessProbe.timeoutSeconds`               | Readiness probe timeout for tfyController                                     | `1`                                 |
| `tfyController.nodeSelector`                                | Node selector for the tfyController                                           | `{}`                                |
| `tfyController.affinity`                                    | Affinity settings for the tfyController                                       | `{}`                                |
| `tfyController.topologySpreadConstraints`                   | Topology spread constraints for the tfyController                             | `{}`                                |
| `tfyController.service.type`                                | Service type for the tfyController                                            | `ClusterIP`                         |
| `tfyController.service.port`                                | Service port for the tfyController                                            | `8123`                              |
| `tfyController.service.annotations`                         | Annotations for the tfyController service                                     | `{}`                                |
| `tfyController.serviceAccount.annotations`                  | Annotations for the tfyController service account                             | `{}`                                |
| `tfyController.serviceAccount.automountServiceAccountToken` | Automount service account token for the tfyController service account         | `true`                              |
| `tfyController.env`                                         | Environment variables for the tfyController                                   | `{}`                                |

### tfyWorkflowAdmin Truefoundry tfy workflow admin settings

| Name                                                  | Description                                                                      | Value                                   |
| ----------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------- |
| `tfyWorkflowAdmin.enabled`                            | Bool to enable the tfyWorkflowAdmin                                              | `false`                                 |
| `tfyWorkflowAdmin.annotations`                        | Annotations for the tfyWorkflowAdmin                                             | `{}`                                    |
| `tfyWorkflowAdmin.image.registry`                     | Registry for the tfyWorkflowAdmin image (overrides global.registry if specified) | `""`                                    |
| `tfyWorkflowAdmin.image.repository`                   | Image repository for the tfyWorkflowAdmin (without registry)                     | `tfy-private-images/tfy-workflow-admin` |
| `tfyWorkflowAdmin.image.tag`                          | Image tag for the tfyWorkflowAdmin                                               | `v0.80.0`                               |
| `tfyWorkflowAdmin.environmentName`                    | Environment name for the tfyWorkflowAdmin                                        | `default`                               |
| `tfyWorkflowAdmin.envSecretName`                      | Secret name for the tfyWorkflowAdmin environment variables                       | `tfy-workflow-admin-env-secret`         |
| `tfyWorkflowAdmin.imagePullPolicy`                    | Image pull policy for the tfyWorkflowAdmin                                       | `IfNotPresent`                          |
| `tfyWorkflowAdmin.nameOverride`                       | Override name for the tfyWorkflowAdmin                                           | `""`                                    |
| `tfyWorkflowAdmin.fullnameOverride`                   | Full name override for the tfyWorkflowAdmin                                      | `""`                                    |
| `tfyWorkflowAdmin.podAnnotations`                     | Annotations for the tfyWorkflowAdmin pods                                        | `{}`                                    |
| `tfyWorkflowAdmin.podSecurityContext`                 | Security context for the tfyWorkflowAdmin pods                                   | `{}`                                    |
| `tfyWorkflowAdmin.commonLabels`                       | Common labels for the tfyWorkflowAdmin pods                                      | `{}`                                    |
| `tfyWorkflowAdmin.securityContext`                    | Security context for the tfyWorkflowAdmin                                        | `{}`                                    |
| `tfyWorkflowAdmin.imagePullSecrets`                   | Image pull secrets for the tfycontroller                                         | `[]`                                    |
| `tfyWorkflowAdmin.resources`                          | Resource requests and limits for the tfyWorkflowAdmin                            | `{}`                                    |
| `tfyWorkflowAdmin.livenessProbe.failureThreshold`     | Liveness probe failure threshold for tfyWorkflowAdmin                            | `3`                                     |
| `tfyWorkflowAdmin.livenessProbe.initialDelaySeconds`  | Liveness probe initial delay for tfyWorkflowAdmin                                | `600`                                   |
| `tfyWorkflowAdmin.livenessProbe.periodSeconds`        | Liveness probe period for the tfyWorkflowAdmin                                   | `10`                                    |
| `tfyWorkflowAdmin.livenessProbe.successThreshold`     | Liveness probe success threshold for tfyWorkflowAdmin                            | `1`                                     |
| `tfyWorkflowAdmin.livenessProbe.timeoutSeconds`       | Liveness probe timeout for tfyWorkflowAdmin                                      | `1`                                     |
| `tfyWorkflowAdmin.readinessProbe.failureThreshold`    | Readiness probe failure threshold for tfyWorkflowAdmin                           | `3`                                     |
| `tfyWorkflowAdmin.readinessProbe.initialDelaySeconds` | Readiness probe initial delay for tfyWorkflowAdmin                               | `30`                                    |
| `tfyWorkflowAdmin.readinessProbe.periodSeconds`       | Readiness probe period for the tfyWorkflowAdmin                                  | `10`                                    |
| `tfyWorkflowAdmin.readinessProbe.successThreshold`    | Readiness probe success threshold for tfyWorkflowAdmin                           | `1`                                     |
| `tfyWorkflowAdmin.readinessProbe.timeoutSeconds`      | Readiness probe timeout for tfyWorkflowAdmin                                     | `1`                                     |
| `tfyWorkflowAdmin.nodeSelector`                       | Node selector for the tfyWorkflowAdmin                                           | `{}`                                    |
| `tfyWorkflowAdmin.affinity`                           | Affinity settings for the tfyWorkflowAdmin                                       | `{}`                                    |
| `tfyWorkflowAdmin.topologySpreadConstraints`          | Topology spread constraints for the tfyWorkflowAdmin                             | `{}`                                    |
| `tfyWorkflowAdmin.service.type`                       | Service type for the tfyWorkflowAdmin                                            | `ClusterIP`                             |
| `tfyWorkflowAdmin.service.port`                       | Service port for the tfyWorkflowAdmin                                            | `8089`                                  |
| `tfyWorkflowAdmin.service.annotations`                | Annotations for the tfyWorkflowAdmin service                                     | `{}`                                    |
| `tfyWorkflowAdmin.serviceAccount.create`              | Bool to create a service account for the tfyWorkflowAdmin                        | `false`                                 |
| `tfyWorkflowAdmin.serviceAccount.name`                | Name of the tfyWorkflowAdmin service account                                     | `""`                                    |
| `tfyWorkflowAdmin.serviceAccount.annotations`         | Annotations for the tfyWorkflowAdmin service account                             | `{}`                                    |
| `tfyWorkflowAdmin.storage`                            | Storage settings for the tfyWorkflowAdmin                                        | `{}`                                    |
| `tfyWorkflowAdmin.env`                                | Environment variables for the tfyWorkflowAdmin                                   | `{}`                                    |

### tfyNats Truefoundry NATS settings

| Name                                             | Description                                                                  | Value                                           |
| ------------------------------------------------ | ---------------------------------------------------------------------------- | ----------------------------------------------- |
| `tfyNats.nameOverride`                           | Override name for NATS server                                                | `tfy-nats`                                      |
| `tfyNats.enabled`                                | Bool to enable the NATS server                                               | `true`                                          |
| `tfyNats.config.cluster.enabled`                 | Bool to enable clustering                                                    | `true`                                          |
| `tfyNats.config.cluster.replicas`                | Number of replicas in cluster                                                | `3`                                             |
| `tfyNats.config.advertise`                       | Bool to enable NATS server advertise                                         | `false`                                         |
| `tfyNats.config.jetstream.enabled`               | Bool to enable Jetstream                                                     | `true`                                          |
| `tfyNats.config.jetstream.fileStore.dir`         | Storage directory path                                                       | `/data`                                         |
| `tfyNats.config.jetstream.fileStore.pvc.size`    | PVC storage size                                                             | `10Gi`                                          |
| `tfyNats.config.jetstream.fileStore.pvc.enabled` | Bool to enable PVC                                                           | `true`                                          |
| `tfyNats.config.jetstream.fileStore.enabled`     | Bool to enable file storage                                                  | `true`                                          |
| `tfyNats.config.jetstream.fileStore.maxSize`     | Maximum file storage size                                                    | `9Gi`                                           |
| `tfyNats.config.jetstream.memoryStore.size`      | Memory storage size                                                          | `1Gi`                                           |
| `tfyNats.config.jetstream.memoryStore.enabled`   | Bool to enable memory storage                                                | `true`                                          |
| `tfyNats.config.websocket.port`                  | Websocket port                                                               | `8080`                                          |
| `tfyNats.config.websocket.enabled`               | Bool to enable websocket                                                     | `true`                                          |
| `tfyNats.natsBox.enabled`                        | Bool to enable NATS Box                                                      | `false`                                         |
| `tfyNats.reloader.image.registry`                | Registry for the reloader image (overrides global.registry if specified)     | `""`                                            |
| `tfyNats.reloader.image.repository`              | Reloader image repository (without registry)                                 | `tfy-mirror/natsio/nats-server-config-reloader` |
| `tfyNats.reloader.image.tag`                     | Reloader image tag                                                           | `0.18.2`                                        |
| `tfyNats.reloader.enabled`                       | Bool to enable config reloader                                               | `true`                                          |
| `tfyNats.reloader.patch`                         | Nats Reloader patches                                                        | `[]`                                            |
| `tfyNats.promExporter.image.registry`            | Registry for the promExporter image (overrides global.registry if specified) | `""`                                            |
| `tfyNats.promExporter.image.repository`          | Exporter image repository (without registry)                                 | `tfy-mirror/natsio/prometheus-nats-exporter`    |
| `tfyNats.promExporter.image.tag`                 | Exporter image tag                                                           | `0.17.3`                                        |
| `tfyNats.promExporter.enabled`                   | Bool to enable Prometheus exporter                                           | `true`                                          |
| `tfyNats.promExporter.patch`                     | Nats Prom Exporter patches                                                   | `[]`                                            |
| `tfyNats.promExporter.podMonitor.enabled`        | Bool to enable pod monitor                                                   | `true`                                          |
| `tfyNats.promExporter.podMonitor.merge`          | Additional kustomize patches for the pod monitor                             | `{}`                                            |
| `tfyNats.container.image.registry`               | Registry for the container image (overrides global.registry if specified)    | `""`                                            |
| `tfyNats.container.image.tag`                    | Container image tag                                                          | `2.11.6-alpine`                                 |
| `tfyNats.container.image.repository`             | Container image repository (without registry)                                | `tfy-mirror/nats`                               |
| `tfyNats.serviceAccount.enabled`                 | Specifies whether a service account should be created                        | `true`                                          |
| `tfyNats.serviceAccount.annotations`             | Annotations to add to the service account                                    | `{}`                                            |
| `tfyNats.serviceAccount.name`                    | The name of the service account to use.                                      | `truefoundry-tfy-nats`                          |
| `tfyNats.serviceAccount.patch`                   | Service account patches                                                      | `[]`                                            |
| `tfy-llm-gateway.commonAnnotations`              | Annotations for the tfy-llm-gateway                                          | `{}`                                            |

### tfy-otel-collector TrueFoundry OpenTelemetry Collector settings


### deltaFusionIngestor Truefoundry DeltaFusion Ingestor settings

| Name                                                              | Description                                                                                | Value                                     |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------- |
| `deltaFusionIngestor.enabled`                                     | Bool to enable the DeltaFusion Ingestor                                                    | `false`                                   |
| `deltaFusionIngestor.image.registry`                              | Registry for the DeltaFusion Ingestor image (overrides global.image.registry if specified) | `""`                                      |
| `deltaFusionIngestor.image.repository`                            | Image repository for the DeltaFusion Ingestor (without registry)                           | `tfy-private-images/deltafusion-ingestor` |
| `deltaFusionIngestor.image.tag`                                   | Image tag for the DeltaFusion Ingestor                                                     | `v0.1.0`                                  |
| `deltaFusionIngestor.image.pullPolicy`                            | Image pull policy for the DeltaFusion Ingestor                                             | `IfNotPresent`                            |
| `deltaFusionIngestor.statefulsetLabels`                           | Labels to apply to the DeltaFusion Ingestor statefulset                                    | `{}`                                      |
| `deltaFusionIngestor.statefulsetAnnotations`                      | Annotations to apply to the DeltaFusion Ingestor statefulset                               | `{}`                                      |
| `deltaFusionIngestor.envSecretName`                               | Name of the secret containing environment variables for the DeltaFusion Ingestor           | `deltafusion-ingestor-service-env-secret` |
| `deltaFusionIngestor.healthcheck.readiness.path`                  | Readiness probe path                                                                       | `/health`                                 |
| `deltaFusionIngestor.healthcheck.readiness.initialDelaySeconds`   | Initial delay seconds                                                                      | `10`                                      |
| `deltaFusionIngestor.healthcheck.readiness.periodSeconds`         | Period seconds                                                                             | `5`                                       |
| `deltaFusionIngestor.healthcheck.readiness.timeoutSeconds`        | Timeout seconds                                                                            | `2`                                       |
| `deltaFusionIngestor.healthcheck.readiness.successThreshold`      | Success threshold                                                                          | `1`                                       |
| `deltaFusionIngestor.healthcheck.readiness.failureThreshold`      | Failure threshold                                                                          | `3`                                       |
| `deltaFusionIngestor.healthcheck.liveness.path`                   | Liveness probe path                                                                        | `/health`                                 |
| `deltaFusionIngestor.healthcheck.liveness.initialDelaySeconds`    | Initial delay seconds                                                                      | `10`                                      |
| `deltaFusionIngestor.healthcheck.liveness.periodSeconds`          | Period seconds                                                                             | `5`                                       |
| `deltaFusionIngestor.healthcheck.liveness.timeoutSeconds`         | Timeout seconds                                                                            | `2`                                       |
| `deltaFusionIngestor.healthcheck.liveness.successThreshold`       | Success threshold                                                                          | `1`                                       |
| `deltaFusionIngestor.healthcheck.liveness.failureThreshold`       | Failure threshold                                                                          | `3`                                       |
| `deltaFusionIngestor.storage.enabled`                             | Bool to enable storage                                                                     | `true`                                    |
| `deltaFusionIngestor.storage.accessModes`                         | Access modes                                                                               | `["ReadWriteOnce"]`                       |
| `deltaFusionIngestor.storage.storageClassName`                    | Storage class name                                                                         | `gp3`                                     |
| `deltaFusionIngestor.storage.size`                                | Storage size                                                                               | `5Gi`                                     |
| `deltaFusionIngestor.storage.mountPath`                           | Mount path                                                                                 | `/spans_dataset`                          |
| `deltaFusionIngestor.imagePullSecrets`                            | Image pull secrets                                                                         | `[]`                                      |
| `deltaFusionIngestor.imagePullPolicy`                             | Image pull policy override                                                                 | `IfNotPresent`                            |
| `deltaFusionIngestor.nameOverride`                                | Name override                                                                              | `""`                                      |
| `deltaFusionIngestor.fullnameOverride`                            | Full name override                                                                         | `""`                                      |
| `deltaFusionIngestor.podLabels`                                   | Pod-level labels                                                                           | `{}`                                      |
| `deltaFusionIngestor.podAnnotations`                              | Pod-level annotations                                                                      | `{}`                                      |
| `deltaFusionIngestor.securityContext.privileged`                  | Bool to run the container in privileged mode                                               | `false`                                   |
| `deltaFusionIngestor.service.type`                                | Service type                                                                               | `ClusterIP`                               |
| `deltaFusionIngestor.service.port`                                | Service port                                                                               | `8000`                                    |
| `deltaFusionIngestor.service.labels`                              | Service labels                                                                             | `{}`                                      |
| `deltaFusionIngestor.service.annotations`                         | Service annotations                                                                        | `{}`                                      |
| `deltaFusionIngestor.serviceMonitor.enabled`                      | Enable ServiceMonitor for the deltaFusionIngestor                                          | `true`                                    |
| `deltaFusionIngestor.serviceMonitor.interval`                     | Interval for the ServiceMonitor                                                            | `10s`                                     |
| `deltaFusionIngestor.serviceMonitor.path`                         | Path for the ServiceMonitor                                                                | `/metrics`                                |
| `deltaFusionIngestor.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                                   | `{}`                                      |
| `deltaFusionIngestor.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                              | `{}`                                      |
| `deltaFusionIngestor.serviceAccount.create`                       | Bool to create a service account                                                           | `false`                                   |
| `deltaFusionIngestor.serviceAccount.labels`                       | Service account labels                                                                     | `{}`                                      |
| `deltaFusionIngestor.serviceAccount.annotations`                  | Service account annotations                                                                | `{}`                                      |
| `deltaFusionIngestor.serviceAccount.name`                         | Service account name                                                                       | `""`                                      |
| `deltaFusionIngestor.serviceAccount.automountServiceAccountToken` | Automount token                                                                            | `false`                                   |
| `deltaFusionIngestor.extraVolumes`                                | Extra volumes                                                                              | `[]`                                      |
| `deltaFusionIngestor.extraVolumeMounts`                           | Extra volume mounts                                                                        | `[]`                                      |
| `deltaFusionIngestor.commonLabels`                                | Common labels for the bootstrap job                                                        | `{}`                                      |
| `deltaFusionIngestor.commonAnnotations`                           | Common annotations for the DeltaFusion Ingestor statefulset                                | `{}`                                      |
| `deltaFusionIngestor.extraEnvs`                                   | Extra environment variables                                                                | `[]`                                      |
| `deltaFusionIngestor.nodeSelector`                                | Node selector                                                                              | `{}`                                      |
| `deltaFusionIngestor.tolerations`                                 | Tolerations                                                                                | `[]`                                      |
| `deltaFusionIngestor.affinity`                                    | Affinity                                                                                   | `{}`                                      |
| `deltaFusionIngestor.topologySpreadConstraints`                   | Topology spread constraints                                                                | `{}`                                      |
| `deltaFusionIngestor.env`                                         | Additional environment variables                                                           | `{}`                                      |

### deltaFusionQueryServer Truefoundry DeltaFusion Query

| Name                                                                 | Description                                                                            | Value                                         |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------- |
| `deltaFusionQueryServer.enabled`                                     | Bool to enable the deltaFusionQueryServer                                              | `false`                                       |
| `deltaFusionQueryServer.deploymentLabels`                            | Labels for the deltaFusionQueryServer deployment                                       | `{}`                                          |
| `deltaFusionQueryServer.deploymentAnnotations`                       | Annotations for the deltaFusionQueryServer deployment                                  | `{}`                                          |
| `deltaFusionQueryServer.image.registry`                              | Registry for the deltaFusionQueryServer image (overrides global.registry if specified) | `""`                                          |
| `deltaFusionQueryServer.image.repository`                            | Image repository for the deltaFusionQueryServer (without registry)                     | `tfy-private-images/deltafusion-query-server` |
| `deltaFusionQueryServer.image.tag`                                   | Image tag for the deltaFusionQueryServer                                               | `v0.1.0`                                      |
| `deltaFusionQueryServer.image.optimized`                             | Optimized image tag for the deltaFusionQueryServer                                     | `false`                                       |
| `deltaFusionQueryServer.environmentName`                             | Environment name for the deltaFusionQueryServer                                        | `default`                                     |
| `deltaFusionQueryServer.envSecretName`                               | Secret name for the deltaFusionQueryServer environment variables                       | `deltafusion-query-env-secret`                |
| `deltaFusionQueryServer.imagePullPolicy`                             | Image pull policy for the deltaFusionQueryServer                                       | `IfNotPresent`                                |
| `deltaFusionQueryServer.nameOverride`                                | Override name for the deltaFusionQueryServer                                           | `""`                                          |
| `deltaFusionQueryServer.fullnameOverride`                            | Full name override for the deltaFusionQueryServer                                      | `""`                                          |
| `deltaFusionQueryServer.podLabels`                                   | Labels for the deltaFusionQueryServer pods                                             | `{}`                                          |
| `deltaFusionQueryServer.podAnnotations`                              | Annotations for the deltaFusionQueryServer pods                                        | `{}`                                          |
| `deltaFusionQueryServer.podSecurityContext`                          | Security context for the deltaFusionQueryServer pods                                   | `{}`                                          |
| `deltaFusionQueryServer.commonLabels`                                | Common labels for the deltaFusionQueryServer pods                                      | `{}`                                          |
| `deltaFusionQueryServer.commonAnnotations`                           | Common annotations for the deltaFusionQueryServer pods                                 | `{}`                                          |
| `deltaFusionQueryServer.securityContext.readOnlyRootFilesystem`      | Read only root filesystem for the deltaFusionQueryServer                               | `true`                                        |
| `deltaFusionQueryServer.imagePullSecrets`                            | Image pull secrets for the deltaFusionQueryServer                                      | `[]`                                          |
| `deltaFusionQueryServer.resourceTierOverride`                        | Resource tier override for the deltaFusionQueryServer                                  | `""`                                          |
| `deltaFusionQueryServer.resources`                                   | Resource requests and limits for the deltaFusionQueryServer                            | `{}`                                          |
| `deltaFusionQueryServer.healthcheck.liveness.path`                   | Liveness probe path                                                                    | `/health`                                     |
| `deltaFusionQueryServer.healthcheck.liveness.initialDelaySeconds`    | Initial delay seconds                                                                  | `10`                                          |
| `deltaFusionQueryServer.healthcheck.liveness.periodSeconds`          | Period seconds                                                                         | `5`                                           |
| `deltaFusionQueryServer.healthcheck.liveness.timeoutSeconds`         | Timeout seconds                                                                        | `2`                                           |
| `deltaFusionQueryServer.healthcheck.liveness.successThreshold`       | Success threshold                                                                      | `1`                                           |
| `deltaFusionQueryServer.healthcheck.liveness.failureThreshold`       | Failure threshold                                                                      | `3`                                           |
| `deltaFusionQueryServer.healthcheck.readiness.path`                  | Readiness probe path                                                                   | `/health`                                     |
| `deltaFusionQueryServer.healthcheck.readiness.initialDelaySeconds`   | Initial delay seconds                                                                  | `10`                                          |
| `deltaFusionQueryServer.healthcheck.readiness.periodSeconds`         | Period seconds                                                                         | `5`                                           |
| `deltaFusionQueryServer.healthcheck.readiness.timeoutSeconds`        | Timeout seconds                                                                        | `2`                                           |
| `deltaFusionQueryServer.healthcheck.readiness.successThreshold`      | Success threshold                                                                      | `1`                                           |
| `deltaFusionQueryServer.healthcheck.readiness.failureThreshold`      | Failure threshold                                                                      | `3`                                           |
| `deltaFusionQueryServer.nodeSelector`                                | Node selector for the deltaFusionQueryServer                                           | `{}`                                          |
| `deltaFusionQueryServer.affinity`                                    | Affinity settings for the deltaFusionQueryServer                                       | `{}`                                          |
| `deltaFusionQueryServer.topologySpreadConstraints`                   | Topology spread constraints for the deltaFusionQueryServer                             | `{}`                                          |
| `deltaFusionQueryServer.service.type`                                | Service type for the deltaFusionQueryServer                                            | `ClusterIP`                                   |
| `deltaFusionQueryServer.service.port`                                | Service port for the deltaFusionQueryServer                                            | `8080`                                        |
| `deltaFusionQueryServer.service.labels`                              | Labels for the deltaFusionQueryServer service                                          | `{}`                                          |
| `deltaFusionQueryServer.service.annotations`                         | Annotations for the deltaFusionQueryServer service                                     | `{}`                                          |
| `deltaFusionQueryServer.serviceMonitor.enabled`                      | Enable ServiceMonitor for the deltaFusionQueryServer                                   | `true`                                        |
| `deltaFusionQueryServer.serviceMonitor.interval`                     | Interval for the ServiceMonitor                                                        | `10s`                                         |
| `deltaFusionQueryServer.serviceMonitor.path`                         | Path for the ServiceMonitor                                                            | `/metrics`                                    |
| `deltaFusionQueryServer.serviceMonitor.additionalLabels`             | Additional labels for the ServiceMonitor                                               | `{}`                                          |
| `deltaFusionQueryServer.serviceMonitor.additionalAnnotations`        | Additional annotations for the ServiceMonitor                                          | `{}`                                          |
| `deltaFusionQueryServer.serviceAccount.create`                       | Bool to create a service account for the deltaFusionQueryServer                        | `false`                                       |
| `deltaFusionQueryServer.serviceAccount.name`                         | Service account name                                                                   | `""`                                          |
| `deltaFusionQueryServer.serviceAccount.labels`                       | Labels for the deltaFusionQueryServer service account                                  | `{}`                                          |
| `deltaFusionQueryServer.serviceAccount.annotations`                  | Annotations for the deltaFusionQueryServer service account                             | `{}`                                          |
| `deltaFusionQueryServer.serviceAccount.automountServiceAccountToken` | Automount service account token for the deltaFusionQueryServer service account         | `true`                                        |
| `deltaFusionQueryServer.extraVolumeMounts`                           | Extra volume mounts for the deltaFusionQueryServer server                              | `[]`                                          |
| `deltaFusionQueryServer.extraVolumes`                                | Extra volumes for the deltaFusionQueryServer server                                    | `[]`                                          |
| `deltaFusionQueryServer.env`                                         | Environment variables for the deltaFusionQueryServer                                   | `{}`                                          |

### extraResources Extra Resources to deploy along with the TrueFoundry Control Plane

| Name                       | Description                         | Value   |
| -------------------------- | ----------------------------------- | ------- |
| `extraResources.enabled`   | Bool to enable the extraResources   | `false` |
| `extraResources.manifests` | Kubernetes manifests to be deployed | `[]`    |

## Install TrueFoundry with External Secret Manager

### Step 1: Create the secrets using an external secret manager

```yaml
apiVersion: v1
stringData:
  CLICKHOUSE_PASSWORD: <random_password>
kind: Secret
metadata:
  name: truefoundry-clickhouse-secret
type: Opaque
---
apiVersion: v1
data:
  .dockerconfigjson: <to_be_provided_by_truefoundry>
kind: Secret
metadata:
  name: truefoundry-image-pull-secret
type: kubernetes.io/dockerconfigjson
---
apiVersion: v1
data:
  DB_HOST: <Release.Name>-postgresql.<Release.Namespace>.svc.cluster.local
  DB_NAME: truefoundry
  DB_PASSWORD: <random_password>
  DB_USERNAME: truefoundry
  TFY_API_KEY: <to_be_provided_by_truefoundry>
kind: Secret
metadata:
  name: truefoundry-creds
type: Opaque
---
apiVersion: v1
data:
  NATS_CONTROLPLANE_ACCOUNT_SEED: <to_be_provided_by_truefoundry>
kind: Secret
metadata:
  name: truefoundry-tfy-nats-secret
type: Opaque
---
apiVersion: v1
data:
  resolver.conf: <to_be_provided_by_truefoundry>
kind: Secret
metadata:
  name: tfy-nats-accounts
type: Opaque
```

Note: Replace <random_password> placeholders with a strong password string, `Release.Name` and `Release.Namespace` with helm release name and namespace, and replace all <to_be_provided_by_truefoundry> with values provided by the TrueFoundry team.

### Step 2: Patch to values

Apply following patch to your values file:

```yaml
global:
  existingTruefoundryCredsSecret: truefoundry-creds
  existingTruefoundryImagePullSecretName: truefoundry-image-pull-secret
truefoundryBootstrap:
  enabled: false
tfyNats:
  podTemplate:
    patch:
      - op: add
        path: /spec/volumes/-
        value:
          name: resolver-volume
          secret:
            secretName: tfy-nats-accounts
            defaultMode: 420
```
