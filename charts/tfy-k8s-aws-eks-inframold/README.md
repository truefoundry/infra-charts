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

| Name             | Description           | Value  |
| ---------------- | --------------------- | ------ |
| `argocd.enabled` | Flag to enable ArgoCD | `true` |

### argoWorkflows parameters

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `argoWorkflows.enabled` | Flag to enable Argo Workflows | `true` |

### argoRollouts parameters

| Name                   | Description                  | Value  |
| ---------------------- | ---------------------------- | ------ |
| `argoRollouts.enabled` | Flag to enable Argo Rollouts | `true` |

### notebookController parameters

| Name                                       | Description                                   | Value              |
| ------------------------------------------ | --------------------------------------------- | ------------------ |
| `notebookController.enabled`               | Flag to enable Notebook Controller            | `false`            |
| `notebookController.defaultStorageClass`   | Default storage class for Notebook Controller | `""`               |
| `notebookController.notebookBaseDomainUrl` | Base domain URL for Notebook Controller       | `<to_be_provided>` |

### certManager parameters

| Name                  | Description                 | Value   |
| --------------------- | --------------------------- | ------- |
| `certManager.enabled` | Flag to enable Cert Manager | `false` |

### metricsServer parameters

| Name                    | Description                   | Value  |
| ----------------------- | ----------------------------- | ------ |
| `metricsServer.enabled` | Flag to enable Metrics Server | `true` |

### AWS parameters

| Name                                    | Description                                 | Value   |
| --------------------------------------- | ------------------------------------------- | ------- |
| `aws.awsLoadBalancerController.enabled` | Flag to enable AWS Load Balancer Controller | `true`  |
| `aws.awsLoadBalancerController.roleArn` | Role ARN for AWS Load Balancer Controller   | `""`    |
| `aws.awsLoadBalancerController.vpcId`   | VPC ID of AWS EKS cluster                   | `""`    |
| `aws.awsLoadBalancerController.region`  | region of AWS EKS cluster                   | `""`    |
| `aws.karpenter.enabled`                 | Flag to enable Karpenter                    | `true`  |
| `aws.karpenter.clusterEndpoint`         | Cluster endpoint for Karpenter              | `""`    |
| `aws.karpenter.roleArn`                 | Role ARN for Karpenter                      | `""`    |
| `aws.karpenter.instanceProfile`         | Instance profile for Karpenter              | `""`    |
| `aws.karpenter.defaultZones`            | Default zones list for Karpenter            | `[]`    |
| `aws.karpenter.interruptionQueue`       | Interruption queue name for Karpenter       | `""`    |
| `aws.awsEbsCsiDriver.enabled`           | Flag to enable AWS EBS CSI Driver           | `true`  |
| `aws.awsEbsCsiDriver.roleArn`           | Role ARN for AWS EBS CSI Driver             | `""`    |
| `aws.awsEfsCsiDriver.enabled`           | Flag to enable AWS EFS CSI Driver           | `true`  |
| `aws.awsEfsCsiDriver.fileSystemId`      | File system ID for AWS EFS CSI Driver       | `""`    |
| `aws.awsEfsCsiDriver.roleArn`           | Role ARN for AWS EFS CSI Driver             | `""`    |
| `aws.inferentia.enabled`                | Flag to enable Inferentia                   | `false` |

### gpu parameters

| Name              | Description                       | Value    |
| ----------------- | --------------------------------- | -------- |
| `gpu.enabled`     | Flag to enable Tfy GPU Operator   | `true`   |
| `gpu.clusterType` | Cluster type for Tfy GPU Operator | `awsEks` |

### truefoundry parameters

| Name                          | Description                         | Value   |
| ----------------------------- | ----------------------------------- | ------- |
| `truefoundry.enabled`         | Flag to enable TrueFoundry          | `false` |
| `truefoundry.devMode.enabled` | Flag to enable TrueFoundry Dev mode | `false` |

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

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `loki.enabled` | Flag to enable Loki | `true` |

### istio parameters

| Name            | Description          | Value  |
| --------------- | -------------------- | ------ |
| `istio.enabled` | Flag to enable Istio | `true` |

### istio discovery parameters

| Name                             | Description                                     | Value                  |
| -------------------------------- | ----------------------------------------------- | ---------------------- |
| `istio.discovery.hub`            | Hub for the istio image                         | `gcr.io/istio-release` |
| `istio.discovery.tag`            | Tag for the istio image                         | `1.21.1-distroless`    |
| `istio.tfyGateway.httpsRedirect` | Flag to enable HTTPS redirect for Istio Gateway | `true`                 |

### keda parameters

| Name           | Description         | Value  |
| -------------- | ------------------- | ------ |
| `keda.enabled` | Flag to enable Keda | `true` |

### kubecost parameters

| Name               | Description             | Value  |
| ------------------ | ----------------------- | ------ |
| `kubecost.enabled` | Flag to enable Kubecost | `true` |

### prometheus parameters

| Name                 | Description               | Value  |
| -------------------- | ------------------------- | ------ |
| `prometheus.enabled` | Flag to enable Prometheus | `true` |

### grafana parameters

| Name              | Description            | Value   |
| ----------------- | ---------------------- | ------- |
| `grafana.enabled` | Flag to enable Grafana | `false` |

### tfyAgent parameters

| Name                    | Description              | Value  |
| ----------------------- | ------------------------ | ------ |
| `tfyAgent.enabled`      | Flag to enable Tfy Agent | `true` |
| `tfyAgent.clusterToken` | cluster token            | `""`   |

### elasti parameters

| Name             | Description           | Value   |
| ---------------- | --------------------- | ------- |
| `elasti.enabled` | Flag to enable Elasti | `false` |

### jspolicy parameters

| Name               | Description                                              | Value   |
| ------------------ | -------------------------------------------------------- | ------- |
| `jspolicy.enabled` | Flag to enable jspolicy. No policy is applied by default | `false` |
