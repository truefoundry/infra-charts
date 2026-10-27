## Changelog

### 0.5.0-rc.4

- Update NVIDIA GPU Operator to v26.7.2
- Update DCGM Exporter to 4.8.4

v26.7.2 ships three CRDs that v25.10.1 did not (`gpuclusters`, `computedomains`,
`computedomaincliques`). If you are applying this chart using ArgoCD, you need to apply
the following CRDs:

```shell
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/nvidia.com_gpuclusters.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/resource.nvidia.com_computedomains.yaml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/v26.7.2/deployments/gpu-operator/crds/resource.nvidia.com_computedomaincliques.yaml
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
