## tfy-k8s-generic-inframold
Inframold, the superchart that configure your cluster on generic for truefoundry.

## Parameters

### Global Parameters

| Name               | Description                                          | Value |
| ------------------ | ---------------------------------------------------- | ----- |
| `tenantName`       | Parameters for tenantName                            | `""`  |
| `controlPlaneURL`  | Parameters for controlPlaneURL                       | `""`  |
| `clusterName`      | Name of the cluster                                  | `""`  |
| `registry`         | registry to override in the chart components         | `""`  |
| `imagePullSecrets` | imagePullSecrets to override in the chart components | `[]`  |
| `tolerations`      | Tolerations for the all chart components             | `[]`  |
| `affinity`         | Affinity for the all chart components                | `{}`  |

### argocd parameters

| Name                    | Description                                | Value  |
| ----------------------- | ------------------------------------------ | ------ |
| `argocd.enabled`        | Flag to enable ArgoCD                      | `true` |
| `argocd.tolerations`    | Tolerations for ArgoCD                     | `[]`   |
| `argocd.affinity`       | Affinity for ArgoCD                        | `{}`   |
| `argocd.valuesOverride` | Config override from default config values | `{}`   |

### argoWorkflows parameters

| Name                           | Description                                | Value  |
| ------------------------------ | ------------------------------------------ | ------ |
| `argoWorkflows.enabled`        | Flag to enable Argo Workflows              | `true` |
| `argoWorkflows.tolerations`    | Tolerations for Argo Workflows             | `[]`   |
| `argoWorkflows.affinity`       | Affinity for Argo Workflows                | `{}`   |
| `argoWorkflows.valuesOverride` | Config override from default config values | `{}`   |

### argoRollouts parameters

| Name                          | Description                                | Value  |
| ----------------------------- | ------------------------------------------ | ------ |
| `argoRollouts.enabled`        | Flag to enable Argo Rollouts               | `true` |
| `argoRollouts.tolerations`    | Tolerations for Argo Rollouts              | `[]`   |
| `argoRollouts.affinity`       | Affinity for Argo Rollouts                 | `{}`   |
| `argoRollouts.valuesOverride` | Config override from default config values | `{}`   |

### certManager parameters

| Name                                     | Description                                                                       | Value  |
| ---------------------------------------- | --------------------------------------------------------------------------------- | ------ |
| `certManager.enabled`                    | Flag to enable Cert Manager                                                       | `true` |
| `certManager.tolerations`                | Tolerations for Cert Manager                                                      | `[]`   |
| `certManager.podLabels`                  | Pod labels for Cert Manager. For Azure will be applied to serviceaccount as well. | `{}`   |
| `certManager.serviceAccount.annotations` | Service account annotations for Cert Manager.                                     | `{}`   |
| `certManager.affinity`                   | Affinity for Cert Manager                                                         | `{}`   |
| `certManager.valuesOverride`             | Config override from default config values                                        | `{}`   |

### certManager issuers parameters

| Name                                | Description                                        | Value  |
| ----------------------------------- | -------------------------------------------------- | ------ |
| `certManager.config.enabled`        | Flag to enable certManager config                  | `true` |
| `certManager.config.issuers`        | Map of issuers and their certificate configuration | `{}`   |
| `certManager.config.valuesOverride` | Config override from default config values         | `{}`   |

### metricsServer parameters

| Name                           | Description                                | Value   |
| ------------------------------ | ------------------------------------------ | ------- |
| `metricsServer.enabled`        | Flag to enable Metrics Server              | `false` |
| `metricsServer.enabled`        | Flag to enable Metrics Server              | `false` |
| `metricsServer.tolerations`    | Tolerations for Metrics Server             | `[]`    |
| `metricsServer.affinity`       | Affinity for Metrics Server                | `{}`    |
| `metricsServer.valuesOverride` | Config override from default config values | `{}`    |

### gpu parameters

| Name                 | Description                                | Value     |
| -------------------- | ------------------------------------------ | --------- |
| `gpu.enabled`        | Flag to enable Tfy GPU Operator            | `true`    |
| `gpu.clusterType`    | Cluster type for Tfy GPU Operator          | `generic` |
| `gpu.valuesOverride` | Config override from default config values | `{}`      |

### truefoundry parameters

| Name                          | Description                                | Value   |
| ----------------------------- | ------------------------------------------ | ------- |
| `truefoundry.enabled`         | Flag to enable TrueFoundry                 | `false` |
| `truefoundry.devMode.enabled` | Flag to enable TrueFoundry Dev mode        | `false` |
| `truefoundry.valuesOverride`  | Config override from default config values | `{}`    |

### truefoundryBootstrap parameters

| Name                                       | Description                                                               | Value  |
| ------------------------------------------ | ------------------------------------------------------------------------- | ------ |
| `truefoundry.truefoundryBootstrap.enabled` | Flag to enable bootstrap job to prep cluster for truefoundry installation | `true` |

