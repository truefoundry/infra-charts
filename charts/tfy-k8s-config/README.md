# Tfy-k8s-config helm chart packaged by TrueFoundry

Tfy-k8s-config is a Helm chart that facilitates the PriorityClass and some global configurations necessary for Truefoundry components.

## Parameters

### priorityClassNodeCritical Configuration for priorityClass `truefoundry-critical`

| Name                                         | Description                                                                | Value                  |
| -------------------------------------------- | -------------------------------------------------------------------------- | ---------------------- |
| `priorityClassNodeCritical.name`             | The name of the priority class.                                            | `truefoundry-critical` |
| `priorityClassNodeCritical.enabled`          | Whether to enable the priority class.                                      | `true`                 |
| `priorityClassNodeCritical.preemptionPolicy` | The preemption policy of the priority class. [PreemptLowerPriority, Never] | `PreemptLowerPriority` |
| `priorityClassNodeCritical.value`            | The value of the priority class.                                           | `100000000`            |
| `priorityClassNodeCritical.globalDefault`    | Whether to set the priority class as the global default.                   | `false`                |
