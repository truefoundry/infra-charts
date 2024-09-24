#!/bin/bash

set -ex

version_lte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

version_lt() {
    ! version_lte "$2" "$1"
}

disable_nvidia_gsp() {

    if lsmod | grep -P "^nvidia_drm"; then
        rmmod nvidia_drm
    fi

    if lsmod | grep -P "^nvidia_modeset"; then
        rmmod nvidia_modeset
    fi

    if lsmod | grep -P "^nvidia_uvm"; then
        rmmod nvidia_uvm
    fi

    if lsmod | grep -P "^nvidia"; then
        rmmod nvidia
    fi

    echo "Writing NVreg_EnableGpuFirmware=0 to /etc/modprobe.d/nvidia.conf"
    echo "options nvidia NVreg_EnableGpuFirmware=0" | tee --append /etc/modprobe.d/nvidia.conf
    echo "Writing NVreg_EnableGpuFirmware=0 to /etc/modprobe.d/nvidia-gsp.conf"
    echo "options nvidia NVreg_EnableGpuFirmware=0" | tee --append /etc/modprobe.d/nvidia-gsp.conf
    echo "Running dracut"
    dracut -f
}

# This needs the driver to be already loaded
# Which is not the case with new EKS AMIs that use Open Kernel Module for NVIDIA drivers
if [ -f /proc/driver/nvidia/version ]; then
    if grep "Open Kernel Module" /proc/driver/nvidia/version; then
        echo "NVIDIA driver is using the open source kernel module. Skipping disabling GSP."
    else
        echo "NVIDIA driver is using proprietary NVIDIA kernel module. Disabling GSP."
        disable_nvidia_gsp
    fi
else
    echo "/proc/driver/nvidia/version does not exist. Skipping disabling GSP."
fi

# SOCI

CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}
CONTAINERD_CONFIG_FILEPATH="/etc/eks/containerd/containerd-config.toml"
BACKUP_CONTAINERD_CONFIG_FILEPATH="$CONTAINERD_CONFIG_FILEPATH.bak"
KUBELET_CONFIG_FILEPATH="/etc/kubernetes/kubelet/kubelet-config.json"
BACKUP_KUBELET_CONFIG_FILEPATH="/etc/kubernetes/kubelet/kubelet-config.json.bak"
SOCI_RELEASE_VERSION="0.7.0"
SOCI_TAR_CHECKSUM="8766cdd479272dcc86299e70a0f7a9343f940c98285c1491bb3c3cdc05b26f47"
SOCI_TAR_FILENAME="soci-snapshotter-$SOCI_RELEASE_VERSION-linux-amd64.tar.gz"
SOCI_CONFIG_DIR="/etc/soci-snapshotter-grpc/"
SOCI_CONFIG_FILEPATH="$SOCI_CONFIG_DIR/config.toml"
SOCI_SYSTEMD_SERVICE_FILEPATH="/etc/systemd/system/soci-snapshotter.service"
cp $CONTAINERD_CONFIG_FILEPATH $BACKUP_CONTAINERD_CONFIG_FILEPATH
cp $KUBELET_CONFIG_FILEPATH $BACKUP_KUBELET_CONFIG_FILEPATH

setup_soci() {( set -ex

yum install fuse -y
modprobe fuse

curl \
--silent \
--show-error \
--retry 3 \
--retry-delay 1 \
-L https://github.com/awslabs/soci-snapshotter/releases/download/v${SOCI_RELEASE_VERSION}/soci-snapshotter-${SOCI_RELEASE_VERSION}-linux-amd64.tar.gz \
-o $SOCI_TAR_FILENAME
echo "$SOCI_TAR_CHECKSUM $SOCI_TAR_FILENAME" | sha256sum -c

tar -C /usr/local/bin -xvf $SOCI_TAR_FILENAME soci soci-snapshotter-grpc
rm $SOCI_TAR_FILENAME

cat > $SOCI_SYSTEMD_SERVICE_FILEPATH << EOF
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

mkdir -p $SOCI_CONFIG_DIR

cat > $SOCI_CONFIG_FILEPATH << EOF
[cri_keychain]
enable_keychain=true
image_service_path="/run/containerd/containerd.sock"
EOF

systemctl daemon-reload
systemctl enable --now soci-snapshotter
systemctl status soci-snapshotter

echo patching $CONTAINERD_CONFIG_FILEPATH
cat > $CONTAINERD_CONFIG_FILEPATH << EOF
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"
imports = ["/etc/containerd/config.d/*.toml"]

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
[proxy_plugins.soci.exports]
root = "/var/lib/soci-snapshotter-grpc"
##
EOF

jq '.imageServiceEndpoint="unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"' "$KUBELET_CONFIG_FILEPATH" > "$KUBELET_CONFIG_FILEPATH.tmp"
mv "$KUBELET_CONFIG_FILEPATH.tmp" "$KUBELET_CONFIG_FILEPATH"
)}

# containerd <1.7.16 does not enforce storage limits
if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
setup_soci
else
  echo "CONTAINERD_VERSION is empty or not within the specified range or we could not find the sandbox image."
fi
