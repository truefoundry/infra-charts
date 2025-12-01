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
