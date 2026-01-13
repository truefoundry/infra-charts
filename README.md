# TrueFoundry Infra Charts

Please visit the [GitHub Repo](https://github.com/truefoundry/infra-charts) for sources

## To enable scraping metrics for a particular service
1. Create a service monitor object in `charts/tfy-prometheus-config/templates/serviceMonitors`
2. Add an entry in `charts/tfy-prometheus-config/values.yaml`
3. Add an entry in `charts/tfy-prometheus-config/templates/_helpers.tpl`
4. Update the chart version in `charts/tfy-prometheus-config/Chart.yaml`
5. Create a corresponding entry in [here](https://github.com/truefoundry/ubermold-base/blob/main/k8s/%7B%7Bcookiecutter.project_slug%7D%7D/templates/%7B%25%20if%20cookiecutter.prometheus.config.enabled%20%3D%3D%20%22True%22%20%25%7Dprometheus-config.yaml%7B%25%20endif%20%25%7D) and update chart version

## Resource Requirements

This section shows the resource requirements for different deployment configurations and resource tiers.
Resource tiers control the default CPU, memory, and storage allocations for all components.

### Control Plane Only

Minimal control plane deployment without LLM Gateway components.

| Resource Tier | CPU Requests | CPU Limits | Memory Requests | Memory Limits | Ephemeral Storage | PVC Storage |
|---------------|--------------|------------|-----------------|---------------|-------------------|-------------|
| small | 800m | 1.60 | 1.94 | 3.88 | 4.00 | 30.00 |
| medium | 6.00 | 12.00 | 16.67 | 33.34 | 5.60 | 230.00 |
| large | 14.00 | 28.00 | 32.06 | 64.12 | 7.10 | 230.00 |

### Control Plane + LLM Gateway

Full control plane deployment with LLM Gateway components enabled.

| Resource Tier | CPU Requests | CPU Limits | Memory Requests | Memory Limits | Ephemeral Storage | PVC Storage |
|---------------|--------------|------------|-----------------|---------------|-------------------|-------------|
| small | 3.95 | 5.90 | 10.12 | 17.12 | 18.97 | 40.00 |
| medium | 11.90 | 17.80 | 31.20 | 48.34 | 46.13 | 40.00 |
| large | 29.30 | 44.60 | 73.03 | 110.12 | 90.20 | 40.00 |

### LLM Gateway Only (Agent Mode)

Standalone LLM Gateway deployment connecting to an external control plane.

| Resource Tier | CPU Requests | CPU Limits | Memory Requests | Memory Limits | Ephemeral Storage | PVC Storage |
|---------------|--------------|------------|-----------------|---------------|-------------------|-------------|
| small | 200m | 400m | 512 | 1.00 | 128 | - |
| medium | 1.00 | 2.00 | 2.00 | 4.00 | 256 | - |
| large | 1.00 | 2.00 | 2.00 | 4.00 | 256 | - |

> **Note:** These values are automatically generated from the Helm charts. Actual resource usage may vary based on workload.
> 
> - **small**: Suitable for development and testing environments
> - **medium**: Suitable for small production workloads
> - **large**: Suitable for production environments with higher traffic
