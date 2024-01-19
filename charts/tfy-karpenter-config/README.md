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
yum install fuse -y
modprobe fuse

curl \
--silent \
--show-error \
--retry 10 \
--retry-delay 1 \
-L https://github.com/awslabs/soci-snapshotter/releases/download/v0.4.0/soci-snapshotter-0.4.0-linux-amd64.tar.gz \
-o soci-snapshotter-0.4.0-linux-amd64.tar.gz

tar -C /usr/local/bin -xvf soci-snapshotter-0.4.0-linux-amd64.tar.gz soci soci-snapshotter-grpc
rm soci-snapshotter-0.4.0-linux-amd64.tar.gz

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

mkdir -p /etc/soci-snapshotter-grpc

cat > /etc/soci-snapshotter-grpc/config.toml << EOF
[http]
MinWaitMsec=15
MaxRetries=2
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

This script **is based on**: https://github.com/truefoundry/infra-charts/blob/62515a0f2735fa0c1f656c4c45d69d532b89a7c3/charts/tfy-karpenter-config/values.yaml#L270.

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

CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}
echo containerd version "${CONTAINERD_VERSION}"

setup_soci() {( set -ex
yum install fuse -y
modprobe fuse

curl \
--silent \
--show-error \
--retry 10 \
--retry-delay 1 \
-L https://github.com/awslabs/soci-snapshotter/releases/download/v0.4.0/soci-snapshotter-0.4.0-linux-amd64.tar.gz \
-o soci-snapshotter-0.4.0-linux-amd64.tar.gz

tar -C /usr/local/bin -xvf soci-snapshotter-0.4.0-linux-amd64.tar.gz soci soci-snapshotter-grpc
rm soci-snapshotter-0.4.0-linux-amd64.tar.gz

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

mkdir -p /etc/soci-snapshotter-grpc

cat > /etc/soci-snapshotter-grpc/config.toml << EOF
[http]
MinWaitMsec=15
MaxRetries=2
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

if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
  echo "CONTAINERD_VERSION is not empty and within the range [1.5.0, 2.0)."
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

# soci will append more config later.
# We need to keep `[plugins.cri.containerd]` in the very end of the file
[plugins.cri.containerd]
default_runtime_name = "nvidia"
EOF

  setup_soci
else
  echo "CONTAINERD_VERSION is empty or not within the specified range."
fi
```

## Parameters

### Cluster configurations

| Name               | Description                 | Value |
| ------------------ | --------------------------- | ----- |
| `cluster.name`     | Name of the EKS cluster     | `""`  |
| `cluster.endpoint` | Endpoint of the EKS cluster | `""`  |

### Karpenter configurations

| Name                                                            | Description                                                                                                                     | Value                                                                                                                                                              |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `karpenter.instanceProfile`                                     | Instance profile of the karpenter                                                                                               | `""`                                                                                                                                                               |
| `karpenter.defaultProvisionerSpec.consolidation.enabled`        | Enable consolidation for default provisioner                                                                                    | `true`                                                                                                                                                             |
| `karpenter.defaultProvisionerSpec.ttlSecondsAfterEmpty`         | Seconds after which node should be deleted once it is empty. Either one of consolidation or ttlSecondsAfterEmpty should be used |                                                                                                                                                                    |
| `karpenter.defaultProvisionerSpec.providerRef.name`             | AWS node template name for default provisioner                                                                                  | `default`                                                                                                                                                          |
| `karpenter.gpuProvisionerSpec.enabled`                          | Enable GPU provisioner for GPU nodes                                                                                            | `false`                                                                                                                                                            |
| `karpenter.gpuProvisionerSpec.consolidation.enabled`            | Enable consolidation for GPU provisioner                                                                                        | `true`                                                                                                                                                             |
| `karpenter.gpuProvisionerSpec.ttlSecondsAfterEmpty`             | Seconds after which node should be deleted once it is empty. Either one of consolidation or ttlSecondsAfterEmpty should be used | `300`                                                                                                                                                              |
| `karpenter.gpuProvisionerSpec.capacityTypes`                    | Capacity types for GPU provisioner                                                                                              | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.gpuProvisionerSpec.zones`                            | Zones to launch instances for GPU provisioner                                                                                   | `[]`                                                                                                                                                               |
| `karpenter.gpuProvisionerSpec.instanceFamilies`                 | Instance families to launch instances for GPU provisioner                                                                       | `["p2","p3","g4dn","g5","p4d","p4de"]`                                                                                                                             |
| `karpenter.gpuProvisionerSpec.instanceSizes.notAllowed`         | Instance Sizes that are not allowed to launch instances for GPU provisioner                                                     | `["nano","micro","metal"]`                                                                                                                                         |
| `karpenter.gpuProvisionerSpec.providerRefName`                  | Name of AWS node template to be used for GPU provisioner                                                                        | `gpu-default`                                                                                                                                                      |
| `karpenter.controlPlaneProvisioner.enabled`                     | Enable control plane provisioner for control plane workloads                                                                    | `false`                                                                                                                                                            |
| `karpenter.controlPlaneProvisioner.consolidation.enabled`       | Enable consolidation for control plane provisioner                                                                              | `true`                                                                                                                                                             |
| `karpenter.controlPlaneProvisioner.ttlSecondsAfterEmpty`        | Time (in seconds) after which node will be drained. Either one of consolidation or ttlSecondsAfterEmpty can be used             | `30`                                                                                                                                                               |
| `karpenter.controlPlaneProvisioner.capacityTypes`               | Capacity types of control plane provisioner                                                                                     | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.controlPlaneProvisioner.zones`                       | Zones to launch instances for control plane workloads                                                                           | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneProvisioner.instanceFamilies.allowed`    | Allowed instance families for control plane workloads                                                                           | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneProvisioner.instanceFamilies.notAllowed` | Not allowed instance families for control plane workloads                                                                       | `["t3","t2","t3a","p2","p3","p4d","p4de","g4dn","g5","g4ad","inf1","inf2","trn1","trn1n","c1","cc1","cc2","cg1","cg2","cr1","g1","g2","hi1","hs1","m1","m2","m3"]` |
| `karpenter.controlPlaneProvisioner.instanceSizes.allowed`       | Allowed instance sizes for control plane workloads                                                                              | `[]`                                                                                                                                                               |
| `karpenter.controlPlaneProvisioner.instanceSizes.notAllowed`    | Not allowed instance sizes for control plane workloads                                                                          | `["nano","12xlarge","16xlarge","24xlarge","32xlarge","metal"]`                                                                                                     |
| `karpenter.controlPlaneProvisioner.providerRefName`             | Name of AWS node template to be used for control plane provisioner                                                              | `default`                                                                                                                                                          |
| `karpenter.controlPlaneProvisioner.taints`                      | Taints to be applied on the control plane provisioner nodes                                                                     | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneProvisioner.labels`                      | Labels to be applied on the control plane provisioner nodes                                                                     | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodeTemplate.enabled`                    | Size for the root volume attached to node                                                                                       | `false`                                                                                                                                                            |
| `karpenter.controlPlaneNodeTemplate.name`                       | Name of the AWS node template                                                                                                   | `controlplane-node-template`                                                                                                                                       |
| `karpenter.controlPlaneNodeTemplate.rootVolumeSize`             | Size for the root volume attached to node                                                                                       | `100Gi`                                                                                                                                                            |
| `karpenter.controlPlaneNodeTemplate.extraTags`                  | Additional tags for the node template.                                                                                          | `{}`                                                                                                                                                               |
| `karpenter.controlPlaneNodeTemplate.amiFamily`                  | AMI family to use for node template                                                                                             | `AL2`                                                                                                                                                              |
| `karpenter.defaultNodeTemplate.rootVolumeSize`                  | Size for the root volume attached to node                                                                                       | `100Gi`                                                                                                                                                            |
| `karpenter.defaultNodeTemplate.extraTags`                       | Additional tags for the node template.                                                                                          | `{}`                                                                                                                                                               |
| `karpenter.defaultNodeTemplate.amiFamily`                       | AMI family to use for node template                                                                                             | `AL2`                                                                                                                                                              |
| `karpenter.gpuDefaultNodeTemplate.rootVolumeSize`               | Size for the root volume attached to node                                                                                       | `100Gi`                                                                                                                                                            |
| `karpenter.gpuDefaultNodeTemplate.extraTags`                    | Additional tags for the gpu node template.                                                                                      | `{}`                                                                                                                                                               |
| `karpenter.gpuDefaultNodeTemplate.amiFamily`                    | AMI family to use for node template                                                                                             | `AL2`                                                                                                                                                              |
| `karpenter.inferentiaDefaultNodeTemplate.rootVolumeSize`        | Size for the root volume attached to node                                                                                       | `100Gi`                                                                                                                                                            |
| `karpenter.inferentiaDefaultNodeTemplate.extraTags`             | Additional tags for the node template.                                                                                          | `{}`                                                                                                                                                               |
| `karpenter.inferentiaDefaultNodeTemplate.amiFamily`             | AMI family to use for node template                                                                                             | `AL2`                                                                                                                                                              |
| `karpenter.inferentiaProvisionerSpec.enabled`                   | Enable inferentia provisioner for inferentia nodes                                                                              | `false`                                                                                                                                                            |
| `karpenter.inferentiaProvisionerSpec.consolidation.enabled`     | Enable consolidation for inferentia provisioner                                                                                 | `false`                                                                                                                                                            |
| `karpenter.inferentiaProvisionerSpec.ttlSecondsAfterEmpty`      | Seconds after which node should be deleted once it is empty. Either one of consolidation or ttlSecondsAfterEmpty should be used | `300`                                                                                                                                                              |
| `karpenter.inferentiaProvisionerSpec.capacityTypes`             | Capacity types for inferentia provisioner                                                                                       | `["spot","on-demand"]`                                                                                                                                             |
| `karpenter.inferentiaProvisionerSpec.zones`                     | Zones to launch instances for inferentia provisioner                                                                            | `[]`                                                                                                                                                               |
| `karpenter.inferentiaProvisionerSpec.instanceFamilies`          | Instance families to launch instances for inferentia provisioner                                                                | `["inf1","inf2"]`                                                                                                                                                  |
| `karpenter.inferentiaProvisionerSpec.instanceSizes.notAllowed`  | Instance Sizes that are not allowed to launch instances for inferentia provisioner                                              | `["48xlarge"]`                                                                                                                                                     |
| `karpenter.inferentiaProvisionerSpec.providerRefName`           | Name of AWS node template to be used for inferentia provisioner                                                                 | `inferentia-default`                                                                                                                                               |
