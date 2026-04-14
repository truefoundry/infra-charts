# tfy-sandbox-server

Helm chart for deploying **tfy-sandbox-server**, a lightweight HTTP sandbox that executes shell commands for TrueFoundry AI agents.

## Installation

```bash
helm install tfy-sandbox-server charts/tfy-sandbox-server
```

## Key Configuration

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image | `tfy.jfrog.io/tfy-public/tfy-sandbox-server` |
| `image.tag` | Image tag | `0.1.0` |
| `persistence.enabled` | Enable PVC for sandbox data | `true` |
| `persistence.size` | Volume size | `50Gi` |
| `persistence.storageClassName` | Storage class (empty = cluster default) | `""` |
| `sandbox.rootDir` | Root directory for sandbox workspaces | `/data/sandboxes` |
| `sandbox.defaultTimeout` | Default command timeout (seconds) | `60` |
| `replicaCount` | Number of replicas (1 recommended for RWO volumes) | `1` |

## Integration with TrueFoundry LLM Gateway

Deploy this chart on the same cluster as the TrueFoundry LLM Gateway. Point the gateway to the sandbox server by setting the `SANDBOX_SERVER_URL` environment variable on the gateway to the internal service URL:

```
http://<release-name>-tfy-sandbox-server:8080
```