### Truefoundry virtual service parameters

| Name                                         | Description                                        | Value   |
| -------------------------------------------- | -------------------------------------------------- | ------- |
| `truefoundry.virtualservice.enabled`         | Flag to enable virtualservice                      | `false` |
| `truefoundry.virtualservice.hosts`           | Hosts for truefoundry virtualservice               | `[]`    |
| `truefoundry.virtualservice.gateways`        | Istio gateways to be configured for virtualservice | `[]`    |
| `truefoundry.virtualservice.annotations`     | Annotations for truefoundry virtualservice         | `{}`    |
| `truefoundry.existingTruefoundryCredsSecret` | Secret name for existing Truefoundry creds         | `""`    |

### database. Can be left empty if using the dev mode parameters

| Name                                               | Description                                                | Value     |
| -------------------------------------------------- | ---------------------------------------------------------- | --------- |
| `truefoundry.database.host`                        | Hostname of the database                                   | `""`      |
| `truefoundry.database.name`                        | Name of the database                                       | `""`      |
| `truefoundry.database.username`                    | Username of the database                                   | `""`      |
| `truefoundry.database.password`                    | Password of the database                                   | `""`      |
| `truefoundry.tfyApiKey`                            | API Key for TrueFoundry                                    | `""`      |
| `truefoundry.imagePullSecrets`                     | Image pull secrets for TrueFoundry                         | `[]`      |
| `truefoundry.truefoundryImagePullConfigJSON`       | Json config for authenticating to the TrueFoundry registry | `""`      |
| `truefoundry.truefoundry_iam_role_arn_annotations` | IAM role annotations for service accounts                  | `{}`      |
| `truefoundry.defaultCloudProvider`                 | Default cloud provider                                     | `generic` |
| `truefoundry.storageConfiguration`                 | Storage class for the storage configuration                | `{}`      |
| `truefoundry.s3proxy.enabled`                      | Flag to enable S3 Proxy                                    | `false`   |
| `truefoundry.sparkHistoryServer.enabled`           | Flag to enable Spark History Server                        | `false`   |
| `truefoundry.tfyWorkflowAdmin.enabled`             | Flag to enable Tfy Workflow Admin                          | `false`   |
| `truefoundry.gateway.enabled`                      | Flag to enable Gateway                                     | `false`   |
| `truefoundry.tolerations`                          | Tolerations for the truefoundry components                 | `[]`      |
| `truefoundry.affinity`                             | Affinity for the truefoundry components                    | `{}`      |

### tfyLogs parameters

| Name                     | Description                                | Value  |
| ------------------------ | ------------------------------------------ | ------ |
| `tfyLogs.enabled`        | Flag to enable Tfy Logs                    | `true` |
| `tfyLogs.valuesOverride` | Config override from default config values | `{}`   |
| `tfyLogs.affinity`       | Affinity for tfyLogs statefulset pod       | `{}`   |
| `tfyLogs.tolerations`    | Tolerations for tfyLogs statefulset pod    | `[]`   |

### istio parameters

| Name                           | Description                                | Value  |
| ------------------------------ | ------------------------------------------ | ------ |
| `istio.enabled`                | Flag to enable Istio                       | `true` |
| `istio.enabled`                | Flag to enable Istio Base                  | `true` |
| `istio.base.valuesOverride`    | Config override from default config values | `{}`   |
| `istio.gateway.annotations`    | Annotations for Istio Gateway              | `{}`   |
| `istio.gateway.affinity`       | Affinity for the gateway pods              | `{}`   |
| `istio.gateway.tolerations`    | Tolerations for the gateway pods           | `[]`   |
| `istio.gateway.valuesOverride` | Config override from default config values | `{}`   |

### istio discovery parameters

| Name                             | Description                                | Value                  |
| -------------------------------- | ------------------------------------------ | ---------------------- |
| `istio.discovery.hub`            | Hub for the istio image                    | `gcr.io/istio-release` |
| `istio.discovery.tolerations`    | Tolerations for Istio Discovery            | `[]`                   |
| `istio.discovery.affinity`       | Affinity for Istio Discovery               | `{}`                   |
| `istio.discovery.valuesOverride` | Config override from default config values | `{}`                   |

### istio tfyGateway parameters

| Name                                  | Description                                     | Value    |
| ------------------------------------- | ----------------------------------------------- | -------- |
| `istio.tfyGateway.httpsRedirect`      | Flag to enable HTTPS redirect for Istio Gateway | `false`  |
| `istio.tfyGateway.tls.enabled`        | Flag to enable TLS for Istio Gateway            | `false`  |
| `istio.tfyGateway.tls.mode`           | TLS mode for the Istio Gateway                  | `SIMPLE` |
| `istio.tfyGateway.tls.credentialName` | Credential name for the TLS certificate         | `""`     |
| `istio.tfyGateway.domains`            | Domains for the gateway pods                    | `[]`     |

### keda parameters

