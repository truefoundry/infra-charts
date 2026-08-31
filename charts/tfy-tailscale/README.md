# tfy-tailscale

The Tailscale Kubernetes operator, packaged for TrueFoundry clusters. It is a thin wrapper
over the upstream `tailscale-operator` chart: a namespace with the right labels, render-time
validation of the values that fail silently, and fleet-wide defaults.

The custom resources the operator reconciles — `ProxyClass`es, `ProxyGroup`s, the session
`Recorder`, and the RBAC tailnet identities are impersonated into — ship separately in
[`tfy-tailscale-config`](../tfy-tailscale-config), following the
`tfy-karpenter` / `tfy-karpenter-config` split.

**The two cannot be a single release.** The operator chart templates its CRDs rather than
using Helm's `crds/` directory, and Helm resolves REST mappings for every rendered object
before applying any of them — so a release containing both a CRD and a custom resource of
that kind fails. Install this chart first and let it reconcile.

## The namespace is not configurable

It is always `.Release.Namespace`, because that is where upstream puts every resource. Set
it with `helm -n` or Argo CD's `destination.namespace`.

The namespace needs `istio-injection: disabled` — a sidecar's iptables fights the proxy
DNAT. This chart creates it with that label. Anything else that creates the namespace first
(Argo CD's `CreateNamespace=true`, `helm --create-namespace`) collides, and needs
`namespace.create=false` with the labels moved to `syncPolicy.managedNamespaceMetadata`.

## Credentials

Three mutually exclusive paths, in precedence order: `oauthSecretVolume`, then
`oauth.audience`, then `oauth.clientSecret`. **A lower-ranked one is silently ignored, not
merged** — upstream's own `values.yaml` comment claims the reverse for the audience/secret
pair and is wrong. This chart fails at render time rather than let you set two.

`oauth.clientId` is required on both non-volume paths: upstream gates the `operator-oauth`
Secret on `clientId`, not on `clientSecret`, so without it no Secret renders and the Pod
hangs mounting one that does not exist.

Under workload identity federation `clientId` and `audience` are **not secrets**. They are
only valid paired with a token the cluster's own OIDC issuer signs.

## Values that are tailnet-global

These collide across clusters, so each cluster's own values file must supply them:

| | |
|---|---|
| `operatorConfig.hostname` | **Write-once.** Changing it re-registers the device on a new `100.x` address and any DNS pointing at it breaks. The upstream default `tailscale-operator` collides the moment a second cluster joins, so this chart refuses to render with it. |
| `proxyConfig.defaultTags` | Tags **Services**, which is what access rules match. Must stay in step with what `tfy-tailscale-config` derives — the two live in different releases and nothing checks them against each other. |

## Device tags vs service tags

`operatorConfig.defaultTags` is a **list** and tags the operator *device*.
`proxyConfig.defaultTags` is a **comma-separated string** and tags *Services*. Access rules
match the Service. Passing a list to `proxyConfig` renders `[tag:a tag:b]` into
`PROXY_TAGS`, which is not a valid env var value, so this chart fails on it at render time.
Getting this pair backwards reports healthy and is unreachable.

Every tag named here must exist in the tailnet policy file's `tagOwners` before a device
claims it, and Service tags need an `autoApprovers.services` entry — without either, the
proxy stalls at `0/N proxy backends ready` with nothing logged.

## Parameters

### Namespace

| Name                    | Description                                          | Value  |
| ----------------------- | ---------------------------------------------------- | ------ |
| `namespace.create`      | Create the operator namespace with the labels below. | `true` |
| `namespace.labels`      | Labels applied to the namespace.                     | `{}`   |
| `namespace.annotations` | Annotations applied to the namespace.                | `{}`   |

### Upstream operator

| Name                                                         | Description                                                                                                                          | Value         |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `tailscale-operator.enabled`                                 | Install the upstream operator chart.                                                                                                 | `true`        |
| `tailscale-operator.installCRDs`                             | Install the tailscale.com CRDs. Leave true unless something else already owns them (multi-tailnet, vcluster).                        | `true`        |
| `tailscale-operator.oauth.clientId`                          | OAuth client ID. Not a secret under workload identity federation.                                                                    | `""`          |
| `tailscale-operator.oauth.audience`                          | WIF audience. Mutually exclusive with clientSecret; requires clientId.                                                               | `""`          |
| `tailscale-operator.oauth.clientSecret`                      | Static OAuth client secret. Do not commit. Prefer audience.                                                                          | `""`          |
| `tailscale-operator.operatorConfig.defaultTags`              | ACL tag the operator itself carries. Tailnet-wide, not per-cluster: wired into the Terraform OAuth client, and owns every other tag. | `[]`          |
| `tailscale-operator.operatorConfig.logging`                  | Operator log level.                                                                                                                  | `info`        |
| `tailscale-operator.operatorConfig.resources`                | Operator resource requests and limits.                                                                                               | `{}`          |
| `tailscale-operator.proxyConfig.defaultProxyClass`           | ProxyClass applied to proxies that do not name one. Matches the ProxyClass shipped by tfy-tailscale-config.                          | `tfy-default` |
| `tailscale-operator.apiServerProxyConfig.allowImpersonation` | Create the ClusterRole permissions the auth-mode API server proxy needs. Required by a kube-apiserver ProxyGroup in auth mode.       | `true`        |
| `tailscale-operator.apiServerProxyConfig.mode`               | Run an in-process API server proxy. Left "false" -- a kube-apiserver ProxyGroup provides an HA one instead.                          | `false`       |
| `tailscale-operator.ingressClass.enabled`                    | Create the "tailscale" IngressClass.                                                                                                 | `true`        |
