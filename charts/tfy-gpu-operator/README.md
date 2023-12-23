# Tfy-gpu-operator helm chart packaged by TrueFoundry
Tfy-gpu-operator is a Helm chart that facilitates the deployment and management of GPU resources in Kubernetes clusters.

## Parameters

### Configuration for the cluster type flags.

| Name                          | Description                                     | Value   |
| ----------------------------- | ----------------------------------------------- | ------- |
| `clusterType.awsEks`          | Flag indicating AWS EKS cluster type.           | `false` |
| `clusterType.gcpGkeStandard`  | Flag indicating GCP GKE Standard cluster type.  | `false` |
| `clusterType.gcpGkeAutopilot` | Flag indicating GCP GKE Autopilot cluster type. | `false` |
| `clusterType.azureAks`        | Flag indicating Azure AKS cluster type.         | `false` |
| `clusterType.civoTalos`       | Flag indicating Civo Talos cluster type.        | `false` |

### aws-eks-gpu-operator Configuration for the AWS EKS GPU Operator. This section will only be used when clusterType.awsEks is set to true.

| Name                                                                           | Description                                                           | Value                     |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------- | ------------------------- |
| `aws-eks-gpu-operator.driver.enabled`                                          | Enabled/Disable driver installation.                                  | `false`                   |
| `aws-eks-gpu-operator.operator.resources.requests.cpu`                         | CPU request for the operator.                                         | `10m`                     |
| `aws-eks-gpu-operator.operator.resources.requests.memory`                      | Memory request for the operator.                                      | `200Mi`                   |
| `aws-eks-gpu-operator.operator.resources.limits.cpu`                           | CPU limit for the operator.                                           | `50m`                     |
| `aws-eks-gpu-operator.operator.resources.limits.memory`                        | Memory limit for the operator.                                        | `300Mi`                   |
| `aws-eks-gpu-operator.toolkit.version`                                         | Version of the toolkit.                                               | `v1.13.5-centos7`         |
| `aws-eks-gpu-operator.node-feature-discovery.master.resources.requests.cpu`    | CPU request for master node feature discovery.                        | `10m`                     |
| `aws-eks-gpu-operator.node-feature-discovery.master.resources.requests.memory` | Memory request for master node feature discovery.                     | `400Mi`                   |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.requests.cpu`    | CPU request for worker node feature discovery.                        | `10m`                     |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.requests.memory` | Memory request for worker node feature discovery.                     | `100Mi`                   |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.limits.cpu`      | CPU limit for worker node feature discovery.                          | `50m`                     |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.limits.memory`   | Memory limit for worker node feature discovery.                       | `300Mi`                   |
| `aws-eks-gpu-operator.node-feature-discovery.gc.enable`                        | Enable node feature discovery garbage collector.                      | `true`                    |
| `aws-eks-gpu-operator.node-feature-discovery.gc.interval`                      | Interval between two garbage collection runs.                         | `30m`                     |
| `aws-eks-gpu-operator.node-feature-discovery.gc.resources.requests.cpu`        | CPU request for node feature discovery garbage collector.             | `10m`                     |
| `aws-eks-gpu-operator.node-feature-discovery.gc.resources.requests.memory`     | Memory request for node feature discovery garbage collector.          | `100Mi`                   |
| `aws-eks-gpu-operator.daemonsets.updateStrategy`                               | Update Strategy for Daemonsets - one of ["OnDelete", "RollingUpdate"] | `OnDelete`                |
| `aws-eks-gpu-operator.validator.plugin.env[0].name`                            | Name of the Evironment Variable for the Validator Plugin              | `WITH_WORKLOAD`           |
| `aws-eks-gpu-operator.validator.plugin.env[0].value`                           | Value of the Evironment Variable for the Validator Plugin             | `false`                   |
| `aws-eks-gpu-operator.dcgmExporter.enabled`                                    | Enabled/Disable DCGM Exporter.                                        | `false`                   |
| `aws-eks-gpu-operator.dcgmExporter.version`                                    | Version of the DCGM Exporter.                                         | `3.1.7-3.1.4-ubuntu20.04` |
| `aws-eks-gpu-operator.dcgmExporter.resources.requests.cpu`                     | CPU request for the DCGM Exporter.                                    | `10m`                     |
| `aws-eks-gpu-operator.dcgmExporter.resources.requests.memory`                  | Memory request for the DCGM Exporter.                                 | `300Mi`                   |
| `aws-eks-gpu-operator.dcgmExporter.resources.limits.cpu`                       | CPU limit for the DCGM Exporter.                                      | `100m`                    |
| `aws-eks-gpu-operator.dcgmExporter.resources.limits.memory`                    | Memory limit for the DCGM Exporter.                                   | `400Mi`                   |
| `aws-eks-gpu-operator.dcgmExporter.args`                                       | Arguments for the DCGM Exporter.                                      | `["-c","5000"]`           |
| `aws-eks-gpu-operator.dcgmExporter.serviceMonitor.enabled`                     | Enable or disable ServiceMonitor for DCGM Exporter.                   | `false`                   |

