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

| Name                                                                           | Description                                                                                                         | Value             |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `aws-eks-gpu-operator.nfd.enabled`                                             | Enable/Disable node feature discovery.                                                                              | `true`            |
| `aws-eks-gpu-operator.gfd.enabled`                                             | Enable/Disable gpu feature discovery.                                                                               | `true`            |
| `aws-eks-gpu-operator.operator.upgradeCRD`                                     | upgrade CRD on chart upgrade                                                                                        | `true`            |
| `aws-eks-gpu-operator.operator.cleanupCRD`                                     | cleanup CRD on chart uninstall                                                                                      | `true`            |
| `aws-eks-gpu-operator.operator.resources.requests.cpu`                         | CPU request for the operator.                                                                                       | `10m`             |
| `aws-eks-gpu-operator.operator.resources.requests.memory`                      | Memory request for the operator.                                                                                    | `200Mi`           |
| `aws-eks-gpu-operator.operator.resources.limits.cpu`                           | CPU limit for the operator.                                                                                         | `50m`             |
| `aws-eks-gpu-operator.operator.resources.limits.memory`                        | Memory limit for the operator.                                                                                      | `300Mi`           |
| `aws-eks-gpu-operator.driver.enabled`                                          | Enable/Disable driver installation.                                                                                 | `false`           |
| `aws-eks-gpu-operator.toolkit.enabled`                                         | Enable/Disable nvidia container toolkit installation.                                                               | `true`            |
| `aws-eks-gpu-operator.toolkit.version`                                         | Version of the toolkit.                                                                                             | `v1.14.3-centos7` |
| `aws-eks-gpu-operator.devicePlugin.enabled`                                    | Enable/Disable nvidia device plugin installation.                                                                   | `true`            |
| `aws-eks-gpu-operator.node-feature-discovery.enableNodeFeatureApi`             | Enable/Disable node feature api in node-feature-discovery.                                                          | `true`            |
| `aws-eks-gpu-operator.node-feature-discovery.master.resources.requests.cpu`    | CPU request for master node feature discovery.                                                                      | `10m`             |
| `aws-eks-gpu-operator.node-feature-discovery.master.resources.requests.memory` | Memory request for master node feature discovery.                                                                   | `400Mi`           |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.requests.cpu`    | CPU request for worker node feature discovery.                                                                      | `10m`             |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.requests.memory` | Memory request for worker node feature discovery.                                                                   | `100Mi`           |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.limits.cpu`      | CPU limit for worker node feature discovery.                                                                        | `50m`             |
| `aws-eks-gpu-operator.node-feature-discovery.worker.resources.limits.memory`   | Memory limit for worker node feature discovery.                                                                     | `300Mi`           |
| `aws-eks-gpu-operator.node-feature-discovery.gc.enable`                        | Enable node feature discovery garbage collector.                                                                    | `true`            |
| `aws-eks-gpu-operator.node-feature-discovery.gc.interval`                      | Interval between two garbage collection runs.                                                                       | `30m`             |
| `aws-eks-gpu-operator.node-feature-discovery.gc.resources.requests.cpu`        | CPU request for node feature discovery garbage collector.                                                           | `10m`             |
| `aws-eks-gpu-operator.node-feature-discovery.gc.resources.requests.memory`     | Memory request for node feature discovery garbage collector.                                                        | `100Mi`           |
| `aws-eks-gpu-operator.daemonsets.updateStrategy`                               | Update Strategy for Daemonsets - one of ["OnDelete", "RollingUpdate"]                                               | `OnDelete`        |
| `aws-eks-gpu-operator.dcgm.enabled`                                            | Enabled/Disable standalone DCGM.                                                                                    | `false`           |
| `aws-eks-gpu-operator.dcgm.resources.requests.cpu`                             | CPU request for standalone DCGM container                                                                           | `10m`             |
| `aws-eks-gpu-operator.dcgm.resources.requests.memory`                          | Memory request for standalone DCGM container                                                                        | `100Mi`           |
| `aws-eks-gpu-operator.dcgm.resources.limits.cpu`                               | CPU limit for standalone DCGM container                                                                             | `50m`             |
| `aws-eks-gpu-operator.dcgm.resources.limits.memory`                            | Memory limit for standalone DCGM container                                                                          | `400Mi`           |
| `aws-eks-gpu-operator.dcgmExporter.enabled`                                    | Enabled/Disable DCGM Exporter. Requires tfy-karpenter-config >= 0.18 to operate safely because of Nvidia GSP issues | `false`           |
| `aws-eks-gpu-operator.dcgmExporter.serviceMonitor.enabled`                     | Enable or disable ServiceMonitor for DCGM Exporter.                                                                 | `false`           |
| `aws-eks-gpu-operator.dcgmExporter.resources.requests.cpu`                     | CPU request for the DCGM Exporter.                                                                                  | `10m`             |
| `aws-eks-gpu-operator.dcgmExporter.resources.requests.memory`                  | Memory request for the DCGM Exporter.                                                                               | `300Mi`           |
| `aws-eks-gpu-operator.dcgmExporter.resources.limits.cpu`                       | CPU limit for the DCGM Exporter.                                                                                    | `50m`             |
| `aws-eks-gpu-operator.dcgmExporter.resources.limits.memory`                    | Memory limit for the DCGM Exporter.                                                                                 | `400Mi`           |
| `aws-eks-gpu-operator.dcgmExporter.args`                                       | Arguments for the DCGM Exporter.                                                                                    | `["-c","5000"]`   |

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
| `gcp-gke-standard-dcgm-exporter.resources.limits.cpu`           | CPU limit for the DCGM Exporter.                                     | `50m`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.resources.limits.memory`        | Memory limit for the DCGM Exporter.                                  | `400Mi`                                                                                                         |
| `gcp-gke-standard-dcgm-exporter.namespaceOverride`              | Namespace override for the DCGM Exporter.                            | `tfy-gpu-operator`                                                                                              |
| `gcp-gke-standard-dcgm-exporter.serviceMonitor.enabled`         | Enable or disable ServiceMonitor for DCGM Exporter.                  | `false`                                                                                                         |
| `gcp-gke-standard-dcgm-exporter.mapPodsMetrics`                 | Enable mapping of pod metrics.                                       | `true`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.securityContext.privileged`     | Set the container to privileged mode.                                | `true`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.priorityClassName`              | Priority class name for the DCGM Exporter.                           | `""`                                                                                                            |
| `gcp-gke-standard-dcgm-exporter.extraEnv[0].name`               | Name for the additional environment variable for the DCGM Exporter.  | `NVIDIA_INSTALL_DIR_HOST`                                                                                       |
| `gcp-gke-standard-dcgm-exporter.extraEnv[0].value`              | Value for the additional environment variable for the DCGM Exporter. | `/home/kubernetes/bin/nvidia`                                                                                   |
| `gcp-gke-standard-dcgm-exporter.extraHostVolumes[0].name`       | Name for the additional host volume for the DCGM Exporter.           | `dev`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.extraHostVolumes[0].hostPath`   | Host Path for the additional host volume for the DCGM Exporter.      | `/dev`                                                                                                          |
| `gcp-gke-standard-dcgm-exporter.extraVolumeMounts[0].name`      | Name for the additional volume mounts for the DCGM Exporter.         | `dev`                                                                                                           |
| `gcp-gke-standard-dcgm-exporter.extraVolumeMounts[0].mountPath` | Mount Path for the additional volume mounts for the DCGM Exporter.   | `/dev`                                                                                                          |

### azure-aks-gpu-operator Configuration for the Azure AKS GPU operator. This section will only be used when clusterType.azureAks is set to true.

| Name                                                                             | Description                                                                                                                                                | Value                  |
| -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `azure-aks-gpu-operator.nfd.enabled`                                             | Enable/Disable node feature discovery.                                                                                                                     | `true`                 |
| `azure-aks-gpu-operator.gfd.enabled`                                             | Enable/Disable gpu feature discovery.                                                                                                                      | `true`                 |
| `azure-aks-gpu-operator.operator.upgradeCRD`                                     | upgrade CRD on chart upgrade                                                                                                                               | `true`                 |
| `azure-aks-gpu-operator.operator.cleanupCRD`                                     | cleanup CRD on chart uninstall                                                                                                                             | `true`                 |
| `azure-aks-gpu-operator.operator.resources.requests.cpu`                         | CPU request for the operator.                                                                                                                              | `10m`                  |
| `azure-aks-gpu-operator.operator.resources.requests.memory`                      | Memory request for the operator.                                                                                                                           | `100Mi`                |
| `azure-aks-gpu-operator.operator.resources.limits.cpu`                           | CPU limit for the operator.                                                                                                                                | `50m`                  |
| `azure-aks-gpu-operator.operator.resources.limits.memory`                        | Memory limit for the operator.                                                                                                                             | `300Mi`                |
| `azure-aks-gpu-operator.node-feature-discovery.enableNodeFeatureApi`             | Enable/Disable node feature api in node-feature-discovery.                                                                                                 | `true`                 |
| `azure-aks-gpu-operator.node-feature-discovery.master.resources.requests.cpu`    | CPU request for master node feature discovery.                                                                                                             | `10m`                  |
| `azure-aks-gpu-operator.node-feature-discovery.master.resources.requests.memory` | Memory request for master node feature discovery.                                                                                                          | `200Mi`                |
| `azure-aks-gpu-operator.node-feature-discovery.worker.resources.requests.cpu`    | CPU request for worker node feature discovery.                                                                                                             | `10m`                  |
| `azure-aks-gpu-operator.node-feature-discovery.worker.resources.requests.memory` | Memory request for worker node feature discovery.                                                                                                          | `100Mi`                |
| `azure-aks-gpu-operator.node-feature-discovery.worker.resources.limits.cpu`      | CPU limit for worker node feature discovery.                                                                                                               | `50m`                  |
| `azure-aks-gpu-operator.node-feature-discovery.worker.resources.limits.memory`   | Memory limit for worker node feature discovery.                                                                                                            | `300Mi`                |
| `azure-aks-gpu-operator.node-feature-discovery.gc.enable`                        | Enable node feature discovery garbage collector.                                                                                                           | `true`                 |
| `azure-aks-gpu-operator.node-feature-discovery.gc.interval`                      | Interval between two garbage collection runs.                                                                                                              | `30m`                  |
| `azure-aks-gpu-operator.node-feature-discovery.gc.resources.requests.cpu`        | CPU request for node feature discovery garbage collector.                                                                                                  | `10m`                  |
| `azure-aks-gpu-operator.node-feature-discovery.gc.resources.requests.memory`     | Memory request for node feature discovery garbage collector.                                                                                               | `100Mi`                |
| `azure-aks-gpu-operator.daemonsets.updateStrategy`                               | Update Strategy for Daemonsets - one of ["OnDelete", "RollingUpdate"]                                                                                      | `OnDelete`             |
| `azure-aks-gpu-operator.daemonsets.priorityClassName`                            | Priority class for Daemonsets                                                                                                                              | `system-node-critical` |
| `azure-aks-gpu-operator.driver.enabled`                                          | Enable/Disable driver installation.                                                                                                                        | `false`                |
| `azure-aks-gpu-operator.toolkit.enabled`                                         | Enable/Disable nvidia container toolkit installation.                                                                                                      | `true`                 |
| `azure-aks-gpu-operator.toolkit.version`                                         | Version of the toolkit. Note for Aure Linux change `-ubuntu20.04` to `-centos7`. However at the time of writing Azure Linux only supports V100 and T4 GPUs | `v1.14.5-ubuntu20.04`  |
| `azure-aks-gpu-operator.mig.strategy`                                            | migStrategy for mig node, single or mixed                                                                                                                  | `mixed`                |
| `azure-aks-gpu-operator.devicePlugin.enabled`                                    | Enable/Disable nvidia device plugin installation.                                                                                                          | `true`                 |
| `azure-aks-gpu-operator.dcgm.enabled`                                            | Enabled/Disable standalone DCGM.                                                                                                                           | `false`                |
| `azure-aks-gpu-operator.dcgm.resources.requests.cpu`                             | CPU request for standalone DCGM container                                                                                                                  | `10m`                  |
| `azure-aks-gpu-operator.dcgm.resources.requests.memory`                          | Memory request for standalone DCGM container                                                                                                               | `100Mi`                |
| `azure-aks-gpu-operator.dcgm.resources.limits.cpu`                               | CPU limit for standalone DCGM container                                                                                                                    | `50m`                  |
| `azure-aks-gpu-operator.dcgm.resources.limits.memory`                            | Memory limit for standalone DCGM container                                                                                                                 | `400Mi`                |
| `azure-aks-gpu-operator.dcgmExporter.enabled`                                    | Enabled/Disable DCGM Exporter.                                                                                                                             | `true`                 |
| `azure-aks-gpu-operator.dcgmExporter.serviceMonitor.enabled`                     | Enable or disable ServiceMonitor for DCGM Exporter.                                                                                                        | `false`                |
| `azure-aks-gpu-operator.dcgmExporter.resources.requests.cpu`                     | CPU request for the DCGM Exporter.                                                                                                                         | `10m`                  |
| `azure-aks-gpu-operator.dcgmExporter.resources.requests.memory`                  | Memory request for the DCGM Exporter.                                                                                                                      | `100Mi`                |
| `azure-aks-gpu-operator.dcgmExporter.resources.limits.cpu`                       | CPU limit for the DCGM Exporter.                                                                                                                           | `50m`                  |
| `azure-aks-gpu-operator.dcgmExporter.resources.limits.memory`                    | Memory limit for the DCGM Exporter.                                                                                                                        | `400Mi`                |
| `azure-aks-gpu-operator.dcgmExporter.args`                                       | Arguments for the DCGM Exporter.                                                                                                                           | `["-c","5000"]`        |

### civo-talos-gpu-operator Configuration for the Civo Talos GPU Operator. This section will only be used when clusterType.civoTalos is set to true.

| Name                                                                              | Description                                                  | Value           |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------ | --------------- |
| `civo-talos-gpu-operator.nfd.enabled`                                             | Enable/Disable node feature discovery.                       | `true`          |
| `civo-talos-gpu-operator.gfd.enabled`                                             | Enable/Disable gpu feature discovery.                        | `true`          |
| `civo-talos-gpu-operator.operator.upgradeCRD`                                     | upgrade CRD on chart upgrade                                 | `true`          |
| `civo-talos-gpu-operator.operator.cleanupCRD`                                     | cleanup CRD on chart uninstall                               | `true`          |
| `civo-talos-gpu-operator.operator.resources.requests.cpu`                         | CPU request for the operator.                                | `10m`           |
| `civo-talos-gpu-operator.operator.resources.requests.memory`                      | Memory request for the operator.                             | `100Mi`         |
| `civo-talos-gpu-operator.operator.resources.limits.cpu`                           | CPU limit for the operator.                                  | `50m`           |
| `civo-talos-gpu-operator.operator.resources.limits.memory`                        | Memory limit for the operator.                               | `300Mi`         |
| `civo-talos-gpu-operator.node-feature-discovery.enableNodeFeatureApi`             | Enable/Disable node feature api in node-feature-discovery.   | `true`          |
| `civo-talos-gpu-operator.node-feature-discovery.master.resources.requests.cpu`    | CPU request for master node feature discovery.               | `10m`           |
| `civo-talos-gpu-operator.node-feature-discovery.master.resources.requests.memory` | Memory request for master node feature discovery.            | `200Mi`         |
| `civo-talos-gpu-operator.node-feature-discovery.worker.resources.requests.cpu`    | CPU request for worker node feature discovery.               | `10m`           |
| `civo-talos-gpu-operator.node-feature-discovery.worker.resources.requests.memory` | Memory request for worker node feature discovery.            | `100Mi`         |
| `civo-talos-gpu-operator.node-feature-discovery.worker.resources.limits.cpu`      | CPU limit for worker node feature discovery.                 | `50m`           |
| `civo-talos-gpu-operator.node-feature-discovery.worker.resources.limits.memory`   | Memory limit for worker node feature discovery.              | `300Mi`         |
| `civo-talos-gpu-operator.node-feature-discovery.gc.enable`                        | Enable node feature discovery garbage collector.             | `true`          |
| `civo-talos-gpu-operator.node-feature-discovery.gc.interval`                      | Interval between two garbage collection runs.                | `30m`           |
| `civo-talos-gpu-operator.node-feature-discovery.gc.resources.requests.cpu`        | CPU request for node feature discovery garbage collector.    | `10m`           |
| `civo-talos-gpu-operator.node-feature-discovery.gc.resources.requests.memory`     | Memory request for node feature discovery garbage collector. | `100Mi`         |
| `civo-talos-gpu-operator.driver.enabled`                                          | Enable/Disable driver installation.                          | `false`         |
| `civo-talos-gpu-operator.toolkit.enabled`                                         | Enable/Disable nvidia container toolkit installation.        | `false`         |
| `civo-talos-gpu-operator.devicePlugin.enabled`                                    | Enable/Disable nvidia device plugin installation.            | `true`          |
| `civo-talos-gpu-operator.dcgm.enabled`                                            | Enabled/Disable standalone DCGM.                             | `true`          |
| `civo-talos-gpu-operator.dcgm.resources.requests.cpu`                             | CPU request for standalone DCGM container                    | `10m`           |
| `civo-talos-gpu-operator.dcgm.resources.requests.memory`                          | Memory request for standalone DCGM container                 | `100Mi`         |
| `civo-talos-gpu-operator.dcgm.resources.limits.cpu`                               | CPU limit for standalone DCGM container                      | `50m`           |
| `civo-talos-gpu-operator.dcgm.resources.limits.memory`                            | Memory limit for standalone DCGM container                   | `400Mi`         |
| `civo-talos-gpu-operator.dcgmExporter.enabled`                                    | Enabled/Disable DCGM Exporter.                               | `true`          |
| `civo-talos-gpu-operator.dcgmExporter.serviceMonitor.enabled`                     | Enable or disable ServiceMonitor for DCGM Exporter.          | `false`         |
| `civo-talos-gpu-operator.dcgmExporter.resources.requests.cpu`                     | CPU request for the DCGM Exporter.                           | `10m`           |
| `civo-talos-gpu-operator.dcgmExporter.resources.requests.memory`                  | Memory request for the DCGM Exporter.                        | `100Mi`         |
| `civo-talos-gpu-operator.dcgmExporter.resources.limits.cpu`                       | CPU limit for the DCGM Exporter.                             | `50m`           |
| `civo-talos-gpu-operator.dcgmExporter.resources.limits.memory`                    | Memory limit for the DCGM Exporter.                          | `400Mi`         |
| `civo-talos-gpu-operator.dcgmExporter.args`                                       | Arguments for the DCGM Exporter.                             | `["-c","5000"]` |
