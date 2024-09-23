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
