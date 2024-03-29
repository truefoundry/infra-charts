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

add_default_runtime_name_nvidia_in_containerd_config() {

    echo "Patching /etc/eks/containerd/containerd-config.toml"
    mkdir -p /etc/eks/containerd
    cp /etc/eks/containerd/containerd-config.toml /etc/eks/containerd/containerd-config.toml.orig

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

CONTAINERD_VERSION_OUTPUT="$(containerd --version)"
IFS=" " read -r -a  CONTAINERD_VERSION_STRING <<< "${CONTAINERD_VERSION_OUTPUT}"
CONTAINERD_VERSION=${CONTAINERD_VERSION_STRING[2]}
echo "${CONTAINERD_VERSION}"

if [ -n "$CONTAINERD_VERSION" ] && version_lte "1.5.0" "$CONTAINERD_VERSION" && version_lt "$CONTAINERD_VERSION" "2.0"; then
    echo "CONTAINERD_VERSION is not empty and within the range [1.5.0, 2.0)."
    if grep -P "^version = 2" /etc/eks/containerd/containerd-config.toml; then
        echo "Containerd config version is 2. Skipping patching."
    else
        add_default_runtime_name_nvidia_in_containerd_config
    fi
else
    echo "CONTAINERD_VERSION is empty or not within the specified range."
fi


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
