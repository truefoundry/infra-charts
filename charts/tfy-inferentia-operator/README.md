# Tfy-inferentia-operator helm chart packaged by TrueFoundry
Tfy-inferentia-operator is a Helm chart that facilitates the deployment and management of AWS Inferentia resources in Kubernetes clusters.

Refer to https://github.com/aws-neuron/aws-neuron-sdk/blob/e0ef8a1a780ee798e7f01fe94f1235d571e211c6/src/k8/k8s-neuron-device-plugin.yml#L1

## Parameters

### Configuration for the device plugin responsible for node feature discovery

| Name                                     | Description                                 | Value                                                  |
| ---------------------------------------- | ------------------------------------------- | ------------------------------------------------------ |
| `devicePlugin.enabled`                   | Enable device plugin Daemonset.             | `true`                                                 |
| `devicePlugin.resources.requests.cpu`    | CPU request for device plugin Daemonset.    | `100m`                                                 |
| `devicePlugin.resources.requests.memory` | Memory request for device plugin Daemonset. | `128Mi`                                                |
| `devicePlugin.image`                     | Image to use for device plugin Daemonset.   | `public.ecr.aws/neuron/neuron-device-plugin:2.16.18.0` |

### Configuration for the scheduler responsible for scheduling neuron pods

| Name                                                    | Description                                    | Value                                             |
| ------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------- |
| `scheduler.enabled`                                     | Enable Scheduler.                              | `true`                                            |
| `scheduler.schedulerName`                               | Name of the scheduler.                         | `neuron-scheduler`                                |
| `scheduler.schedulerImage`                              | K8s Scheduler image.                           | `registry.k8s.io/kube-scheduler:v1.27.7`          |
| `scheduler.schedulerResources.requests.cpu`             | CPU request for K8s scheduler.                 | `100m`                                            |
| `scheduler.schedulerResources.requests.memory`          | Memory request for K8s scheduler.              | `50Mi`                                            |
| `scheduler.schedulerExtensionImage`                     | Neuron scheduler extension image.              | `public.ecr.aws/neuron/neuron-scheduler:2.18.3.0` |
| `scheduler.schedulerExtensionResources.requests.cpu`    | CPU request for Neuron scheduler extension.    | `0.1`                                             |
| `scheduler.schedulerExtensionResources.requests.memory` | Memory request for Neuron scheduler extension. | `50Mi`                                            |