### gcp-gke-standard-driver Configuration for the GKE Standard Nvidia Drivers. This section will only be used when clusterType.gcpGkeStandard is set to true.

| Name                                             | Description                                       | Value           |
| ------------------------------------------------ | ------------------------------------------------- | --------------- |
| `gcp-gke-standard-driver.latest.gkeAccelerators` | Install latest driver for these GKE accelerators. | `["nvidia-l4"]` |

### gcp-gke-standard-dcgm-exporter Configuration for the GCP GKE Standard DCGM Exporter. This section will only be used when clusterType.gcpGkeStandard is set to true.

| Name                                                            | Description                                                          | Value                                                                                                           |
| --------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `gcp-gke-standard-dcgm-exporter.image.tag`                      | Docker image tag for the DCGM Exporter.                              | `3.1.7-3.1.4-ubuntu20.04`                                                                                       |
| `gcp-gke-standard-dcgm-exporter.arguments`                      | Arguments for the DCGM Exporter.                                     | `["-c","\"5000\"","-f","/etc/dcgm-exporter/dcp-metrics-included.csv","--kubernetes-gpu-id-type","device-name"]` |
| `gcp-gke-standard-dcgm-exporter.resources.requests.cpu`         | CPU request for the DCGM Exporter.                                   | `10m`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.resources.requests.memory`      | Memory request for the DCGM Exporter.                                | `300Mi`                                                                                                         |
| `gcp-gke-standard-dcgm-exporter.resources.limits.cpu`           | CPU limit for the DCGM Exporter.                                     | `100m`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.resources.limits.memory`        | Memory limit for the DCGM Exporter.                                  | `400Mi`                                                                                                         |
| `gcp-gke-standard-dcgm-exporter.namespaceOverride`              | Namespace override for the DCGM Exporter.                            | `tfy-gpu-operator`                                                                                              |
| `gcp-gke-standard-dcgm-exporter.serviceMonitor.enabled`         | Enable or disable ServiceMonitor for DCGM Exporter.                  | `false`                                                                                                         |
| `gcp-gke-standard-dcgm-exporter.tolerations[0].operator`        | Toleration configuration for worker nodes.                           | `Exists`                                                                                                        |
| `gcp-gke-standard-dcgm-exporter.mapPodsMetrics`                 | Enable mapping of pod metrics.                                       | `true`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.securityContext.privileged`     | Set the container to privileged mode.                                | `true`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.priorityClassName`              | Priority class name for the DCGM Exporter.                           | `""`                                                                                                            |
| `gcp-gke-standard-dcgm-exporter.extraEnv[0].name`               | Name for the additional environment variable for the DCGM Exporter.  | `NVIDIA_INSTALL_DIR_HOST`                                                                                       |
| `gcp-gke-standard-dcgm-exporter.extraEnv[0].value`              | Value for the additional environment variable for the DCGM Exporter. | `/home/kubernetes/bin/nvidia`                                                                                   |
| `gcp-gke-standard-dcgm-exporter.extraHostVolumes[0].name`       | Name for the additional host volume for the DCGM Exporter.           | `dev`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.extraHostVolumes[0].hostPath`   | Host Path for the additional host volume for the DCGM Exporter.      | `/dev`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.extraVolumeMounts[0].name`      | Name for the additional volume mounts for the DCGM Exporter.         | `dev`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.extraVolumeMounts[0].mountPath` | Mount Path for the additional volume mounts for the DCGM Exporter.   | `/dev`                                                                                                          |

### azure-aks-dcgm-exporter Configuration for the Azure AKS DCGM Exporter. This section will only be used when clusterType.azureAks is set to true.

| Name                                                     | Description                                                           | Value                                                                  |
| -------------------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `azure-aks-dcgm-exporter.image.tag`                      | Docker image tag for the DCGM Exporter.                               | `3.1.7-3.1.4-ubuntu20.04`                                              |
| `azure-aks-dcgm-exporter.arguments`                      | Arguments for the DCGM Exporter.                                      | `["-c","\"5000\"","-f","/etc/dcgm-exporter/dcp-metrics-included.csv"]` |
| `azure-aks-dcgm-exporter.resources.requests.cpu`         | CPU request for the DCGM Exporter.                                    | `10m`                                                                  |
| `azure-aks-dcgm-exporter.resources.requests.memory`      | Memory request for the DCGM Exporter.                                 | `300Mi`                                                                |
| `azure-aks-dcgm-exporter.resources.limits.cpu`           | CPU limit for the DCGM Exporter.                                      | `100m`                                                                 |
| `azure-aks-dcgm-exporter.resources.limits.memory`        | Memory limit for the DCGM Exporter.                                   | `400Mi`                                                                |
| `azure-aks-dcgm-exporter.namespaceOverride`              | Namespace override for the DCGM Exporter.                             | `tfy-gpu-operator`                                                     |
| `azure-aks-dcgm-exporter.serviceMonitor.enabled`         | Enable or disable ServiceMonitor for DCGM Exporter.                   | `false`                                                                |
| `azure-aks-dcgm-exporter.mapPodsMetrics`                 | Enable or disable mapping of pod metrics.                             | `true`                                                                 |
| `azure-aks-dcgm-exporter.securityContext.privileged`     | Set the container to privileged mode.                                 | `true`                                                                 |
| `azure-aks-dcgm-exporter.priorityClassName`              | Priority class name for the DCGM Exporter.                            | `""`                                                                   |
| `azure-aks-dcgm-exporter.extraEnv[0].name`               | Name for the additional environment variables for the DCGM Exporter.  | `NVIDIA_INSTALL_DIR_HOST`                                              |
| `azure-aks-dcgm-exporter.extraEnv[0].value`              | Value for the additional environment variables for the DCGM Exporter. | `/home/kubernetes/bin/nvidia`                                          |
| `azure-aks-dcgm-exporter.extraHostVolumes[0].name`       | Name for the additional host volumes for the DCGM Exporter.           | `dev`                                                                  |
| `azure-aks-dcgm-exporter.extraHostVolumes[0].hostPath`   | Host Path for the additional host volumes for the DCGM Exporter.      | `/dev`                                                                 |
| `azure-aks-dcgm-exporter.extraVolumeMounts[0].name`      | Name for the additional volume mounts for the DCGM Exporter.          | `dev`                                                                  |
| `azure-aks-dcgm-exporter.extraVolumeMounts[0].mountPath` | Mount Path for the additional volume mounts for the DCGM Exporter.    | `/dev`                                                                 |

### civo-talos-nvidia-device-plugin Configuration for the Civo Talos Nvidia Device Plugin. This section will only be used when clusterType.civoTalos is set to true.

| Name                                                   | Description                                                                | Value              |
| ------------------------------------------------------ | -------------------------------------------------------------------------- | ------------------ |
| `civo-talos-nvidia-device-plugin.namespaceOverride`    | Namespace override for the Device Plugin.                                  | `tfy-gpu-operator` |
| `civo-talos-nvidia-device-plugin.updateStrategy.type`  | Update Strategy for Daemonsets - one of ["OnDelete", "RollingUpdate"]      | `OnDelete`         |
| `civo-talos-nvidia-device-plugin.compatWithCPUManager` | Enable compatibility with CPUManager and PASS_DEVICE_SPECS                 | `true`             |
| `civo-talos-nvidia-device-plugin.deviceListStrategy`   | How device plugin should list devices - one of ["volume-mounts", "envvar"] | `volume-mounts`    |
| `civo-talos-nvidia-device-plugin.deviceIDStrategy`     | How device plugin should pass device IDs - one of ["uuid", "index"]        | `index`            |
