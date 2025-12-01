# Squid Forward Proxy Helm Chart

This Helm chart deploys a Squid forward proxy for HTTP/HTTPS traffic forwarding.

## Overview

Squid is a caching and forwarding HTTP web proxy. This chart configures it as a forward proxy that can be used to route outbound HTTP/HTTPS traffic through a controlled endpoint.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Installation

```bash
helm install my-squid-proxy ./tfy-squid-proxy
```

## Configuration

The following table lists the configurable parameters of the Squid Proxy chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `squid.replicas` | Number of replicas | `1` |
| `squid.image.repository` | Docker image repository | `public.ecr.aws/ubuntu/squid` |
| `squid.image.tag` | Docker image tag | `6.6-24.04_edge` |
| `squid.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `squid.imagePullSecrets` | Image pull secrets | `[]` |
| `squid.port` | Proxy listen port | `3130` |
| `squid.config` | Squid configuration file content | See values.yaml |
| `squid.resources.limits.cpu` | CPU limit | `200m` |
| `squid.resources.limits.memory` | Memory limit | `256Mi` |
| `squid.resources.requests.cpu` | CPU request | `100m` |
| `squid.resources.requests.memory` | Memory request | `128Mi` |
| `squid.tolerations` | Pod tolerations | `[]` |
| `squid.affinity` | Pod affinity rules | `{}` |
| `squid.nodeSelector` | Node selector | `{}` |
| `squid.service.type` | Service type | `ClusterIP` |
| `squid.service.annotations` | Service annotations | `{}` |

## Usage

### Basic Installation

```bash
helm install squid-proxy ./tfy-squid-proxy
```

### Custom Configuration

Create a custom values file:

```yaml
squid:
  replicas: 2
  port: 3128
  config: |
    http_port 3128
    cache deny all
    http_access allow all
    access_log /dev/stdout
```

Install with custom values:

```bash
helm install squid-proxy ./tfy-squid-proxy -f custom-values.yaml
```

### With Image Pull Secrets

```yaml
squid:
  imagePullSecrets:
    - name: my-registry-secret
```

## Accessing the Proxy

The proxy will be available at:

```
http://<release-name>-squid-proxy.<namespace>.svc.cluster.local:<port>
```

For example:
```
http://squid-proxy-squid-proxy.default.svc.cluster.local:3130
```

## Uninstallation

```bash
helm uninstall squid-proxy
```

## Default Squid Configuration

The default configuration:
- Listens on port 3130
- Disables caching
- Allows all traffic by default
- Logs to stdout

**Note**: The default configuration allows all traffic. For production use, you should customize the ACLs and access controls based on your security requirements.

