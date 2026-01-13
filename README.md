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

- **small**: Suitable for development and testing environments
- **medium**: Suitable for small production workloads
- **large**: Suitable for production environments with higher traffic

> **Note:** Values shown are totals (per-pod resources × replica count).

### Control Plane Only

Minimal control plane deployment without LLM Gateway components.

#### SMALL

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| frontend-app | Deployment | 1 | 50m | 100m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| mlfoundry-server | Deployment | 1 | 100m | 200m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| servicefoundry-server | Deployment | 1 | 100m | 200m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| sfy-manifest-service | Deployment | 1 | 50m | 100m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| tfy-controller | Deployment | 1 | 50m | 100m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| tfy-k8s-controller | Deployment | 1 | 100m | 200m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-proxy | Deployment | 1 | 50m | 100m | 64 MiB | 128 MiB | 256 MiB | 512 MiB | - |
| **TOTAL** | - | - | **800m** | **1.60 cores** | **1.94 GiB** | **3.88 GiB** | **4.00 GiB** | **8.00 GiB** | **30.00 GiB** |

#### MEDIUM

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| frontend-app | Deployment | 3 | 300m | 600m | 1.17 GiB | 2.34 GiB | 384 MiB | 768 MiB | - |
| mlfoundry-server | Deployment | 3 | 600m | 1.20 cores | 3.00 GiB | 6.00 GiB | 384 MiB | 768 MiB | - |
| servicefoundry-server | Deployment | 3 | 1.50 cores | 3.00 cores | 3.00 GiB | 6.00 GiB | 768 MiB | 1.50 GiB | - |
| sfy-manifest-service | Deployment | 2 | 100m | 200m | 256 MiB | 512 MiB | 256 MiB | 512 MiB | - |
| tfy-buildkitd-service | StatefulSet | 1 | 2.50 cores | 5.00 cores | 8.00 GiB | 16.00 GiB | 100 MiB | 100 MiB | 200.00 GiB |
| tfy-controller | Deployment | 1 | 100m | 200m | 256 MiB | 512 MiB | 128 MiB | 256 MiB | - |
| tfy-k8s-controller | Deployment | 1 | 500m | 1.00 cores | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-proxy | Deployment | 1 | 100m | 200m | 128 MiB | 256 MiB | 512 MiB | 1.00 GiB | - |
| **TOTAL** | - | - | **6.00 cores** | **12.00 cores** | **16.67 GiB** | **33.34 GiB** | **5.60 GiB** | **11.10 GiB** | **230.00 GiB** |

#### LARGE

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| frontend-app | Deployment | 5 | 1.50 cores | 3.00 cores | 3.91 GiB | 7.81 GiB | 640 MiB | 1.25 GiB | - |
| mlfoundry-server | Deployment | 5 | 3.00 cores | 6.00 cores | 7.50 GiB | 15.00 GiB | 640 MiB | 1.25 GiB | - |
| servicefoundry-server | Deployment | 5 | 5.00 cores | 10.00 cores | 10.00 GiB | 20.00 GiB | 1.25 GiB | 5.00 GiB | - |
| sfy-manifest-service | Deployment | 2 | 200m | 400m | 512 MiB | 1.00 GiB | 256 MiB | 512 MiB | - |
| tfy-buildkitd-service | StatefulSet | 1 | 2.50 cores | 5.00 cores | 8.00 GiB | 16.00 GiB | 100 MiB | 100 MiB | 200.00 GiB |
| tfy-controller | Deployment | 1 | 500m | 1.00 cores | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| tfy-k8s-controller | Deployment | 1 | 500m | 1.00 cores | 800 MiB | 1.56 GiB | 128 MiB | 256 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-proxy | Deployment | 1 | 500m | 1.00 cores | 512 MiB | 1.00 GiB | 1.00 GiB | 2.00 GiB | - |
| **TOTAL** | - | - | **14.00 cores** | **28.00 cores** | **32.06 GiB** | **64.12 GiB** | **7.10 GiB** | **16.60 GiB** | **230.00 GiB** |

### Control Plane with Gateway

Full control plane deployment with LLM Gateway components enabled.

#### SMALL

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| deltafusion-compaction | CronJob | 1 | 1.00 cores | 2.00 cores | 1.95 GiB | 2.34 GiB | 9.77 GiB | 9.77 GiB | - |
| deltafusion-ingestor | StatefulSet | 2 | 1.00 cores | 2.00 cores | 1.95 GiB | 2.34 GiB | 200 MiB | 200 MiB | 10.00 GiB |
| deltafusion-query-server | Deployment | 1 | 1.00 cores | 0m | 3.91 GiB | 7.81 GiB | 4.88 GiB | 9.77 GiB | - |
| frontend-app | Deployment | 1 | 50m | 100m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| mlfoundry-server | Deployment | 1 | 100m | 200m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| servicefoundry-server | Deployment | 1 | 100m | 200m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| tfy-k8s-controller | Deployment | 1 | 100m | 200m | 128 MiB | 256 MiB | 128 MiB | 256 MiB | - |
| tfy-llm-gateway | Deployment | 1 | 200m | 400m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-otel-collector | Deployment | 1 | 50m | 100m | 128 MiB | 256 MiB | 256 MiB | 512 MiB | - |
| tfy-proxy | Deployment | 1 | 50m | 100m | 64 MiB | 128 MiB | 256 MiB | 512 MiB | - |
| **TOTAL** | - | - | **3.95 cores** | **5.90 cores** | **10.12 GiB** | **17.12 GiB** | **18.97 GiB** | **27.98 GiB** | **40.00 GiB** |

