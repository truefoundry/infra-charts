# tfy-tailscale-config

Tailscale custom resources for a TrueFoundry cluster: `ProxyClass`es, `ProxyGroup`s,
session recording, and the RBAC that tailnet identities are impersonated into.

**This chart does not install the Tailscale operator.** It ships only custom resources, in
the same way `tfy-cert-manager-config` ships only Issuers and Certificates. The operator —
and with it the `tailscale.com` CRDs — must already be installed and reconciled before this
chart is applied. Installing both in a single Helm release is not possible: the operator
chart templates its CRDs rather than using Helm's `crds/` directory, and Helm resolves REST
mappings for every rendered object before applying any of them.

## Prerequisites

All of these fail *silently* — a missing one shows up as a `ProxyGroup` stuck at
`0/N proxy backends ready` with nothing logged:

- The Tailscale Kubernetes operator, running and reconciled.
- Every tag this chart derives, present in the tailnet policy file's `tagOwners`.
- A matching `autoApprovers.services` entry for each **Service** tag. Note the asymmetry:
  the key is a tag the *Service* carries, the value is the tags of *devices* allowed to
  advertise it. The recorder deliberately gets no entry.
- An OAuth client or federated identity carrying the `services` scope.
- The tailnet-wide **HTTPS Certificates** toggle enabled in the admin console.
- The RBAC bindings applied **before** the policy file impersonates their groups.

## Device tags vs service tags

The single most costly thing to get wrong here. Devices tagged one way and Services another
reports healthy and is unreachable.

| | Set by | What it tags | Matched by access rules |
|---|---|---|---|
| `tailnet.roleTags.*` | `ProxyGroup.spec.tags` (a YAML **list**) | the proxy **devices** | no |
| `serviceTags.*` | `proxyConfig.defaultTags` or the `tailscale.com/tags` annotation (a comma-separated **string**) | the Tailscale **Services** | **yes** |

The authoritative value for Ingress- and LoadBalancer-backed Services is
`proxyConfig.defaultTags` on the *operator* release, which this chart does not own. An
explicit `tailscale.com/tags` annotation overrides it for that Service, so the two must be
kept in step.

**Egress inverts this.** An egress `ProxyGroup` advertises no Tailscale Service, so there
is nothing for `serviceTags` or `proxyConfig.defaultTags` to attach to. The only identity
in play is the proxy device's, from `ProxyGroup.spec.tags` — and it appears in the grant as
**`src`**, not `dst`. It also needs **no `autoApprovers.services` entry**, which is the one
place in the policy file where that absence is correct rather than the usual silent stall.

## Write-once values

Changing any of these re-registers the device on a new `100.x` address and orphans any DNS
record pointing at it:

- `clusterSlug`
- `proxyGroups.ingress.hostnamePrefix`
- `proxyGroups.apiserver.hostname`
- `proxyGroups.apiserver.hostnamePrefix`
- `proxyGroups.egress.hostnamePrefix`
- `recorder.name`
- `istioGateway.service.hostname`

Tags are **not** in this set — retagging needs no device recreate, though a change must be
applied to both `spec.tags` and the device API or it reverts at next provisioning.

Reducing `replicas` on a `ProxyGroup` deletes devices and their state Secrets. The
`ProxyGroup` and `Recorder` templates carry `argocd.argoproj.io/sync-options: Prune=false`
for the same reason.

## Cluster archetypes

`ci/` holds four worked examples, which double as lint fixtures:

| File | Shape |
|---|---|
| `mgmt-values.yaml` | full install — admin UIs on `*.mgmt` through the Istio gateway |
| `gateway-pop-values.yaml` | kubectl access only — no ingress proxies, no recorder |
| `compute-plane-values.yaml` | egress only — reaches the tailnet, exposes nothing to it |
| `minimal-values.yaml` | portable core, no TrueFoundry-specific infrastructure |

## Parameters

### Cluster identity

| Name          | Description                                                                                                                 | Value          |
| ------------- | --------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `clusterName` | Name of the cluster, as supplied by the inframold.                                                                          | `cluster-name` |
| `clusterSlug` | Short identifier used in tailnet hostnames and ACL tags. Defaults to clusterName with a leading "tfy-" removed, if present. | `""`           |

### Tailnet device tags

| Name                   | Description                                                                                                                                                               | Value     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `tailnet.baseTag`      | Device tag carried by every proxy. Never name this in an access rule -- it is the chart default on every cluster, so a rule naming it silently widens to the whole fleet. | `tag:k8s` |
| `tailnet.roleTags`     | Per-role DEVICE tags. Each defaults to "tag:k8s-<role>-<clusterSlug>". Override to pin an existing tag; tags must match ^tag:[a-zA-Z][a-zA-Z0-9-]*$ (no underscores).     | `{}`      |
| `tailnet.coarse.env`   | Environment token -- dev, stage, prod, demo.                                                                                                                              | `""`      |
| `tailnet.coarse.cloud` | Cloud token -- aws, azu, gcp.                                                                                                                                             | `""`      |
| `tailnet.coarse.plane` | Plane token -- ctl, cmp, gtw.                                                                                                                                             | `""`      |

