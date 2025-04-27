# Tfy-k8s-config helm chart packaged by TrueFoundry

Tfy-k8s-config is a Helm chart that facilitates the PriorityClass and some global configurations necessary for Truefoundry components.

## Parameters

### priorityClass Configuration for priorityClass `truefoundry-critical`

| Name                             | Description                                                                | Value                  |
| -------------------------------- | -------------------------------------------------------------------------- | ---------------------- |
| `priorityClass.name`             | The name of the priority class.                                            | `truefoundry-critical` |
| `priorityClass.enabled`          | Whether to enable the priority class.                                      | `true`                 |
| `priorityClass.preemptionPolicy` | The preemption policy of the priority class. [PreemptLowerPriority, Never] | `PreemptLowerPriority` |
| `priorityClass.value`            | The value of the priority class.                                           | `1000000`              |
| `priorityClass.globalDefault`    | Whether to set the priority class as the global default.                   | `false`                |