#### MEDIUM

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| deltafusion-compaction | CronJob | 1 | 2.00 cores | 4.00 cores | 3.91 GiB | 4.69 GiB | 19.53 GiB | 19.53 GiB | - |
| deltafusion-ingestor | StatefulSet | 2 | 2.00 cores | 4.00 cores | 3.91 GiB | 4.69 GiB | 200 MiB | 200 MiB | 10.00 GiB |
| deltafusion-query-server | Deployment | 1 | 3.00 cores | 0m | 11.72 GiB | 15.62 GiB | 19.53 GiB | 19.53 GiB | - |
| frontend-app | Deployment | 3 | 300m | 600m | 1.17 GiB | 2.34 GiB | 384 MiB | 768 MiB | - |
| mlfoundry-server | Deployment | 3 | 600m | 1.20 cores | 3.00 GiB | 6.00 GiB | 384 MiB | 768 MiB | - |
| servicefoundry-server | Deployment | 3 | 1.50 cores | 3.00 cores | 3.00 GiB | 6.00 GiB | 768 MiB | 1.50 GiB | - |
| tfy-k8s-controller | Deployment | 1 | 500m | 1.00 cores | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| tfy-llm-gateway | Deployment | 1 | 1.00 cores | 2.00 cores | 2.00 GiB | 4.00 GiB | 256 MiB | 512 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-otel-collector | Deployment | 3 | 600m | 1.20 cores | 1.50 GiB | 3.00 GiB | 1.50 GiB | 3.00 GiB | - |
| tfy-proxy | Deployment | 1 | 100m | 200m | 128 MiB | 256 MiB | 512 MiB | 1.00 GiB | - |
| **TOTAL** | - | - | **11.90 cores** | **17.80 cores** | **31.20 GiB** | **48.34 GiB** | **46.13 GiB** | **53.01 GiB** | **40.00 GiB** |

#### LARGE

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| deltafusion-compaction | CronJob | 1 | 4.00 cores | 8.00 cores | 7.81 GiB | 9.38 GiB | 39.06 GiB | 39.06 GiB | - |
| deltafusion-ingestor | StatefulSet | 2 | 4.00 cores | 8.00 cores | 7.81 GiB | 9.38 GiB | 200 MiB | 200 MiB | 10.00 GiB |
| deltafusion-query-server | Deployment | 1 | 7.00 cores | 0m | 27.34 GiB | 31.25 GiB | 39.06 GiB | 39.06 GiB | - |
| frontend-app | Deployment | 5 | 1.50 cores | 3.00 cores | 3.91 GiB | 7.81 GiB | 640 MiB | 1.25 GiB | - |
| mlfoundry-server | Deployment | 5 | 3.00 cores | 6.00 cores | 7.50 GiB | 15.00 GiB | 640 MiB | 1.25 GiB | - |
| servicefoundry-server | Deployment | 5 | 5.00 cores | 10.00 cores | 10.00 GiB | 20.00 GiB | 1.25 GiB | 5.00 GiB | - |
| tfy-k8s-controller | Deployment | 1 | 500m | 1.00 cores | 800 MiB | 1.56 GiB | 128 MiB | 256 MiB | - |
| tfy-llm-gateway | Deployment | 1 | 1.00 cores | 2.00 cores | 2.00 GiB | 4.00 GiB | 256 MiB | 512 MiB | - |
| tfy-nats | StatefulSet | 3 | 300m | 600m | 384 MiB | 768 MiB | 3.00 GiB | 6.00 GiB | 30.00 GiB |
| tfy-otel-collector | Deployment | 5 | 2.50 cores | 5.00 cores | 5.00 GiB | 10.00 GiB | 5.00 GiB | 10.00 GiB | - |
| tfy-proxy | Deployment | 1 | 500m | 1.00 cores | 512 MiB | 1.00 GiB | 1.00 GiB | 2.00 GiB | - |
| **TOTAL** | - | - | **29.30 cores** | **44.60 cores** | **73.03 GiB** | **110.12 GiB** | **90.20 GiB** | **104.57 GiB** | **40.00 GiB** |

### Gateway Only

Standalone LLM Gateway deployment connecting to an external control plane.

#### SMALL

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| tfy-llm-gateway | Deployment | 1 | 200m | 400m | 512 MiB | 1.00 GiB | 128 MiB | 256 MiB | - |
| **TOTAL** | - | - | **200m** | **400m** | **512 MiB** | **1.00 GiB** | **128 MiB** | **256 MiB** | **-** |

#### MEDIUM

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| tfy-llm-gateway | Deployment | 1 | 1.00 cores | 2.00 cores | 2.00 GiB | 4.00 GiB | 256 MiB | 512 MiB | - |
| **TOTAL** | - | - | **1.00 cores** | **2.00 cores** | **2.00 GiB** | **4.00 GiB** | **256 MiB** | **512 MiB** | **-** |

#### LARGE

| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |
|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|
| tfy-llm-gateway | Deployment | 1 | 1.00 cores | 2.00 cores | 2.00 GiB | 4.00 GiB | 256 MiB | 512 MiB | - |
| **TOTAL** | - | - | **1.00 cores** | **2.00 cores** | **2.00 GiB** | **4.00 GiB** | **256 MiB** | **512 MiB** | **-** |

