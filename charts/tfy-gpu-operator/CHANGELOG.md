## Changelog

### 0.6.0-rc.1

- Update NVIDIA GPU Operator to v26.7.2
- Update GKE standalone DCGM Exporter chart to 4.8.4
- Align toolkit (`v1.20.1`), device plugin (`v0.20.1`), DCGM (`4.6.1-1-ubuntu24.04`), and DCGM Exporter (`4.6.1-4.8.4-distroless`) pins with GPU Operator v26.7.2
- Remove unused GKE `mapPodsMetrics` value (no-op in upstream dcgm-exporter)

If you are applying this chart using ArgoCD, you need to apply the following CRDs:

```shell
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_gpuclusters.yaml
```

### 0.5.0-rc.3

- [aws-eks] Add g7 instance types to NFD worker, NFD garbage collector, and fakeToolkitReady node affinities

### 0.5.0-rc.2

- [aws-eks] Enable CDI
- [generic] Enable CDI

### 0.5.0-rc.1

- Update NVIDIA GPU Operator to v25.10.1

If you are applying this chart using ArgoCD, you need to apply the following CRDs:

```shell
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v25.10.1/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v25.10.1/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml
```