### Tailnet service tags

| Name                  | Description                                                                                                                                                                                               | Value |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `serviceTags.ingress` | Comma-separated tags applied to Services fronted by the ingress ProxyGroup. Note this is a STRING, not a list -- unlike ProxyGroup.spec.tags. Defaults to "<tailnet.baseTag>,<tailnet.roleTags.ingress>". | `""`  |

### Placement

| Name                    | Description                                                               | Value |
| ----------------------- | ------------------------------------------------------------------------- | ----- |
| `placement.tolerations` | Tolerations for Tailscale proxy and recorder pods.                        | `[]`  |
| `placement.affinity`    | Affinity for Tailscale proxy and recorder pods.                           | `{}`  |
| `placement.resources`   | Resource requests and limits for Tailscale proxy and recorder containers. | `{}`  |

### Proxy classes

| Name                                    | Description                                                                                                                                                                                                                | Value                          |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| `proxyClasses.default.enabled`          | Create the default ProxyClass, used by ingress proxies.                                                                                                                                                                    | `true`                         |
| `proxyClasses.default.name`             | Name of the default ProxyClass.                                                                                                                                                                                            | `tfy-default`                  |
| `proxyClasses.default.metricsEnabled`   | Expose proxy metrics.                                                                                                                                                                                                      | `true`                         |
| `proxyClasses.apiserver.enabled`        | Create the ProxyClass used by the kube-apiserver ProxyGroup.                                                                                                                                                               | `true`                         |
| `proxyClasses.apiserver.name`           | Name of the kube-apiserver ProxyClass.                                                                                                                                                                                     | `tfy-apiserver`                |
| `proxyClasses.apiserver.image`          | Pinned k8s-proxy image. This image is NOT settable through the operator chart's values -- a ProxyClass is the only way to override it, and leaving it unpinned runs :latest on the highest-privilege pod in the namespace. | `tailscale/k8s-proxy:v1.102.2` |
| `proxyClasses.apiserver.metricsEnabled` | Expose proxy metrics.                                                                                                                                                                                                      | `true`                         |

### Proxy groups

| Name                                   | Description                                                                                                                              | Value             |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `proxyGroups.ingress.enabled`          | Deploy a ProxyGroup of type "ingress".                                                                                                   | `true`            |
| `proxyGroups.ingress.name`             | Kubernetes object name of the ingress ProxyGroup.                                                                                        | `ingress-proxies` |
| `proxyGroups.ingress.replicas`         | Number of ingress proxy replicas. Reducing this DELETES devices and their state Secrets -- it is not a safe casual edit.                 | `2`               |
| `proxyGroups.ingress.hostnamePrefix`   | Tailnet-global device hostname prefix. Defaults to "<clusterSlug>-ing". Max 62 chars, lowercase, must match ^[a-z0-9][a-z0-9-]{0,61}$.   | `""`              |
| `proxyGroups.apiserver.enabled`        | Deploy a ProxyGroup of type "kube-apiserver".                                                                                            | `true`            |
| `proxyGroups.apiserver.name`           | Kubernetes object name of the kube-apiserver ProxyGroup.                                                                                 | `k8s-apiserver`   |
| `proxyGroups.apiserver.replicas`       | Number of kube-apiserver proxy replicas. Reducing this DELETES devices and their state Secrets.                                          | `2`               |
| `proxyGroups.apiserver.hostname`       | Tailnet-global hostname, must be UNIQUE across the whole tailnet. Defaults to "<clusterSlug>-k8s". Max 63 chars, must not end in a dash. | `""`              |
| `proxyGroups.apiserver.hostnamePrefix` | Tailnet-global DEVICE hostname prefix. Deliberately has NO default -- see below. Max 62 chars, must match ^[a-z0-9][a-z0-9-]{0,61}$.     | `""`              |
| `proxyGroups.apiserver.mode`           | kube-apiserver proxy mode. "auth" impersonates tailnet identities against Kubernetes RBAC.                                               | `auth`            |
| `proxyGroups.egress.enabled`           | Deploy a ProxyGroup of type "egress", so cluster pods can reach tailnet targets. Off by default -- most clusters egress nowhere.         | `false`           |
| `proxyGroups.egress.name`              | Kubernetes object name of the egress ProxyGroup.                                                                                         | `egress-proxies`  |
| `proxyGroups.egress.replicas`          | Number of egress proxy replicas. Reducing this DELETES devices and their state Secrets.                                                  | `2`               |
| `proxyGroups.egress.hostnamePrefix`    | Tailnet-global device hostname prefix. Defaults to "<clusterSlug>-egress". Max 62 chars, must match ^[a-z0-9][a-z0-9-]{0,61}$.           | `""`              |