| Name                  | Description                                | Value  |
| --------------------- | ------------------------------------------ | ------ |
| `keda.enabled`        | Flag to enable Keda                        | `true` |
| `keda.tolerations`    | Tolerations for Keda                       | `[]`   |
| `keda.affinity`       | Affinity for Keda                          | `{}`   |
| `keda.valuesOverride` | Config override from default config values | `{}`   |

### sparkOperator parameters

| Name                           | Description                                | Value   |
| ------------------------------ | ------------------------------------------ | ------- |
| `sparkOperator.enabled`        | Flag to enable Spark Operator              | `false` |
| `sparkOperator.tolerations`    | Tolerations for Spark Operator             | `[]`    |
| `sparkOperator.affinity`       | Affinity for Spark Operator                | `{}`    |
| `sparkOperator.valuesOverride` | Config override from default config values | `{}`    |

### kubecost parameters

| Name                      | Description                                | Value  |
| ------------------------- | ------------------------------------------ | ------ |
| `kubecost.enabled`        | Flag to enable Kubecost                    | `true` |
| `kubecost.tolerations`    | Tolerations for Kubecost                   | `[]`   |
| `kubecost.affinity`       | Affinity for Kubecost                      | `{}`   |
| `kubecost.valuesOverride` | Config override from default config values | `{}`   |

### prometheus parameters

| Name                                 | Description                                                               | Value  |
| ------------------------------------ | ------------------------------------------------------------------------- | ------ |
| `prometheus.enabled`                 | Flag to enable Prometheus                                                 | `true` |
| `prometheus.additionalScrapeConfigs` | Additional scrape configs for Prometheus                                  | `[]`   |
| `prometheus.alertmanager`            | Alertmanager configuration for Prometheus                                 | `{}`   |
| `prometheus.affinity`                | Affinity for prometheus statefulset pod                                   | `{}`   |
| `prometheus.tolerations`             | Tolerations for prometheus statefulset pod                                | `[]`   |
| `prometheus.valuesOverride`          | Config override from default config values                                | `{}`   |
| `prometheus.config.enabled`          | Flag to enable prometheus config (requires prometheus.enabled to be true) | `true` |
| `prometheus.config.valuesOverride`   | Config override from default config values                                | `{}`   |
| `prometheus.config.extraObjects`     | Extra objects for prometheus config                                       | `[]`   |

### grafana parameters

| Name                     | Description                                | Value   |
| ------------------------ | ------------------------------------------ | ------- |
| `grafana.enabled`        | Flag to enable Grafana                     | `false` |
| `grafana.tolerations`    | Tolerations for Grafana                    | `[]`    |
| `grafana.affinity`       | Affinity for Grafana                       | `{}`    |
| `grafana.valuesOverride` | Config override from default config values | `{}`    |

### tfyAgent parameters

| Name                          | Description                                | Value  |
| ----------------------------- | ------------------------------------------ | ------ |
| `tfyAgent.enabled`            | Flag to enable Tfy Agent                   | `true` |
| `tfyAgent.valuesOverride`     | Config override from default config values | `{}`   |
| `tfyAgent.tolerations`        | Tolerations for the agent pods             | `[]`   |
| `tfyAgent.affinity`           | Affinity for the agent pods                | `{}`   |
| `tfyAgent.clusterToken`       | cluster token                              | `""`   |
| `tfyAgent.clusterTokenSecret` | Secret name for cluster token              | `""`   |

### elasti parameters

| Name                    | Description                                | Value  |
| ----------------------- | ------------------------------------------ | ------ |
| `elasti.enabled`        | Flag to enable Elasti                      | `true` |
| `elasti.tolerations`    | Tolerations for Elasti                     | `[]`   |
| `elasti.affinity`       | Affinity for Elasti                        | `{}`   |
| `elasti.valuesOverride` | Config override from default config values | `{}`   |

### jspolicy parameters

| Name                             | Description                                              | Value   |
| -------------------------------- | -------------------------------------------------------- | ------- |
| `jspolicy.enabled`               | Flag to enable jspolicy. No policy is applied by default | `false` |
| `jspolicy.enabled`               | Flag to enable jspolicy                                  | `false` |
| `jspolicy.valuesOverride`        | Config override from default config values               | `{}`    |
| `jspolicy.affinity`              | Affinity for jspolicy                                    | `{}`    |
| `jspolicy.tolerations`           | Tolerations for jspolicy                                 | `[]`    |
| `jspolicy.config.valuesOverride` | Config override from default config values               | `{}`    |

### tfy-workflow-propeller parameters

| Name                                  | Description                                | Value   |
| ------------------------------------- | ------------------------------------------ | ------- |
| `tfyWorkflowPropeller.enabled`        | Flag to enable workflow-propeller.         | `false` |
| `tfyWorkflowPropeller.valuesOverride` | Config override from default config values | `{}`    |
| `helm.resourcePolicy`                 | Resource policy for the helm chart         | `keep`  |
