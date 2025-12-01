# Tfy-squid-proxy helm chart packaged by TrueFoundry
Tfy-squid-proxy is a Helm chart that facilitates the deployment and management of Squid forward proxy for HTTP/HTTPS traffic forwarding.

## Parameters

### Squid Proxy Configuration

| Name                              | Description                                      | Value                                                                                                                                                                                                                                                                                                               |
| --------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `squid.replicas`                  | number of replicas of squid proxy service        | `3`                                                                                                                                                                                                                                                                                                                 |
| `squid.image.repository`          | the docker image repository for squid proxy      | `public.ecr.aws/ubuntu/squid`                                                                                                                                                                                                                                                                                       |
| `squid.image.tag`                 | the docker image tag for squid proxy             | `6.6-24.04_edge`                                                                                                                                                                                                                                                                                                    |
| `squid.image.pullPolicy`          | Image pull policy                                | `IfNotPresent`                                                                                                                                                                                                                                                                                                      |
| `squid.imagePullSecrets`          | Image pull secrets for squid proxy               | `[]`                                                                                                                                                                                                                                                                                                                |
| `squid.port`                      | the port on which squid proxy listens            | `3130`                                                                                                                                                                                                                                                                                                              |
| `squid.config`                    | the squid configuration file content             | `# ------------------------
# Squid #3 - groq-only
# Listens on 3130
# ------------------------
http_port 3130

# No caching
cache deny all

# Allow all by default
http_access allow all

# Logging
# Route access logs directly to stdout (no stdio: prefix)
access_log /dev/stdout
cache_log stdio:/dev/stdout
` |
| `squid.resources.limits.cpu`      | The maximum amount of CPU the service can use    | `200m`                                                                                                                                                                                                                                                                                                              |
| `squid.resources.limits.memory`   | The maximum amount of memory the service can use | `256Mi`                                                                                                                                                                                                                                                                                                             |
| `squid.resources.requests.cpu`    | The amount of CPU the service requests           | `100m`                                                                                                                                                                                                                                                                                                              |
| `squid.resources.requests.memory` | The amount of memory the service requests        | `128Mi`                                                                                                                                                                                                                                                                                                             |
| `squid.tolerations`               | Tolerations for the squid proxy service          | `[]`                                                                                                                                                                                                                                                                                                                |
| `squid.affinity`                  | Node affinity for squid proxy service            | `{}`                                                                                                                                                                                                                                                                                                                |
| `squid.nodeSelector`              | Node selector for squid proxy service            | `{}`                                                                                                                                                                                                                                                                                                                |
| `squid.service.type`              | Service type for squid proxy                     | `ClusterIP`                                                                                                                                                                                                                                                                                                         |
| `squid.service.annotations`       | Service annotations                              | `{}`                                                                                                                                                                                                                                                                                                                |

