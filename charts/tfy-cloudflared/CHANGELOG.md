## Changelog

### 0.3.0

- **Breaking:** Default install namespace changed from `cloudflared` to `tfy-cloudflared`. See [Migrating from the `cloudflared` namespace](./README.md#migrating-from-the-cloudflared-namespace-chart-030) in the README for step-by-step migration instructions.
- **Breaking:** `caddy.enabled` default changed from `false` to `true`. Existing installs that explicitly set `caddy.enabled=false` are unaffected; fresh installs now deploy the Caddy private endpoint router out of the box.

### 0.2.0

- **Breaking:** Removed the `/proxy/` URL segment from all 4 Caddy `path_regexp` matchers. The `<tunnel-identifier>` prefix is now required. See [Migrating from the `/proxy/` URL scheme](./README.md#migrating-from-the-proxy-url-scheme-chart--020) in the README for the URL substitution rules.

### 0.1.1

- Initial release of the chart vendored from the upstream Cloudflare Tunnel chart, with optional Caddy private endpoint router.
