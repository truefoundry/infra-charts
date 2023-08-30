# Tfy-istio-ingress helm chart packaged by TrueFoundry
Tfy-istio-ingress is an <empty>

## Parameters

### gateway Configuration for the Gateway component.

| Name                                  | Description                                             | Value         |
| ------------------------------------- | ------------------------------------------------------- | ------------- |
| `gateway.autoscaling.minReplicas`     | Minimum number of replicas for autoscaling the Gateway. | `3`           |
| `gateway.service.ports[0].name`       | Name of the port.                                       | `status-port` |
| `gateway.service.ports[0].port`       | Port number for status-port.                            | `15021`       |
| `gateway.service.ports[0].protocol`   | Protocol of the port.                                   | `TCP`         |
| `gateway.service.ports[0].targetPort` | Target port.                                            | `15021`       |
| `gateway.service.ports[1].name`       | Name of the port.                                       | `http2`       |
| `gateway.service.ports[1].port`       | Port number for http.                                   | `80`          |
| `gateway.service.ports[1].protocol`   | Protocol of the port.                                   | `TCP`         |
| `gateway.service.ports[1].targetPort` | Target port.                                            | `80`          |
| `gateway.service.ports[2].name`       | Name of the port.                                       | `https`       |
| `gateway.service.ports[2].port`       | Port number for https.                                  | `443`         |
| `gateway.service.ports[2].protocol`   | Protocol of the port.                                   | `TCP`         |
| `gateway.service.ports[2].targetPort` | Target port.                                            | `443`         |

### tfyGateway Configuration for the tfyGateway.

| Name                                                | Description                             | Value                 |
| --------------------------------------------------- | --------------------------------------- | --------------------- |
| `tfyGateway.name`                                   | Name of the tfyGateway.                 | `""`                  |
| `tfyGateway.spec.selector.istio`                    | Selector to enable istio for tfyGateway | `{{ .Release.Name }}` |
| `tfyGateway.spec.servers[0].hosts`                  | List of hosts for the first server.     | `[]`                  |
| `tfyGateway.spec.servers[0].port.name`              | Name of the port.                       | `http-tfy-wildcard`   |
| `tfyGateway.spec.servers[0].port.number`            | Port number for http.                   | `80`                  |
| `tfyGateway.spec.servers[0].port.protocol`          | Protocol of the port.                   | `HTTP`                |
| `tfyGateway.spec.servers[0].port.tls.httpsRedirect` | TLS configuration for the port.         | `true`                |
| `tfyGateway.spec.servers[1].hosts`                  | List of hosts for the second server.    | `[]`                  |
| `tfyGateway.spec.servers[1].port.name`              | Name of the port for https.             | `https-tfy-wildcard`  |
| `tfyGateway.spec.servers[1].port.number`            | Port number.                            | `443`                 |
| `tfyGateway.spec.servers[1].port.protocol`          | Protocol of the port.                   | `HTTPS`               |
