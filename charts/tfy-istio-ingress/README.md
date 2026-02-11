# Tfy-istio-ingress helm chart packaged by TrueFoundry
Tfy-istio-ingress is a Helm chart that facilitates the deployment and configuration of Istio Ingress Gateway on a Kubernetes cluster.

## Parameters

### ALB Configuration

| Name                               | Description                                | Value   |
| ---------------------------------- | ------------------------------------------ | ------- |
| `alb.ingress.enabled`              | Enable ALB ingress                         | `false` |
| `alb.ingress.ingressClassName`     | Ingress class name for ALB                 | `alb`   |
| `alb.ingress.annotations`          | Additional annotations for the ALB ingress | `{}`    |
| `alb.ingress.flyte.enabled`        | Enable HTTP2 ALB ingress path for Flyte    | `true`  |
| `alb.ingress.additionalHttp2Paths` | Additional HTTP2 paths to be configured    | `[]`    |

### Gateway Configuration

| Name                                                 | Description                                                      | Value |
| ---------------------------------------------------- | ---------------------------------------------------------------- | ----- |
| `gateway.autoscaling.minReplicas`                    | Minimum number of replicas for autoscaling the Gateway.          | `3`   |
| `gateway.autoscaling.maxReplicas`                    | Maximum number of replicas for autoscaling the Gateway.          | `100` |
| `gateway.autoscaling.targetCPUUtilizationPercentage` | CPU utilization percentage wrt requests for scaling gateway pods | `70`  |
| `gateway.resources`                                  | Resource section for the gateway pods                            | `{}`  |

### tfyGateway Configuration for the tfyGateway.

| Name                                                | Description                             | Value                 |
| --------------------------------------------------- | --------------------------------------- | --------------------- |
| `tfyGateway.name`                                   | Name of the tfyGateway.                 | `""`                  |
| `tfyGateway.labels`                                 | Labels for the tfyGateway.              | `{}`                  |
| `tfyGateway.annotations`                            | Annotations for the tfyGateway.         | `{}`                  |
| `tfyGateway.spec.selector.istio`                    | Selector to enable istio for tfyGateway | `{{ .Release.Name }}` |
| `tfyGateway.spec.servers[0].hosts`                  | List of hosts for the first server.     | `[]`                  |
| `tfyGateway.spec.servers[0].port.name`              | Name of the port.                       | `http-tfy-wildcard`   |
| `tfyGateway.spec.servers[0].port.number`            | Port number for http.                   | `80`                  |
| `tfyGateway.spec.servers[0].port.protocol`          | Protocol of the port.                   | `HTTP`                |
| `tfyGateway.spec.servers[0].port.tls.httpsRedirect` | TLS configuration for the port.         | `true`                |
| `tfyGateway.spec.servers[1].hosts`                  | List of hosts for the second server.    | `[]`                  |
| `tfyGateway.spec.servers[1].port.name`              | Name of the port.                       | `https-tfy-wildcard`  |
| `tfyGateway.spec.servers[1].port.number`            | Port number for https.                  | `443`                 |
| `tfyGateway.spec.servers[1].port.protocol`          | Protocol of the port.                   | `HTTPS`               |

### telemetry Configuration for the telemetry.

| Name                      | Description                       | Value   |
| ------------------------- | --------------------------------- | ------- |
| `telemetry.enabled`       | Enable telemetry.                 | `false` |
| `telemetry.accessLogging` | Access logging for the telemetry. | `[]`    |

### awsElbControllerChecker Job that verifies aws-load-balancer-controller deployment has 2 pods up.

| Name                                            | Description                                                                                | Value                                        |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------------------- |
| `awsElbControllerChecker.enabled`               | Enable the aws-load-balancer-controller checker job.                                       | `false`                                      |
| `awsElbControllerChecker.labels`                | Labels for the aws-load-balancer-controller checker job.                                   | `{}`                                         |
| `awsElbControllerChecker.annotations`           | Annotations for the aws-load-balancer-controller checker job.                              | `{}`                                         |
| `awsElbControllerChecker.jobLabels`             | Labels for the aws-load-balancer-controller checker job.                                   | `{}`                                         |
| `awsElbControllerChecker.jobAnnotations`        | Annotations for the aws-load-balancer-controller checker job.                              | `{}`                                         |
| `awsElbControllerChecker.deploymentName`        | Name of the aws-load-balancer-controller deployment to check.                              | `aws-load-balancer-controller`               |
| `awsElbControllerChecker.namespace`             | Namespace where the aws-load-balancer-controller deployment runs.                          | `aws-load-balancer-controller`               |
| `awsElbControllerChecker.waitTimeoutSeconds`    | Time in seconds to wait for aws-load-balancer-controller pods to come up (default 3 mins). | `180`                                        |
| `awsElbControllerChecker.image.repository`      | Repository for the checker job (helm-kubectl-based).                                       | `tfy.jfrog.io/tfy-mirror/dtzar/helm-kubectl` |
| `awsElbControllerChecker.image.tag`             | Tag for the checker job (helm-kubectl-based).                                              | `3.19.1`                                     |
| `awsElbControllerChecker.image.pullPolicy`      | Pull policy for the checker job (helm-kubectl-based).                                      | `IfNotPresent`                               |
| `awsElbControllerChecker.serviceAccount.create` | Create a dedicated ServiceAccount for the checker job.                                     | `true`                                       |
| `awsElbControllerChecker.serviceAccount.name`   | Name of existing ServiceAccount to use when create is false.                               | `""`                                         |
| `awsElbControllerChecker.resources`             | Resource limits/requests for the checker job.                                              | `{}`                                         |
| `awsElbControllerChecker.backoffLimit`          | Number of retries before the job is marked failed.                                         | `3`                                          |
