# Tfy-cloudflared helm chart packaged by TrueFoundry
Tfy-cloudflared vendors the upstream Cloudflare Tunnel chart into this repository so it can be maintained and released from the TrueFoundry charts repo.

It deploys [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) for secure, outbound-only connections between services in your cluster and Cloudflare's network.

## Installation

From this repository:

```bash
helm install tfy-cloudflared ./charts/tfy-cloudflared -f values.yaml
```

From the published TrueFoundry repo after release:

```bash
helm repo add truefoundry https://truefoundry.github.io/infra-charts/
helm repo update
helm install tfy-cloudflared truefoundry/tfy-cloudflared -f values.yaml
```

## Quick Start

Create a tunnel in the Cloudflare dashboard, copy the tunnel token, and set one of the following:

```yaml
tunnel:
  token: "eyJhIjoiY2Y..."
```

or reference an existing secret:

```yaml
tunnel:
  existingSecret: my-tunnel-secret
  existingSecretKey: token
```

Then configure the public hostname mappings in Cloudflare to point at your in-cluster services.

## Notes

- This chart does not create Cloudflare tunnel routes or ingress rules.
- Horizontal autoscaling is intentionally not included because downscaling can terminate active tunnel connections.
- The metrics endpoint is exposed on port `2000` and a `ServiceMonitor` can be enabled when needed.

## More Information

- [Cloudflare Tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Kubernetes deployment guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/deployment-guides/kubernetes/)
- [Architecture overview](docs/architecture.md)