### Egress targets

| Name                | Description                                                                                                                                                                | Value   |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `egress.enabled`    | Mirror the targets below into the cluster as ExternalName Services.                                                                                                        | `false` |
| `egress.proxyGroup` | ProxyGroup that carries this traffic. Defaults to proxyGroups.egress.name.                                                                                                 | `""`    |
| `egress.items`      | Map of tailnet targets to mirror. Each takes a namespace, exactly one of fqdn or ip, a list of ports, and an optional name for the Service object (defaulting to the key). | `{}`    |

### Session recording

| Name                | Description                                                                                                                                                                      | Value  |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `recorder.enabled`  | Deploy a Recorder for kubectl session recording.                                                                                                                                 | `true` |
| `recorder.name`     | Kubernetes object name. Tailnet-global and WRITE-ONCE -- the DEVICE is named "<name>-0", so the effective budget is 61 characters, not 63. Defaults to "<clusterSlug>-recorder". | `""`   |
| `recorder.replicas` | Number of recorder replicas.                                                                                                                                                     | `1`    |
| `recorder.enableUI` | Serve the recorder's web UI on the tailnet.                                                                                                                                      | `true` |
| `recorder.storage`  | Recording storage. An empty object means emptyDir, which loses every recording on pod restart; set s3 for durable storage.                                                       | `{}`   |

### RBAC

| Name                          | Description                                                                                                                                                                                | Value           |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- |
| `rbac.create`                 | Create the tailnet RBAC ClusterRole and ClusterRoleBindings.                                                                                                                               | `true`          |
| `rbac.breakGlass.enabled`     | Bind a break-glass group directly to cluster-admin, independent of the SCIM-synced tiers.                                                                                                  | `true`          |
| `rbac.breakGlass.group`       | Impersonated group name for break-glass access.                                                                                                                                            | `tailnet-infra` |
| `rbac.breakGlass.clusterRole` | ClusterRole granted to the break-glass group.                                                                                                                                              | `cluster-admin` |
| `rbac.tiers`                  | Access tiers, each binding an impersonated group to a list of ClusterRoles. Every role named here must already exist -- a binding to a missing ClusterRole is accepted and grants nothing. | `{}`            |

### TrueFoundry integrations


### Platform surfaces on their own tailnet names (Mode I)

