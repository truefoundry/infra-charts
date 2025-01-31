## tfy-k8s-aws-eks-inframold
Inframold, the superchart that configure your cluster on aws for truefoundry.

## Parameters

### Global Parameters

| Name              | Description                              | Value |
| ----------------- | ---------------------------------------- | ----- |
| `tenantName`      | Parameters for tenantName                | `""`  |
| `controlPlaneURL` | Parameters for controlPlaneURL           | `""`  |
| `clusterName`     | Name of the cluster                      | `""`  |
| `tolerations`     | Tolerations for the all chart components | `[]`  |
| `affinity`        | Affinity for the all chart components    | `{}`  |

### argocd parameters

| Name                    | Description                                | Value  |
| ----------------------- | ------------------------------------------ | ------ |
| `argocd.enabled`        | Flag to enable ArgoCD                      | `true` |
| `argocd.valuesOverride` | Config override from default config values | `{}`   |

### argoWorkflows parameters

| Name                           | Description                                | Value  |
| ------------------------------ | ------------------------------------------ | ------ |
| `argoWorkflows.enabled`        | Flag to enable Argo Workflows              | `true` |
| `argoWorkflows.valuesOverride` | Config override from default config values | `{}`   |

### argoRollouts parameters

| Name                          | Description                                | Value  |
| ----------------------------- | ------------------------------------------ | ------ |
| `argoRollouts.enabled`        | Flag to enable Argo Rollouts               | `true` |
| `argoRollouts.valuesOverride` | Config override from default config values | `{}`   |

### notebookController parameters

| Name                                       | Description                                   | Value              |
| ------------------------------------------ | --------------------------------------------- | ------------------ |
| `notebookController.enabled`               | Flag to enable Notebook Controller            | `false`            |
| `notebookController.defaultStorageClass`   | Default storage class for Notebook Controller | `""`               |
| `notebookController.notebookBaseDomainUrl` | Base domain URL for Notebook Controller       | `<to_be_provided>` |
| `notebookController.valuesOverride`        | Config override from default config values    | `{}`               |

### certManager parameters

| Name                         | Description                                | Value   |
| ---------------------------- | ------------------------------------------ | ------- |
| `certManager.enabled`        | Flag to enable Cert Manager                | `false` |
| `certManager.valuesOverride` | Config override from default config values | `{}`    |

### metricsServer parameters

| Name                           | Description                                | Value  |
| ------------------------------ | ------------------------------------------ | ------ |
| `metricsServer.enabled`        | Flag to enable Metrics Server              | `true` |
| `metricsServer.enabled`        | Flag to enable Metrics Server              | `true` |
| `metricsServer.valuesOverride` | Config override from default config values | `{}`   |

### AWS parameters

| Name                                           | Description                                 | Value   |
| ---------------------------------------------- | ------------------------------------------- | ------- |
| `aws.awsLoadBalancerController.enabled`        | Flag to enable AWS Load Balancer Controller | `true`  |
| `aws.awsLoadBalancerController.roleArn`        | Role ARN for AWS Load Balancer Controller   | `""`    |
| `aws.awsLoadBalancerController.vpcId`          | VPC ID of AWS EKS cluster                   | `""`    |
| `aws.awsLoadBalancerController.region`         | region of AWS EKS cluster                   | `""`    |
| `aws.awsLoadBalancerController.valuesOverride` | Config override from default config values  | `{}`    |
| `aws.karpenter.enabled`                        | Flag to enable Karpenter                    | `true`  |
| `aws.karpenter.clusterEndpoint`                | Cluster endpoint for Karpenter              | `""`    |
| `aws.karpenter.roleArn`                        | Role ARN for Karpenter                      | `""`    |
| `aws.karpenter.instanceProfile`                | Instance profile for Karpenter              | `""`    |
| `aws.karpenter.defaultZones`                   | Default zones list for Karpenter            | `[]`    |
| `aws.karpenter.webhook.enabled`                | Flag to enable Karpenter webhook            | `true`  |
| `aws.karpenter.interruptionQueue`              | Interruption queue name for Karpenter       | `""`    |
| `aws.karpenter.valuesOverride`                 | Config override from default config values  | `{}`    |
| `aws.karpenter.config.valuesOverride`          | Config override for karpenter config        | `{}`    |
| `aws.awsEbsCsiDriver.enabled`                  | Flag to enable AWS EBS CSI Driver           | `true`  |
| `aws.awsEbsCsiDriver.roleArn`                  | Role ARN for AWS EBS CSI Driver             | `""`    |
| `aws.awsEbsCsiDriver.valuesOverride`           | Config override from default config values  | `{}`    |
| `aws.awsEfsCsiDriver.enabled`                  | Flag to enable AWS EFS CSI Driver           | `true`  |
| `aws.awsEfsCsiDriver.fileSystemId`             | File system ID for AWS EFS CSI Driver       | `""`    |
| `aws.awsEfsCsiDriver.roleArn`                  | Role ARN for AWS EFS CSI Driver             | `""`    |
| `aws.awsEfsCsiDriver.valuesOverride`           | Config override from default config values  | `{}`    |
| `aws.inferentia.enabled`                       | Flag to enable Inferentia                   | `false` |
| `aws.inferentia.valuesOverride`                | Config override from default config values  | `{}`    |

