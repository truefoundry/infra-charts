# karpenter-config helm chart packaged by TrueFoundry
A Helm chart for Karpenter provisioners.

## Soci

You can add [soci-snapshotter](https://github.com/awslabs/soci-snapshotter) in the nodes brought up by Karpenter using the `userData` field in the `AWSNodeTemplate` resource.

The script in `userData` does the following,

1. Install and load the `fuse` kernel module.
2. Downloads the binary from the `awslabs/soci-snapshotter` release page.
3. Adds a configuration file for the `soci-snapshotter-grpc` finary.
4. Adds a `systemd` service, which manages the `soci-snapshotter-grpc` process.
5. Patches `containerd` config to use the `soci-snapshotter`.

### `userData` script for `default` Node Template

```bash
#!/bin/bash
set -ex

version_lte() {
  printf '%s\n' "$1" "$2" | sort -C -V
}

version_lt() {
  ! version_lte "$2" "$1"
}
CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}
echo containerd version "${CONTAINERD_VERSION}"

setup_soci() {( set -ex

SOCI_RELEASE_VERSION="0.5.0"

yum install fuse -y
modprobe fuse

curl \
--silent \
--show-error \
--retry 10 \
--retry-delay 1 \
-L https://github.com/awslabs/soci-snapshotter/releases/download/v$SOCI_RELEASE_VERSION/soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz \
-o soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz

tar -C /usr/local/bin -xvf soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz ./soci ./soci-snapshotter-grpc
rm soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz

cat > /etc/systemd/system/soci-snapshotter.service << EOF
[Unit]
Description=soci snapshotter containerd plugin
Documentation=https://github.com/awslabs/soci-snapshotter
After=network.target
Before=containerd.service

[Service]
Type=notify
ExecStart=/usr/local/bin/soci-snapshotter-grpc
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

KUBELET_CONFIG_PATH=/etc/kubernetes/kubelet/kubelet-config.json

if [ -f "$KUBELET_CONFIG_PATH" ]; then
  cat $KUBELET_CONFIG_PATH | jq '.imageServiceEndpoint = "unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"' > $KUBELET_CONFIG_PATH.tmp && mv -f $KUBELET_CONFIG_PATH.tmp $KUBELET_CONFIG_PATH
else
  echo Kubelet Config not found at $KUBELET_CONFIG_PATH. SOCI will not work for private image.
fi

mkdir -p /etc/soci-snapshotter-grpc

cat > /etc/soci-snapshotter-grpc/config.toml << EOF
[cri_keychain]
enable_keychain=true
image_service_path="/run/containerd/containerd.sock"
EOF

systemctl daemon-reload
systemctl enable --now soci-snapshotter
systemctl status soci-snapshotter

echo patching /etc/eks/containerd/containerd-config.toml
cat > /etc/eks/containerd/containerd-config.toml << EOF
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"

[grpc]
address = "/run/containerd/containerd.sock"

[plugins."io.containerd.grpc.v1.cri".containerd]
default_runtime_name = "runc"
discard_unpacked_layers = true
## ENABLE SOCI SNAPSHOTTER
snapshotter = "soci"
disable_snapshot_annotations = false
##

[plugins."io.containerd.grpc.v1.cri"]
sandbox_image = "SANDBOX_IMAGE"

[plugins."io.containerd.grpc.v1.cri".registry]
config_path = "/etc/containerd/certs.d:/etc/docker/certs.d"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".cni]
bin_dir = "/opt/cni/bin"
conf_dir = "/etc/cni/net.d"

## SOCI PLUGIN
[proxy_plugins]
[proxy_plugins.soci]
type = "snapshot"
address = "/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"
##
EOF

)}

if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
setup_soci
else
  echo "CONTAINERD_VERSION is empty or not within the specified range."
fi
```

### `userData` script for `gpu-default` Node Template

This script **is based on**: [./files/al2-gpu-provisioner-userdata.sh](./files/al2-gpu-provisioner-userdata.sh)

The `containerd` config patch for NVIDIA GPUs **may change in future commits**.

```bash
#!/bin/bash

set -ex

version_lte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

version_lt() {
    ! version_lte "$2" "$1"
}

disable_nvidia_gsp() {

  rmmod nvidia_drm
  rmmod nvidia_modeset
  rmmod nvidia_uvm
  rmmod nvidia
  echo "Writing NVreg_EnableGpuFirmware=0 to /etc/modprobe.d/nvidia.conf"
  echo "options nvidia NVreg_EnableGpuFirmware=0" | tee --append /etc/modprobe.d/nvidia.conf
  echo "Writing NVreg_EnableGpuFirmware=0 to /etc/modprobe.d/nvidia-gsp.conf"
  echo "options nvidia NVreg_EnableGpuFirmware=0" | tee --append /etc/modprobe.d/nvidia-gsp.conf
  echo "Running dracut"
  dracut -f

}

add_default_runtime_name_nvidia_in_containerd_config() {

    echo "Patching /etc/eks/containerd/containerd-config.toml"
    mkdir -p /etc/eks/containerd

    cat > /etc/eks/containerd/containerd-config.toml << EOF

root = "/var/lib/containerd"
state = "/run/containerd"

[grpc]
address = "/run/containerd/containerd.sock"

[plugins.cri]
sandbox_image = "SANDBOX_IMAGE"

[plugins.cri.registry]
config_path = "/etc/containerd/certs.d:/etc/docker/certs.d"

[plugins.cri.containerd.runtimes.nvidia]
privileged_without_host_devices = false
runtime_engine = ""
runtime_root = ""
runtime_type = "io.containerd.runtime.v1.linux"

[plugins.cri.containerd.runtimes.nvidia.options]
Runtime = "/etc/docker-runtimes.d/nvidia"
SystemdCgroup = true

[plugins.cri.containerd]
default_runtime_name = "nvidia"

EOF

}

setup_soci() {(

SOCI_RELEASE_VERSION="0.5.0"

yum install fuse -y
modprobe fuse

curl \
--silent \
--show-error \
--retry 10 \
--retry-delay 1 \
-L https://github.com/awslabs/soci-snapshotter/releases/download/v$SOCI_RELEASE_VERSION/soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz \
-o soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz

tar -C /usr/local/bin -xvf soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz ./soci ./soci-snapshotter-grpc
rm soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz

cat > /etc/systemd/system/soci-snapshotter.service << EOF
[Unit]
Description=soci snapshotter containerd plugin
Documentation=https://github.com/awslabs/soci-snapshotter
After=network.target
Before=containerd.service

[Service]
Type=notify
ExecStart=/usr/local/bin/soci-snapshotter-grpc
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

KUBELET_CONFIG_PATH=/etc/kubernetes/kubelet/kubelet-config.json

if [ -f "$KUBELET_CONFIG_PATH" ]; then
  cat $KUBELET_CONFIG_PATH | jq '.imageServiceEndpoint = "unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"' > $KUBELET_CONFIG_PATH.tmp && mv -f $KUBELET_CONFIG_PATH.tmp $KUBELET_CONFIG_PATH
else
  echo Kubelet Config not found at $KUBELET_CONFIG_PATH. SOCI will not work for private image.
fi

mkdir -p /etc/soci-snapshotter-grpc

cat > /etc/soci-snapshotter-grpc/config.toml << EOF
[cri_keychain]
enable_keychain=true
image_service_path="/run/containerd/containerd.sock"
EOF

systemctl daemon-reload
systemctl enable --now soci-snapshotter
systemctl status soci-snapshotter

echo patching /etc/eks/containerd/containerd-config.toml

cat >> /etc/eks/containerd/containerd-config.toml << EOF
## ENABLE SOCI SNAPSHOTTER
snapshotter = "soci"
disable_snapshot_annotations = false
##

## SOCI PLUGIN
[proxy_plugins]
[proxy_plugins.soci]
type = "snapshot"
address = "/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"
##
EOF

)}

CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -r -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}
echo "${CONTAINERD_VERSION}"

if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
    echo "CONTAINERD_VERSION is not empty and within the range [1.5.0, 2.0)."
    add_default_runtime_name_nvidia_in_containerd_config
    disable_nvidia_gsp
    setup_soci
else
    echo "CONTAINERD_VERSION is empty or not within the specified range."
fi
```

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

| Name               | Description                 | Value |
| ------------------ | --------------------------- | ----- |
| `cluster.name`     | Name of the EKS cluster     | `""`  |
| `cluster.endpoint` | Endpoint of the EKS cluster | `""`  |

### Karpenter configurations

| Name                                                             | Description                                                   | Value                                                                                                                                                              |
| ---------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `karpenter.instanceProfile`                                      | Instance profile of the karpenter                             | `""`                                                                                                                                                               |
| `karpenter.defaultNodeTemplate.name`                             | Name of the AWS node class                                    | `default`                                                                                                                                                          |
| `karpenter.defaultNodeTemplate.rootVolumeSize`                   | Size for the root volume attached to node                     | `100Gi`                                                                                                                                                            |
| `karpenter.defaultNodeTemplate.extraTags`                        | Additional tags for the node template.                        | `{}`                                                                                                                                                               |
| `karpenter.defaultNodeTemplate.amiFamily`                        | AMI family to use for node template                           | `AL2`                                                                                                                                                              |
| `karpenter.defaultNodeTemplate.detailedMonitoring`               |                                                               | `false`                                                                                                                                                            |
| `karpenter.defaultNodeTemplate.extraSubnetTags`                  | Additional tags for the subnet.                               | `{}`                                                                                                                                                               |
| `karpenter.defaultNodeTemplate.extraSecurityGroupTags`           | Additional tags for the security group.                       | `{}`                                                                                                                                                               |
| `karpenter.defaultNodePool.name`                                 | Name of the default node pool                                 | `default-nodepool`                                                                                                                                                 |
| `karpenter.defaultNodePool.weight`                               | Weight for the default node pool                              | `10`                                                                                                                                                               |
| `karpenter.defaultNodePool.labels`                               | Labels for the default node pool                              | `{}`                                                                                                                                                               |
| `karpenter.defaultNodePool.taints`                               | Taints for the default node pool                              | `[]`                                                                                                                                                               |
| `karpenter.defaultNodePool.disruption.consolidationPolicy`       | Consolidation policy for disruption                           | `WhenUnderutilized`                                                                                                                                                |
| `karpenter.defaultNodePool.capacityTypes`                        | Capacity types for the default node pool                      | `["spot"]`                                                                                                                                                         |
| `karpenter.defaultNodePool.zones`                                | Zones for the default node pool                               | `[]`                                                                                                                                                               |
| `karpenter.defaultNodePool.architectures`                        | Architectures for the default node pool                       | `["amd64"]`                                                                                                                                                        |
| `karpenter.defaultNodePool.instanceFamilies.notAllowed`          | Not allowed instance families for the default node pool       | `["t3","t2","t3a","p2","p3","p4d","p4de","p5","g4dn","g5","g4ad","inf1","inf2","trn1","trn1n"]`                                                                    |
| `karpenter.defaultNodePool.instanceSizes.notAllowed`             | Not allowed instance sizes for the default node pool          | `["nano","micro","metal"]`                                                                                                                                         |
| `karpenter.defaultNodePool.limits.cpu`                           | CPU limit for the default node pool                           | `75`                                                                                                                                                               |
| `karpenter.defaultNodePool.limits.memory`                        | Memory limit for the default node pool                        | `300Gi`                                                                                                                                                            |
| `karpenter.gpuDefaultNodeTemplate.enabled`                       | Enable the GPU node pool                                      | `false`                                                                                                                                                            |
| `karpenter.gpuDefaultNodeTemplate.name`                          | Name of the AWS node class                                    | `gpu-default`                                                                                                                                                      |
| `karpenter.gpuDefaultNodeTemplate.rootVolumeSize`                | Size for the root volume attached to node                     | `100Gi`                                                                                                                                                            |
| `karpenter.gpuDefaultNodeTemplate.extraTags`                     | Additional tags for the gpu node template.                    | `{}`                                                                                                                                                               |
| `karpenter.gpuDefaultNodeTemplate.detailedMonitoring`            |                                                               | `false`                                                                                                                                                            |
| `karpenter.gpuDefaultNodeTemplate.amiFamily`                     | AMI family to use for node template                           | `AL2`                                                                                                                                                              |
| `karpenter.gpuDefaultNodeTemplate.extraSubnetTags`               | Additional tags for the subnet.                               | `{}`                                                                                                                                                               |
| `karpenter.gpuDefaultNodeTemplate.extraSecurityGroupTags`        | Additional tags for the security group.                       | `{}`                                                                                                                                                               |
| `karpenter.gpuNodePool.enabled`                                  | Enable the GPU node pool                                      | `false`                                                                                                                                                            |
| `karpenter.gpuNodePool.name`                                     | Name of the GPU node pool                                     | `gpu-nodepool`                                                                                                                                                     |
| `karpenter.gpuNodePool.weight`                                   | Weight for the GPU node pool                                  | `10`                                                                                                                                                               |
| `karpenter.gpuNodePool.labels`                                   | Labels for the GPU node pool                                  | `{}`                                                                                                                                                               |
| `karpenter.gpuNodePool.taints`                                   | Taints for the GPU node pool                                  | `[]`                                                                                                                                                               |
| `karpenter.gpuNodePool.disruption.consolidationPolicy`           | Consolidation policy for disruption                           | `WhenUnderutilized`                                                                                                                                                |
| `karpenter.gpuNodePool.capacityTypes`                            | Capacity types for the GPU node pool                          | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.gpuNodePool.zones`                                    | Zones for the GPU node pool                                   | `[]`                                                                                                                                                               |
| `karpenter.gpuNodePool.architectures`                            | Architectures for the GPU node pool                           | `["amd64"]`                                                                                                                                                        |
| `karpenter.gpuNodePool.instanceFamilies.allowed`                 | Allowed instance families for the GPU node pool               | `["p2","p3","g4dn","g5","p4d","p4de"]`                                                                                                                             |
| `karpenter.gpuNodePool.instanceSizes.notAllowed`                 | Not allowed instance sizes for the GPU node pool              | `["nano","micro","metal"]`                                                                                                                                         |
| `karpenter.controlPlaneNodeTemplate.enabled`                     | Enable the control plane node template                        | `false`                                                                                                                                                            |
| `karpenter.controlPlaneNodeTemplate.name`                        | Name of the AWS node template                                 | `controlplane-node-template`                                                                                                                                       |
| `karpenter.controlPlaneNodeTemplate.rootVolumeSize`              | Size for the root volume attached to node                     | `100Gi`                                                                                                                                                            |
| `karpenter.controlPlaneNodeTemplate.extraTags`                   | Additional tags for the node template.                        | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodeTemplate.amiFamily`                   | AMI family to use for node template                           | `AL2`                                                                                                                                                              |
| `karpenter.controlPlaneNodeTemplate.detailedMonitoring`          |                                                               | `false`                                                                                                                                                            |
| `karpenter.controlPlaneNodeTemplate.extraSubnetTags`             | Additional tags for the subnet.                               | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodeTemplate.extraSecurityGroupTags`      | Additional tags for the security group.                       | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.enabled`                         | Enable the control plane node pool                            | `false`                                                                                                                                                            |
| `karpenter.controlPlaneNodePool.name`                            | Name of the control plane node pool                           | `control-plane-nodepool`                                                                                                                                           |
| `karpenter.controlPlaneNodePool.weight`                          | Weight for the control plane node pool                        | `10`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.labels`                          | Labels for the control plane node pool                        | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.taints`                          | Taints for the control plane node pool                        | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.disruption.consolidationPolicy`  | Consolidation policy for disruption                           | `WhenUnderutilized`                                                                                                                                                |
| `karpenter.controlPlaneNodePool.capacityTypes`                   | Capacity types for the control plane node pool                | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.controlPlaneNodePool.zones`                           | Zones for the control plane node pool                         | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.architectures`                   | Architectures for the control plane node pool                 | `["amd64"]`                                                                                                                                                        |
| `karpenter.controlPlaneNodePool.instanceFamilies.allowed`        | Allowed instance families for the control plane node pool     | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.instanceFamilies.notAllowed`     | Not allowed instance families for the control plane node pool | `["t3","t2","t3a","p2","p3","p4d","p4de","g4dn","g5","g4ad","inf1","inf2","trn1","trn1n","c1","cc1","cc2","cg1","cg2","cr1","g1","g2","hi1","hs1","m1","m2","m3"]` |
| `karpenter.controlPlaneNodePool.instanceSizes.allowed`           | Allowed instance sizes for the control plane node pool        | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneNodePool.instanceSizes.notAllowed`        | Not allowed instance sizes for the control plane node pool    | `["nano","12xlarge","16xlarge","24xlarge","32xlarge","metal"]`                                                                                                     |
| `karpenter.inferentiaDefaultNodeTemplate.enabled`                | Enable the inferentia node pool                               | `false`                                                                                                                                                            |
| `karpenter.inferentiaDefaultNodeTemplate.name`                   | Name of the AWS node class                                    | `inferentia-default`                                                                                                                                               |
| `karpenter.inferentiaDefaultNodeTemplate.rootVolumeSize`         | Size for the root volume attached to node                     | `100Gi`                                                                                                                                                            |
| `karpenter.inferentiaDefaultNodeTemplate.extraTags`              | Additional tags for the node template.                        | `{}`                                                                                                                                                               |
| `karpenter.inferentiaDefaultNodeTemplate.detailedMonitoring`     |                                                               | `false`                                                                                                                                                            |
| `karpenter.inferentiaDefaultNodeTemplate.amiFamily`              | AMI family to use for node template                           | `AL2`                                                                                                                                                              |
| `karpenter.inferentiaDefaultNodeTemplate.extraSubnetTags`        | Additional tags for the subnet.                               | `{}`                                                                                                                                                               |
| `karpenter.inferentiaDefaultNodeTemplate.extraSecurityGroupTags` | Additional tags for the security group.                       | `{}`                                                                                                                                                               |
| `karpenter.inferentiaNodePool.enabled`                           | Enable the Inferentia node pool                               | `false`                                                                                                                                                            |
| `karpenter.inferentiaNodePool.name`                              | Name of the Inferentia node pool                              | `inferentia-nodepool`                                                                                                                                              |
| `karpenter.inferentiaNodePool.weight`                            | Weight for the Inferentia node pool                           | `10`                                                                                                                                                               |
| `karpenter.inferentiaNodePool.labels`                            | Labels for the Inferentia node pool                           | `{}`                                                                                                                                                               |
| `karpenter.inferentiaNodePool.taints`                            | Taints for the Inferentia node pool                           | `[]`                                                                                                                                                               |
| `karpenter.inferentiaNodePool.disruption.consolidationPolicy`    | Consolidation policy for disruption                           | `WhenUnderutilized`                                                                                                                                                |
| `karpenter.inferentiaNodePool.capacityTypes`                     | Capacity types for the Inferentia node pool                   | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.inferentiaNodePool.zones`                             | Zones for the Inferentia node pool                            | `[]`                                                                                                                                                               |
| `karpenter.inferentiaNodePool.architectures`                     | Architectures for the Inferentia node pool                    | `["amd64"]`                                                                                                                                                        |
| `karpenter.inferentiaNodePool.instanceFamilies.allowed`          | Allowed instance families for the Inferentia node pool        | `["inf1","inf2"]`                                                                                                                                                  |
| `karpenter.inferentiaNodePool.instanceSizes.notAllowed`          | Not allowed instance sizes for the Inferentia node pool       | `["48xlarge"]`                                                                                                                                                     |
