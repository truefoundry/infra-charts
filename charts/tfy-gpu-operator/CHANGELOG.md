## Changelog

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