### gpu parameters

| Name                 | Description                                | Value    |
| -------------------- | ------------------------------------------ | -------- |
| `gpu.enabled`        | Flag to enable Tfy GPU Operator            | `true`   |
| `gpu.clusterType`    | Cluster type for Tfy GPU Operator          | `awsEks` |
| `gpu.valuesOverride` | Config override from default config values | `{}`     |

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

| Name                                  | Description                                        | Value   |
| ------------------------------------- | -------------------------------------------------- | ------- |
| `truefoundry.virtualservice.enabled`  | Flag to enable virtualservice                      | `false` |
| `truefoundry.virtualservice.hosts`    | Hosts for truefoundry virtualservice               | `[]`    |
| `truefoundry.virtualservice.gateways` | Istio gateways to be configured for virtualservice | `[]`    |

### database. Can be left empty if using the dev mode parameters

| Name                                         | Description                                                | Value |
| -------------------------------------------- | ---------------------------------------------------------- | ----- |
| `truefoundry.database.host`                  | Hostname of the database                                   | `""`  |
| `truefoundry.database.name`                  | Name of the database                                       | `""`  |
| `truefoundry.database.username`              | Username of the database                                   | `""`  |
| `truefoundry.database.password`              | Password of the database                                   | `""`  |
| `truefoundry.tfyApiKey`                      | API Key for TrueFoundry                                    | `""`  |
| `truefoundry.truefoundryImagePullConfigJSON` | Json config for authenticating to the TrueFoundry registry | `""`  |

### loki parameters

| Name                  | Description                                | Value  |
| --------------------- | ------------------------------------------ | ------ |
| `loki.enabled`        | Flag to enable Loki                        | `true` |
| `loki.valuesOverride` | Config override from default config values | `{}`   |
| `loki.affinity`       | Affinity for loki statefulset pod          | `{}`   |
| `loki.tolerations`    | Tolerations for loki statefulset pod       | `[]`   |

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

| Name                             | Description                                     | Value                  |
| -------------------------------- | ----------------------------------------------- | ---------------------- |
| `istio.discovery.hub`            | Hub for the istio image                         | `gcr.io/istio-release` |
| `istio.discovery.tag`            | Tag for the istio image                         | `1.21.1-distroless`    |
| `istio.discovery.valuesOverride` | Config override from default config values      | `{}`                   |
| `istio.tfyGateway.httpsRedirect` | Flag to enable HTTPS redirect for Istio Gateway | `true`                 |

### keda parameters

| Name                  | Description                                | Value  |
| --------------------- | ------------------------------------------ | ------ |
| `keda.enabled`        | Flag to enable Keda                        | `true` |
| `keda.valuesOverride` | Config override from default config values | `{}`   |

### kubecost parameters

| Name                      | Description                                | Value  |
| ------------------------- | ------------------------------------------ | ------ |
| `kubecost.enabled`        | Flag to enable Kubecost                    | `true` |
| `kubecost.valuesOverride` | Config override from default config values | `{}`   |

### prometheus parameters

| Name                                 | Description                                | Value  |
| ------------------------------------ | ------------------------------------------ | ------ |
| `prometheus.enabled`                 | Flag to enable Prometheus                  | `true` |
| `prometheus.additionalScrapeConfigs` | Additional scrape configs for Prometheus   | `[]`   |
| `prometheus.alertmanager`            | Alertmanager configuration for Prometheus  | `{}`   |
| `prometheus.affinity`                | Affinity for prometheus statefulset pod    | `{}`   |
| `prometheus.tolerations`             | Tolerations for prometheus statefulset pod | `[]`   |
| `prometheus.valuesOverride`          | Config override from default config values | `{}`   |

### grafana parameters

| Name                     | Description                                | Value   |
| ------------------------ | ------------------------------------------ | ------- |
| `grafana.enabled`        | Flag to enable Grafana                     | `false` |
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

| Name                    | Description                                | Value   |
| ----------------------- | ------------------------------------------ | ------- |
| `elasti.enabled`        | Flag to enable Elasti                      | `false` |
| `elasti.valuesOverride` | Config override from default config values | `{}`    |

### jspolicy parameters

| Name                             | Description                                              | Value   |
| -------------------------------- | -------------------------------------------------------- | ------- |
| `jspolicy.enabled`               | Flag to enable jspolicy. No policy is applied by default | `false` |
| `jspolicy.enabled`               | Flag to enable jspolicy                                  | `false` |
| `jspolicy.valuesOverride`        | Config override from default config values               | `{}`    |
| `jspolicy.affinity`              | Affinity for jspolicy                                    | `{}`    |
| `jspolicy.tolerations`           | Tolerations for jspolicy                                 | `[]`    |
| `jspolicy.config.valuesOverride` | Config override from default config values               | `{}`    |
