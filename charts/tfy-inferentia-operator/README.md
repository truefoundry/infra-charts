# Tfy-inferentia-operator helm chart packaged by TrueFoundry
Tfy-inferentia-operator is a Helm chart that facilitates the deployment and management of AWS Inferentia resources in Kubernetes clusters.

## Parameters

### Configuration for the device plugin responsible for node feature discovery

| Name                                     | Description                                 | Value                                                  |
| ---------------------------------------- | ------------------------------------------- | ------------------------------------------------------ |
| `devicePlugin.enabled`                   | Enable device plugin Daemonset.             | `true`                                                 |
| `devicePlugin.resources.requests.cpu`    | CPU request for device plugin Daemonset.    | `100m`                                                 |
| `devicePlugin.resources.requests.memory` | Memory request for device plugin Daemonset. | `128MiB`                                               |
| `devicePlugin.image`                     | Image to use for device plugin Daemonset.   | `public.ecr.aws/neuron/neuron-device-plugin:2.16.18.0` |
