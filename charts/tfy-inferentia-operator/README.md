# Tfy-inferentia-operator helm chart packaged by TrueFoundry
Tfy-inferentia-operator is a Helm chart that facilitates the deployment and management of AWS Inferentia resources in Kubernetes clusters.

Refer to,


* https://github.com/aws-neuron/aws-neuron-sdk/blob/e0ef8a1a780ee798e7f01fe94f1235d571e211c6/src/k8/k8s-neuron-device-plugin.yml#L1
* https://awsdocs-neuron.readthedocs-hosted.com/en/latest/containers/kubernetes-getting-started.html


## Parameters

### Configuration for the device plugin responsible for node feature discovery

| Name                                     | Description                                          | Value                                        |
| ---------------------------------------- | ---------------------------------------------------- | -------------------------------------------- |
| `devicePlugin.enabled`                   | Enable device plugin Daemonset.                      | `true`                                       |
| `devicePlugin.resources.requests.cpu`    | CPU request for device plugin Daemonset.             | `100m`                                       |
| `devicePlugin.resources.requests.memory` | Memory request for device plugin Daemonset.          | `128Mi`                                      |
| `devicePlugin.resources.limits.cpu`      | CPU limit for device plugin Daemonset.               | `400m`                                       |
| `devicePlugin.resources.limits.memory`   | Memory limit for device plugin Daemonset.            | `256Mi`                                      |
| `devicePlugin.image.repository`          | Image repository to use for device plugin Daemonset. | `public.ecr.aws/neuron/neuron-device-plugin` |
| `devicePlugin.image.tag`                 | Image tag to use for device plugin Daemonset.        | `2.23.30.0`                                  |
| `imagePullSecrets`                       | (global) List of image pull secrets                  | `[]`                                         |
| `devicePlugin.imagePullSecrets`          | List of image pull secrets                           | `[]`                                         |
| `devicePlugin.labels`                    | Labels for device plugin Daemonsets.                 | `{}`                                         |
| `devicePlugin.annotations`               | Annotations for device plugin Daemonsets.            | `{}`                                         |
| `devicePlugin.affinity`                  | Affinity settings for device plugin Daemonset.       | `{}`                                         |

### Configuration for the scheduler responsible for scheduling neuron pods

| Name                                            | Description                                    | Value                                                 |
| ----------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------- |
| `scheduler.enabled`                             | Enable Scheduler.                              | `true`                                                |
| `scheduler.schedulerName`                       | Name of the scheduler.                         | `neuron-scheduler`                                    |
| `scheduler.image.repository`                    | K8s Scheduler image repository.                | `public.ecr.aws/eks-distro/kubernetes/kube-scheduler` |
| `scheduler.image.tag`                           | K8s Scheduler image tag.                       | `v1.29.14-eks-1-29-latest`                            |
| `scheduler.labels`                              | K8s Scheduler labels.                          | `{}`                                                  |
| `scheduler.annotations`                         | K8s Scheduler annotations.                     | `{}`                                                  |
| `scheduler.resources.requests.cpu`              | CPU request for K8s scheduler.                 | `200m`                                                |
| `scheduler.resources.requests.memory`           | Memory request for K8s scheduler.              | `128Mi`                                               |
| `scheduler.resources.limits.cpu`                | CPU limit for K8s scheduler.                   | `400m`                                                |
| `scheduler.resources.limits.memory`             | Memory limit for K8s scheduler.                | `256Mi`                                               |
| `scheduler.extension.image.repository`          | Neuron scheduler extension image repository.   | `public.ecr.aws/neuron/neuron-scheduler`              |
| `scheduler.extension.image.tag`                 | Neuron scheduler extension image tag.          | `2.23.30.0`                                           |
| `scheduler.extension.resources.requests.cpu`    | CPU request for Neuron scheduler extension.    | `200m`                                                |
| `scheduler.extension.resources.requests.memory` | Memory request for Neuron scheduler extension. | `128Mi`                                               |
| `scheduler.extension.resources.limits.cpu`      | CPU limit for Neuron scheduler extension.      | `400m`                                                |
| `scheduler.extension.resources.limits.memory`   | Memory limit for Neuron scheduler extension.   | `256Mi`                                               |
| `scheduler.imagePullSecrets`                    | List of image pull secrets                     | `[]`                                                  |
| `scheduler.extension.labels`                    | Labels for Neuron scheduler extension.         | `{}`                                                  |
| `scheduler.extension.annotations`               | Annotations for Neuron scheduler extension.    | `{}`                                                  |
| `scheduler.extension.imagePullSecrets`          | List of image pull secrets                     | `[]`                                                  |
| `scheduler.affinity`                            | Affinity settings for scheduler.               | `{}`                                                  |
| `scheduler.extension.affinity`                  | Affinity settings for scheduler extension.     | `{}`                                                  |
