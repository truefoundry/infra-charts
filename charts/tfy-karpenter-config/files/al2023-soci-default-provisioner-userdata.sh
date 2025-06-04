MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  kubelet:
    config:
      imageServiceEndpoint: unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock
  containerd: 
    config: |
      [proxy_plugins.soci]
        type = "snapshot"
        address = "/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"
        [proxy_plugins.soci.exports]
          root = "/var/lib/soci-snapshotter-grpc"
      [plugins."io.containerd.grpc.v1.cri".containerd]
        snapshotter = "soci"
        # This line is required for containerd to send information about how to lazily load the image to the snapshotter
        disable_snapshot_annotations = false

--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
# Set environment variables
ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
version="0.9.0"
ARCHIVE=soci-snapshotter-$version-linux-$ARCH.tar.gz

pushd /tmp
# Download, verify, and install the soci-snapshotter
curl --silent --location --fail --output $ARCHIVE https://github.com/awslabs/soci-snapshotter/releases/download/v$version/$ARCHIVE
curl --silent --location --fail --output $ARCHIVE.sha256sum https://github.com/awslabs/soci-snapshotter/releases/download/v$version/$ARCHIVE.sha256sum
sha256sum ./$ARCHIVE.sha256sum
tar xzvf ./$ARCHIVE -C /usr/local/bin soci-snapshotter-grpc
rm ./$ARCHIVE
rm ./$ARCHIVE.sha256sum

# Configure the SOCI snapshotter for CRI credentials
mkdir -p /etc/soci-snapshotter-grpc
cat <<EOF > /etc/soci-snapshotter-grpc/config.toml
[cri_keychain]
# This tells the soci-snapshotter to act as a proxy ImageService
# and to cache credentials from requests to pull images.
enable_keychain = true
# This tells the soci-snapshotter where containerd's ImageService is located.
image_service_path = "/run/containerd/containerd.sock"
EOF

# Start the soci-snapshotter
curl --silent --location --fail --output /etc/systemd/system/soci-snapshotter.service https://raw.githubusercontent.com/awslabs/soci-snapshotter/v$version/soci-snapshotter.service
systemctl daemon-reload
systemctl enable --now soci-snapshotter
systemctl status soci-snapshotter

popd

--BOUNDARY--