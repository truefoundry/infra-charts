# karpenter-config helm chart packaged by TrueFoundry
A Helm chart for Karpenter provisioners.

## Soci

You can add [soci-snapshotter](https://github.com/awslabs/soci-snapshotter) in the nodes brought up by Karpenter using the `userData` field in the `EC2NodeClass` resource.

The script in `userData` does the following,

1. Install and load the `fuse` kernel module.
2. Download the binary from the `awslabs/soci-snapshotter` release page.
3. Adds a configuration file for the `soci-snapshotter-grpc` binary.
4. Adds a `systemd` service, which manages the `soci-snapshotter-grpc` process.
5. Patches `containerd` and `kubelet` config to use the `soci-snapshotter`.

[Note that soci-snapshotter with containerd <1.7.16 does not enforce storage limits.](https://github.com/containerd/containerd/issues/10095#issuecomment-2096570519)

### `userData` script for `default` (CPU) EC2 Node Class
* [AL2023](./files/al2023-soci-default-provisioner-userdata.sh)

### `userData` script for `gpu-default` (GPU) EC2 Node Class
* [AL2023](./files/al2023-soci-gpu-provisioner-userdata.sh)


### Debugging

https://github.com/awslabs/soci-snapshotter/blob/2e3df4a92415ff02ccc76ed9ceb1c25ef9b5c75f/docs/debug.md

1. Shell into the Node.
2. To identify whether the snapshotter is being used, we can use the command below.
   ```
   mount | grep fuse
   ```

   We should see mounts like,
   ```
   fusectl on /sys/fs/fuse/connections type fusectl (rw,relatime)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/63/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/67/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/72/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/75/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/81/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/84/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   soci on /var/lib/soci-snapshotter-grpc/snapshotter/snapshots/87/fs type fuse.rawBridge (rw,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=131072)
   ```

   If you do not see any fuse mounts, that means the snapshotter may not be running or no container image has soci index.

3. Use the commands below to check the status of the snapshotter service and logs.
   ```
   systemctl status soci-snapshotter
   journalctl -u soci-snapshotter -e
   ```

## Parameters

### Cluster configurations

| Name           | Description             | Value           |
| -------------- | ----------------------- | --------------- |
| `cluster.name` | Name of the EKS cluster | `$CLUSTER_NAME` |

### Karpenter configurations

| Name                                                             | Description                                                                                                                                         | Value                        |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `karpenter.instanceProfile`                                      | Instance profile of the karpenter                                                                                                                   | `""`                         |
| `karpenter.defaultNodeTemplate.name`                             | Name of the AWS node class                                                                                                                          | `default`                    |
| `karpenter.defaultNodeTemplate.instanceProfile`                  | Instance profile override for the node template                                                                                                     | `""`                         |
| `karpenter.defaultNodeTemplate.rootVolumeSize`                   | Size for the root volume attached to node                                                                                                           | `100Gi`                      |
| `karpenter.defaultNodeTemplate.encrypted`                        | Encryption for EBS volumes                                                                                                                          | `true`                       |
| `karpenter.defaultNodeTemplate.extraTags`                        | Additional tags for the node template.                                                                                                              | `{}`                         |
| `karpenter.defaultNodeTemplate.amiFamily`                        | AMI family to use for node template                                                                                                                 | `""`                         |
| `karpenter.defaultNodeTemplate.amiSelectorTerms`                 | AMI selector terms for the node template, conditions are ANDed                                                                                      | `[]`                         |
| `karpenter.defaultNodeTemplate.userData`                         | User data to append in the default node template. Set this to "" to disable injection.                                                              | `""`                         |
| `karpenter.defaultNodeTemplate.enableSoci`                       | Enable SOCI for the default nodes. Note this only takes effect when `userData` is `default`                                                         | `false`                      |
| `karpenter.defaultNodeTemplate.metadataOptions`                  | Metadata options to be passed to the default node template.                                                                                         | `{}`                         |
| `karpenter.defaultNodeTemplate.detailedMonitoring`               | Set this to true to enable EC2 detailed cloudwatch monitoring.                                                                                      | `false`                      |
| `karpenter.defaultNodeTemplate.extraSubnetTags`                  | Additional tags for the subnet.                                                                                                                     | `{}`                         |
| `karpenter.defaultNodeTemplate.extraSecurityGroupTags`           | Additional tags for the security group.                                                                                                             | `{}`                         |
| `karpenter.defaultNodePool.name`                                 | Name of the default node pool                                                                                                                       | `default-nodepool`           |
| `karpenter.defaultNodePool.weight`                               | Weight for the default node pool                                                                                                                    | `10`                         |
| `karpenter.defaultNodePool.labels`                               | Labels for the default node pool                                                                                                                    | `{}`                         |
| `karpenter.defaultNodePool.taints`                               | Taints for the default node pool                                                                                                                    | `[]`                         |
| `karpenter.defaultNodePool.disruption`                           | Consolidation policy for disruption                                                                                                                 | `{}`                         |
| `karpenter.defaultNodePool.capacityTypes`                        | Capacity types for the default node pool                                                                                                            | `[]`                         |
| `karpenter.defaultNodePool.zones`                                | Zones for the default node pool                                                                                                                     | `[]`                         |
| `karpenter.defaultNodePool.architectures`                        | Architectures for the default node pool                                                                                                             | `[]`                         |
| `karpenter.defaultNodePool.instanceFamilies.notAllowed`          | Not allowed instance families for the default node pool                                                                                             | `[]`                         |
| `karpenter.defaultNodePool.instanceSizes.notAllowed`             | Not allowed instance sizes for the default node pool                                                                                                | `[]`                         |
| `karpenter.defaultNodePool.limits`                               | compute limits for the default nodepool                                                                                                             | `{}`                         |
| `karpenter.defaultNodePool.additionalRequirements`               | List of additional requirements for default nodepool                                                                                                | `[]`                         |
| `karpenter.gpuDefaultNodeTemplate.enabled`                       | Enable the GPU node pool                                                                                                                            | `true`                       |
| `karpenter.gpuDefaultNodeTemplate.name`                          | Name of the AWS node class                                                                                                                          | `gpu-default`                |
| `karpenter.gpuDefaultNodeTemplate.instanceProfile`               | Instance profile override for the node template                                                                                                     | `""`                         |
| `karpenter.gpuDefaultNodeTemplate.rootVolumeSize`                | Size for the root volume attached to node                                                                                                           | `100Gi`                      |
| `karpenter.gpuDefaultNodeTemplate.encrypted`                     | Encryption for EBS volumes                                                                                                                          | `true`                       |
| `karpenter.gpuDefaultNodeTemplate.extraTags`                     | Additional tags for the gpu node template.                                                                                                          | `{}`                         |
| `karpenter.gpuDefaultNodeTemplate.detailedMonitoring`            | Set this to true to enable EC2 detailed cloudwatch monitoring.                                                                                      | `false`                      |
| `karpenter.gpuDefaultNodeTemplate.amiFamily`                     | AMI family to use for node template                                                                                                                 | `""`                         |
| `karpenter.gpuDefaultNodeTemplate.amiSelectorTerms`              | AMI selector terms for the node template, conditions are ANDed                                                                                      | `[]`                         |
| `karpenter.gpuDefaultNodeTemplate.userData`                      | User data script for GPU node template. Set this to "default" to let the chart automatically decide this. Set this to "" to disable this injection. | `default`                    |
| `karpenter.gpuDefaultNodeTemplate.enableSoci`                    | Enable SOCI for the GPU machines.                                                                                                                   | `false`                      |
| `karpenter.gpuDefaultNodeTemplate.metadataOptions`               | Metadata options to be passed to the GPU node template.                                                                                             | `{}`                         |
| `karpenter.gpuDefaultNodeTemplate.extraSubnetTags`               | Additional tags for the subnet.                                                                                                                     | `{}`                         |
| `karpenter.gpuDefaultNodeTemplate.extraSecurityGroupTags`        | Additional tags for the security group.                                                                                                             | `{}`                         |
| `karpenter.gpuNodePool.enabled`                                  | Enable the GPU node pool                                                                                                                            | `true`                       |
| `karpenter.gpuNodePool.name`                                     | Name of the GPU node pool                                                                                                                           | `gpu-nodepool`               |
| `karpenter.gpuNodePool.weight`                                   | Weight for the GPU node pool                                                                                                                        | `10`                         |
| `karpenter.gpuNodePool.labels`                                   | Labels for the GPU node pool                                                                                                                        | `{}`                         |
| `karpenter.gpuNodePool.taints`                                   | Taints for the GPU node pool                                                                                                                        | `[]`                         |
| `karpenter.gpuNodePool.disruption`                               | Consolidation policy for disruption                                                                                                                 | `{}`                         |
| `karpenter.gpuNodePool.capacityTypes`                            | Capacity types for the GPU node pool                                                                                                                | `[]`                         |
| `karpenter.gpuNodePool.zones`                                    | Zones for the GPU node pool                                                                                                                         | `[]`                         |
| `karpenter.gpuNodePool.architectures`                            | Architectures for the GPU node pool                                                                                                                 | `[]`                         |
| `karpenter.gpuNodePool.instanceFamilies.allowed`                 | Allowed instance families for the GPU node pool                                                                                                     | `[]`                         |
| `karpenter.gpuNodePool.instanceSizes.notAllowed`                 | Not allowed instance sizes for the GPU node pool                                                                                                    | `[]`                         |
| `karpenter.gpuNodePool.limits`                                   | compute limits for the GPU node pool                                                                                                                | `{}`                         |
| `karpenter.gpuNodePool.additionalRequirements`                   | List of additional requirements for GPU node pool                                                                                                   | `[]`                         |
| `karpenter.controlPlaneNodeTemplate.enabled`                     | Enable the control plane node template                                                                                                              | `true`                       |
| `karpenter.controlPlaneNodeTemplate.name`                        | Name of the AWS node template                                                                                                                       | `controlplane-node-template` |
| `karpenter.controlPlaneNodeTemplate.instanceProfile`             | Instance profile override for the node template                                                                                                     | `""`                         |
| `karpenter.controlPlaneNodeTemplate.rootVolumeSize`              | Size for the root volume attached to node                                                                                                           | `100Gi`                      |
| `karpenter.controlPlaneNodeTemplate.encrypted`                   | Encryption for EBS volumes                                                                                                                          | `true`                       |
| `karpenter.controlPlaneNodeTemplate.extraTags`                   | Additional tags for the node template.                                                                                                              | `{}`                         |
| `karpenter.controlPlaneNodeTemplate.amiFamily`                   | AMI family to use for node template                                                                                                                 | `""`                         |
| `karpenter.controlPlaneNodeTemplate.amiSelectorTerms`            | AMI selector terms for the node template, conditions are ANDed                                                                                      | `[]`                         |
| `karpenter.controlPlaneNodeTemplate.userData`                    | User data script for control-plane node template. Set this to "" to disable this injection.                                                         | `""`                         |
| `karpenter.controlPlaneNodeTemplate.metadataOptions`             | Metadata options to be passed to the instance.                                                                                                      | `{}`                         |
| `karpenter.controlPlaneNodeTemplate.detailedMonitoring`          | Set this to true to enable EC2 detailed cloudwatch monitoring.                                                                                      | `false`                      |
| `karpenter.controlPlaneNodeTemplate.extraSubnetTags`             | Additional tags for the subnet.                                                                                                                     | `{}`                         |
| `karpenter.controlPlaneNodeTemplate.extraSecurityGroupTags`      | Additional tags for the security group.                                                                                                             | `{}`                         |
| `karpenter.controlPlaneNodePool.enabled`                         | Enable the control plane node pool                                                                                                                  | `true`                       |
| `karpenter.controlPlaneNodePool.name`                            | Name of the control plane node pool                                                                                                                 | `control-plane-nodepool`     |
| `karpenter.controlPlaneNodePool.weight`                          | Weight for the control plane node pool                                                                                                              | `10`                         |
| `karpenter.controlPlaneNodePool.labels`                          | Labels for the control plane node pool                                                                                                              | `{}`                         |
| `karpenter.controlPlaneNodePool.taints`                          | Taints for the control plane node pool                                                                                                              | `[]`                         |
| `karpenter.controlPlaneNodePool.disruption`                      | Consolidation policy for disruption                                                                                                                 | `{}`                         |
| `karpenter.controlPlaneNodePool.capacityTypes`                   | Capacity types for the control plane node pool                                                                                                      | `[]`                         |
| `karpenter.controlPlaneNodePool.zones`                           | Zones for the control plane node pool                                                                                                               | `[]`                         |
| `karpenter.controlPlaneNodePool.architectures`                   | Architectures for the control plane node pool                                                                                                       | `[]`                         |
| `karpenter.controlPlaneNodePool.instanceFamilies.allowed`        | Allowed instance families for the control plane node pool                                                                                           | `[]`                         |
| `karpenter.controlPlaneNodePool.instanceFamilies.notAllowed`     | Not allowed instance families for the control plane node pool                                                                                       | `[]`                         |
| `karpenter.controlPlaneNodePool.instanceSizes.allowed`           | Allowed instance sizes for the control plane node pool                                                                                              | `[]`                         |
| `karpenter.controlPlaneNodePool.instanceSizes.notAllowed`        | Not allowed instance sizes for the control plane node pool                                                                                          | `[]`                         |
| `karpenter.controlPlaneNodePool.limits`                          | compute limits for the control plane node pool                                                                                                      | `{}`                         |
| `karpenter.controlPlaneNodePool.additionalRequirements`          | List of additional requirements for control plane node pool                                                                                         | `[]`                         |
| `karpenter.inferentiaDefaultNodeTemplate.enabled`                | Enable the inferentia node pool                                                                                                                     | `false`                      |
| `karpenter.inferentiaDefaultNodeTemplate.name`                   | Name of the AWS node class                                                                                                                          | `inferentia-default`         |
| `karpenter.inferentiaDefaultNodeTemplate.instanceProfile`        | Instance profile override for the node template                                                                                                     | `""`                         |
| `karpenter.inferentiaDefaultNodeTemplate.rootVolumeSize`         | Size for the root volume attached to node                                                                                                           | `100Gi`                      |
| `karpenter.inferentiaDefaultNodeTemplate.encrypted`              | Encryption for EBS volumes                                                                                                                          | `true`                       |
| `karpenter.inferentiaDefaultNodeTemplate.extraTags`              | Additional tags for the node template.                                                                                                              | `{}`                         |
| `karpenter.inferentiaDefaultNodeTemplate.detailedMonitoring`     | Set this to true to enable EC2 detailed cloudwatch monitoring                                                                                       | `false`                      |
| `karpenter.inferentiaDefaultNodeTemplate.amiFamily`              | AMI family to use for node template                                                                                                                 | `""`                         |
| `karpenter.inferentiaDefaultNodeTemplate.amiSelectorTerms`       | AMI selector terms for the node template, conditions are ANDed                                                                                      | `[]`                         |
| `karpenter.inferentiaDefaultNodeTemplate.userData`               | User data script for GPU node template. Set this to "" to disable this injection.                                                                   | `""`                         |
| `karpenter.inferentiaDefaultNodeTemplate.metadataOptions`        | Metadata options to be passed to the inferentia node template.                                                                                      | `{}`                         |
| `karpenter.inferentiaDefaultNodeTemplate.extraSubnetTags`        | Additional tags for the subnet.                                                                                                                     | `{}`                         |
| `karpenter.inferentiaDefaultNodeTemplate.extraSecurityGroupTags` | Additional tags for the security group.                                                                                                             | `{}`                         |
| `karpenter.inferentiaNodePool.enabled`                           | Enable the Inferentia node pool                                                                                                                     | `false`                      |
| `karpenter.inferentiaNodePool.name`                              | Name of the Inferentia node pool                                                                                                                    | `inferentia-nodepool`        |
| `karpenter.inferentiaNodePool.weight`                            | Weight for the Inferentia node pool                                                                                                                 | `10`                         |
| `karpenter.inferentiaNodePool.labels`                            | Labels for the Inferentia node pool                                                                                                                 | `{}`                         |
| `karpenter.inferentiaNodePool.taints`                            | Taints for the Inferentia node pool                                                                                                                 | `[]`                         |
| `karpenter.inferentiaNodePool.disruption`                        | Consolidation policy for disruption                                                                                                                 | `{}`                         |
| `karpenter.inferentiaNodePool.capacityTypes`                     | Capacity types for the Inferentia node pool                                                                                                         | `[]`                         |
| `karpenter.inferentiaNodePool.zones`                             | Zones for the Inferentia node pool                                                                                                                  | `[]`                         |
| `karpenter.inferentiaNodePool.architectures`                     | Architectures for the Inferentia node pool                                                                                                          | `[]`                         |
| `karpenter.inferentiaNodePool.instanceFamilies.allowed`          | Allowed instance families for the Inferentia node pool                                                                                              | `[]`                         |
| `karpenter.inferentiaNodePool.instanceSizes.notAllowed`          | Not allowed instance sizes for the Inferentia node pool                                                                                             | `[]`                         |
| `karpenter.inferentiaNodePool.limits`                            | compute limits for the Inferentia node pool                                                                                                         | `{}`                         |
| `karpenter.inferentiaNodePool.additionalRequirements`            | List of additional requirements for Inferentia node pool                                                                                            | `[]`                         |

### critical Section to create on-demand nodepool for critical components

| Name                                                  | Description                                                                            | Value                   |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------------------- |
| `karpenter.critical.enabled`                          | Enable the critical plane node pool                                                    | `true`                  |
| `karpenter.critical.name`                             | Name of the critical node pool                                                         | `tfy-critical-nodepool` |
| `karpenter.critical.weight`                           | Weight for the critical node pool                                                      | `100`                   |
| `karpenter.critical.labels`                           | Labels for the critical node pool                                                      | `{}`                    |
| `karpenter.critical.taints`                           | Taints for the critical node pool                                                      | `[]`                    |
| `karpenter.critical.disruption`                       | Consolidation policy for disruption                                                    | `{}`                    |
| `karpenter.critical.capacityTypes`                    | Capacity types for the critical node pool                                              | `[]`                    |
| `karpenter.critical.zones`                            | Zones for the critical node pool                                                       | `[]`                    |
| `karpenter.critical.architectures`                    | Architectures for the critical node pool                                               | `[]`                    |
| `karpenter.critical.instanceFamilies.allowed`         | Allowed instance families for the critical node pool                                   | `[]`                    |
| `karpenter.critical.instanceFamilies.notAllowed`      | Not allowed instance families for the critical node pool                               | `[]`                    |
| `karpenter.critical.instanceSizes.allowed`            | Allowed instance sizes for the critical node pool                                      | `[]`                    |
| `karpenter.critical.instanceSizes.notAllowed`         | Not allowed instance sizes for the critical node pool                                  | `[]`                    |
| `karpenter.critical.limits`                           | compute limits for the critical node pool                                              | `{}`                    |
| `karpenter.critical.additionalRequirements`           | List of additional requirements for critical node pool                                 | `[]`                    |
| `karpenter.critical.nodeclass.create`                 | Specifies if the EC2 nodeclass with nodeclass.name should be created                   | `true`                  |
| `karpenter.critical.nodeclass.name`                   | Name of the nodeclass. If create is not set, existing nodeclass is used.               | `[]`                    |
| `karpenter.critical.nodeclass.instanceProfile`        | Instance profile override for the node template                                        | `""`                    |
| `karpenter.critical.nodeclass.rootVolumeSize`         | Size for the root volume attached to the node                                          | `100Gi`                 |
| `karpenter.critical.nodeclass.encrypted`              | Encryption for EBS volumes                                                             | `true`                  |
| `karpenter.critical.nodeclass.extraTags`              | Additional tags for the node template.                                                 | `{}`                    |
| `karpenter.critical.nodeclass.detailedMonitoring`     | Set this to true to enable EC2 detailed cloudwatch monitoring.                         | `false`                 |
| `karpenter.critical.nodeclass.amiFamily`              | AMI family to use for node template                                                    | `""`                    |
| `karpenter.critical.nodeclass.amiSelectorTerms`       | AMI selector terms for the node template, conditions are ANDed                         | `[]`                    |
| `karpenter.critical.nodeclass.userData`               | User data script for critical node template. Set this to "" to disable this injection. | `""`                    |
| `karpenter.critical.nodeclass.metadataOptions`        | Metadata options to be passed to the instance.                                         | `{}`                    |
| `karpenter.critical.nodeclass.extraSubnetTags`        | Additional tags for the subnet.                                                        | `{}`                    |
| `karpenter.critical.nodeclass.extraSecurityGroupTags` | Additional tags for the security group.                                                | `{}`                    |
| `extraObjects`                                        | Additional objects to be created along with karpenter                                  | `[]`                    |
