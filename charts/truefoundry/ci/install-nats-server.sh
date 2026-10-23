#!/usr/bin/env bash
# Installs the nats-server release matching the chart's NATS image tag (tfyNats.container.image.tag), so
# ci/test-mtls.sh validates the rendered config with the same server version. Verifies the release
# SHA256SUMS and fails on any download or checksum error.
# Usage: ./charts/truefoundry/ci/install-nats-server.sh [install dir, default /usr/local/bin]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-/usr/local/bin}"
version="$(yq '.tfyNats.container.image.tag' "$ROOT/values.yaml")"
if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "::error::tfyNats.container.image.tag is '$version', not a nats-server release version" >&2
  exit 1
fi
base="https://github.com/nats-io/nats-server/releases/download/v${version}"
asset="nats-server-v${version}-linux-amd64.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fsSL --retry 3 -o "$TMP/$asset" "$base/$asset"
curl -fsSL --retry 3 -o "$TMP/SHA256SUMS" "$base/SHA256SUMS"
(cd "$TMP" && grep " ${asset}\$" SHA256SUMS | sha256sum -c -)
tar -xzf "$TMP/$asset" -C "$TMP"
if [[ -w $DEST ]]; then
  install "$TMP/nats-server-v${version}-linux-amd64/nats-server" "$DEST/"
else
  sudo install "$TMP/nats-server-v${version}-linux-amd64/nats-server" "$DEST/"
fi
"$DEST/nats-server" --version
