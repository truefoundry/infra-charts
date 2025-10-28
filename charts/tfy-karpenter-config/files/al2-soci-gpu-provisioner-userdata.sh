#!/bin/bash
set -ex

function version_lte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}
function version_lt() {
    ! version_lte "$2" "$1"
}

function setup_soci() {
ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
VERSION="0.11.1"
ARCHIVE="soci-snapshotter-$VERSION-linux-$ARCH.tar.gz"
KUBELET_CONFIG_FILEPATH="/etc/kubernetes/kubelet/kubelet-config.json"
BACKUP_KUBELET_CONFIG_FILEPATH="/etc/kubernetes/kubelet/kubelet-config.json.bak"

# --- Install soci-snapshotter ---
pushd /tmp
curl -sSL -o "$ARCHIVE" "https://github.com/awslabs/soci-snapshotter/releases/download/v$VERSION/$ARCHIVE"
curl -sSL -o "$ARCHIVE.sha256sum" "https://github.com/awslabs/soci-snapshotter/releases/download/v$VERSION/$ARCHIVE.sha256sum"
sha256sum -c "$ARCHIVE.sha256sum"
tar -xvzf "$ARCHIVE" -C /usr/local/bin soci-snapshotter-grpc
rm -f "$ARCHIVE" "$ARCHIVE.sha256sum"
popd

# --- Configure soci-snapshotter ---
mkdir -p /etc/soci-snapshotter-grpc
cat <<EOF > /etc/soci-snapshotter-grpc/config.toml
[cri_keychain]
enable_keychain = true
image_service_path = "/run/containerd/containerd.sock"
EOF

# --- Enable and start soci-snapshotter ---
curl -sSL -o /etc/systemd/system/soci-snapshotter.service "https://raw.githubusercontent.com/awslabs/soci-snapshotter/v$VERSION/soci-snapshotter.service"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now soci-snapshotter
systemctl status soci-snapshotter

# --- Configure containerd to use soci snapshotter ---
cat > /etc/containerd/config.d/soci.toml <<EOF
[plugins."io.containerd.grpc.v1.cri".containerd]
default_runtime_name = "nvidia"
discard_unpacked_layers = true
snapshotter = "soci"
disable_snapshot_annotations = false
[proxy_plugins]
[proxy_plugins.soci]
address = '/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock'
type = 'snapshot'

[proxy_plugins.soci.exports]
root = '/var/lib/soci-snapshotter-grpc'

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
BinaryName = "/usr/bin/nvidia-container-runtime"
EOF

# --- Add kubelet imageServiceEndpoint ---
jq '.imageServiceEndpoint="unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"' "$KUBELET_CONFIG_FILEPATH" > "$KUBELET_CONFIG_FILEPATH.tmp"
mv "$KUBELET_CONFIG_FILEPATH.tmp" "$KUBELET_CONFIG_FILEPATH"
}

# --- Check containerd version ---
CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}

if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
  setup_soci
else
  echo "CONTAINERD_VERSION is empty or not within the specified range or we could not find the sandbox image."
fi

