## Changelog

### 0.3.0

- **Breaking:** Default install namespace changed from `cloudflared` to `tfy-cloudflared`.
- **Breaking:** `caddy.enabled` default changed from `false` to `true`. Existing installs that explicitly set `caddy.enabled=false` are unaffected; fresh installs now deploy the Caddy private endpoint router out of the box.

#### Migrating from the `cloudflared` namespace

If you have an existing release in the `cloudflared` namespace, follow these steps to move it.

1. **Install the chart in the new namespace** using the same values file (with the same `tunnel.token` / `tunnel.existingSecret`) you used for the original install:

   ```bash
   helm upgrade --install tfy-cloudflared truefoundry/tfy-cloudflared \
     --namespace tfy-cloudflared \
     --create-namespace \
     -f <your-values-overrides>.yaml
   ```

2. **Verify the new release is healthy** before tearing down the old one:

   ```bash
   kubectl rollout status deployment -n tfy-cloudflared \
     -l app.kubernetes.io/instance=tfy-cloudflared --timeout=120s
   ```

3. **Uninstall the old release** once traffic is confirmed flowing through the new namespace:

   ```bash
   helm uninstall tfy-cloudflared -n cloudflared
   kubectl delete namespace cloudflared
   ```

> **Note:** Cloudflare tunnels are outbound-only — running the old and new releases in parallel during the cutover is safe; both establish their own connections to Cloudflare's edge using the same token.

##### Rollback

If the new namespace deployment has issues, the old `cloudflared` namespace release is still active (assuming you haven't run step 3). Uninstall the new release:

```bash
helm uninstall tfy-cloudflared -n tfy-cloudflared
```

### 0.2.0

- **Breaking:** Removed the `/proxy/` URL segment from all 4 Caddy `path_regexp` matchers. The `<tunnel-identifier>` prefix is now required.

#### Migrating from the `/proxy/` URL scheme

Prior to `0.2.0`, Caddy accepted URLs with an explicit `/proxy/` segment:

```
# Old scheme (no longer supported)
<tunnel-url>/proxy/http://host:port/path
<tunnel-url>/proxy/https://host:port/path
<tunnel-url>/proxy/https/host:port/path
<tunnel-url>/proxy/host:port/path
```

The `/proxy/` segment has been removed. The `<tunnel-identifier>` prefix is now **required**.

1. **Identify all callers** that construct Caddy proxy URLs — SDKs, agents, platform services, scripts, or any code that builds URLs pointing at the Cloudflare tunnel endpoint.

2. **Rewrite URLs** using the following substitution rules (replace `<tunnel-identifier>` with your actual tunnel identifier):

   | Old URL | New URL |
   | ------- | ------- |
   | `.../proxy/http://host:port/path` | `.../<tunnel-identifier>/http://host:port/path` |
   | `.../proxy/https://host:port/path` | `.../<tunnel-identifier>/https://host:port/path` |
   | `.../proxy/https/host:port/path` | `.../<tunnel-identifier>/https/host:port/path` |
   | `.../proxy/host:port/path` | `.../<tunnel-identifier>/host:port/path` |

3. **Deploy the new chart version:**

   ```bash
   helm upgrade tfy-cloudflared truefoundry/tfy-cloudflared \
     --namespace tfy-cloudflared \
     --reuse-values
   ```

4. **Smoke-test** after the rollout completes:

   ```bash
   # Should return a response from your target service
   curl -v https://<tunnel-url>/<tunnel-identifier>/http://<host>:<port>/healthz
   ```

##### Rollback

If you need to revert to the old `/proxy/` matchers while callers are updated, roll back the Helm release to the previous revision — this restores the previous Caddyfile configmap and triggers a Caddy restart automatically:

```bash
helm rollback tfy-cloudflared -n tfy-cloudflared
```

### 0.1.1

- Initial release of the chart vendored from the upstream Cloudflare Tunnel chart, with optional Caddy private endpoint router.