| Name                   | Description                                                                                                                                                                                 | Value   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingresses.enabled`    | Publish admin UIs to the tailnet as Tailscale Ingresses.                                                                                                                                    | `false` |
| `ingresses.proxyGroup` | ProxyGroup that fronts these Ingresses. Defaults to proxyGroups.ingress.name.                                                                                                               | `""`    |
| `ingresses.items`      | Map of admin UIs to expose. Each entry takes namespace, service, port, and an optional host (defaulting to "<clusterSlug>-<key>"). The operator keeps only the first DNS label of the host. | `{}`    |

### Platform surfaces on our own domain (Mode H)

| Name                            | Description                                                                                                                                                                                          | Value                   |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `mgmt.enabled`                  | Route the surfaces below through the Istio gateway.                                                                                                                                                  | `false`                 |
| `mgmt.baseDomain`               | Host suffix for these surfaces, e.g. "mgmt.<clusterSlug>.internal.example.com". Must be covered by istioGateway.hosts and certificate.dnsNames -- the render fails if the gateway does not serve it. | `""`                    |
| `mgmt.gateway`                  | Gateway to bind to, as "<namespace>/<name>". Defaults to the one this chart creates. Setting it skips the coverage check, since another chart's hosts are not visible here.                          | `""`                    |
| `mgmt.items`                    | Map of surfaces to route. Each takes namespace, service, port, an optional host (defaulting to the key) and an optional name for the VirtualService object.                                          | `{}`                    |
| `istioGateway.enabled`          | Create a second Istio Gateway listener and a Tailscale Service in front of it. Requires an existing Istio ingress gateway deployment.                                                                | `false`                 |
| `istioGateway.name`             | Name of the Istio Gateway resource.                                                                                                                                                                  | `tfy-tailnet-wildcard`  |
| `istioGateway.namespace`        | Namespace holding the Istio ingress gateway.                                                                                                                                                         | `istio-system`          |
| `istioGateway.selector`         | Pod selector for the existing Istio ingress gateway deployment.                                                                                                                                      | `{}`                    |
| `istioGateway.port`             | Port the tailnet listener binds on. Deliberately not 443, which the public gateway already uses.                                                                                                     | `8443`                  |
| `istioGateway.hosts`            | Hosts served on the tailnet listener.                                                                                                                                                                | `[]`                    |
| `istioGateway.credentialName`   | TLS secret for the tailnet listener. Must match certificate.secretName when that is enabled.                                                                                                         | `""`                    |
| `istioGateway.service.name`     | Name of the Tailscale LoadBalancer Service. Must NOT be "tfy-istio-ingress" -- the control plane reads that name to auto-populate base domains.                                                      | `istio-ingress-tailnet` |
| `istioGateway.service.hostname` | Tailnet hostname for the gateway Service. Defaults to "<clusterSlug>-gw".                                                                                                                            | `""`                    |

### Plain L3 Services on the tailnet (Mode J ingress)

| Name                         | Description                                                                                                                                | Value   |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `tailnetServices.enabled`    | Expose the Services listed below to the tailnet at L3.                                                                                     | `false` |
| `tailnetServices.proxyGroup` | ProxyGroup that fronts them. Defaults to proxyGroups.ingress.name.                                                                         | `""`    |
| `tailnetServices.items`      | Map of targets. Each needs namespace, selector, hostname and ports; name defaults to "<key>-tailnet" and tags to the ingress Service tags. | `{}`    |

### ACME issuer

| Name                         | Description                                                                                                                                                                                                                                                                                                                       | Value                                            |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `issuer.enabled`             | Create the ACME issuer named below. Requires cert-manager already installed.                                                                                                                                                                                                                                                      | `false`                                          |
| `issuer.kind`                | Issuer or ClusterIssuer. ClusterIssuer keeps the DNS-01 credential out of istio-system and serves every namespace; use Issuer only to match an existing namespaced one.                                                                                                                                                           | `ClusterIssuer`                                  |
| `issuer.name`                | Name of the issuer. Must match certificate.issuerRef.name when both are enabled -- the render fails otherwise.                                                                                                                                                                                                                    | `letsencrypt-cloudflare`                         |
| `issuer.namespace`           | Namespace for the issuer. Used only when kind is Issuer; a ClusterIssuer is cluster-scoped.                                                                                                                                                                                                                                       | `istio-system`                                   |
| `issuer.email`               | Contact address for the ACME account. Required by Let's Encrypt.                                                                                                                                                                                                                                                                  | `""`                                             |
| `issuer.server`              | ACME directory URL. Defaults to Let's Encrypt PRODUCTION, whose weekly budget is shared across every name under the parent domain -- iterate on https://acme-staging-v02.api.letsencrypt.org/directory instead.                                                                                                                   | `https://acme-v02.api.letsencrypt.org/directory` |
| `issuer.privateKeySecretRef` | Secret the ACME account key is written to. Created by cert-manager, not by this chart.                                                                                                                                                                                                                                            | `letsencrypt-cloudflare-account-key`             |
| `issuer.solvers`             | Solver list, passed through verbatim. A DNS-01 solver works identically on EKS, AKS and GKE, so one definition covers the fleet. Any Secret named here must already exist -- this chart never templates a credential -- in cert-manager's --cluster-resource-namespace for a ClusterIssuer, or in issuer.namespace for an Issuer. | `[]`                                             |
| `certificate.enabled`        | Create a cert-manager Certificate for the tailnet wildcard. Requires cert-manager, and an Issuer -- either pre-existing or from the issuer block above.                                                                                                                                                                           | `false`                                          |
| `certificate.name`           | Name of the Certificate resource.                                                                                                                                                                                                                                                                                                 | `""`                                             |
| `certificate.namespace`      | Namespace for the Certificate.                                                                                                                                                                                                                                                                                                    | `istio-system`                                   |
| `certificate.secretName`     | Secret the issued certificate is written to.                                                                                                                                                                                                                                                                                      | `""`                                             |
| `certificate.issuerRef`      | cert-manager issuer reference. Points at an existing Issuer unless the issuer block above creates one.                                                                                                                                                                                                                            | `{}`                                             |
| `certificate.dnsNames`       | DNS names on the certificate.                                                                                                                                                                                                                                                                                                     | `[]`                                             |
| `certificate.duration`       | Certificate lifetime. Use Go's normalised form -- the API server rewrites "2160h" to "2160h0m0s", which Argo CD then reports as permanent drift.                                                                                                                                                                                  | `2160h0m0s`                                      |
| `certificate.renewBefore`    | How long before expiry renewal starts. Normalised form, same reason as duration.                                                                                                                                                                                                                                                  | `360h0m0s`                                       |

### Extra

| Name           | Description                                               | Value |
| -------------- | --------------------------------------------------------- | ----- |
| `extraObjects` | Arbitrary additional manifests to render with this chart. | `[]`  |

