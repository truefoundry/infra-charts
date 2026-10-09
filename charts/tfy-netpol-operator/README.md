# tfy-netpol-operator

Annotation-driven Kubernetes NetworkPolicy operator for the TrueFoundry ecosystem.

The operator source (and the image this chart deploys) lives in
[truefoundry/network-policy-operator](https://github.com/truefoundry/network-policy-operator).
This chart is released from `infra-charts` like every other chart here.

## What it does

For every namespace carrying the single annotation
`truefoundry.com/allowed-ingress-namespaces`, the operator reconciles three standard
`networking.k8s.io/v1` NetworkPolicies, applied in this order:

1. `tfy-np-allow-egress` — allow-all egress (egress stays open).
2. `tfy-np-allow-ingress` — allow ingress from the same namespace, the configured
   baseline namespaces, and the namespaces listed in the annotation.
3. `tfy-np-default-deny-ingress` — default-deny ingress backstop (applied last,
   after the allow rules are in place; can be disabled via `config.defaultDenyIngress`).

Annotation semantics:

| Annotation state | Result |
|------------------|--------|
| Absent | Namespace not managed; any managed policies are removed. |
| Present, empty (`""`) | Default-deny ingress + allow-all egress + allow `self` + baselines. |
| Present, with list (`"argocd,prometheus"`) | The above **plus** allow ingress from each listed namespace. |
| Present, with prefix wildcard (`"ihg-*"`) | The above **plus** allow ingress from every namespace whose name starts with `ihg-`. New matching namespaces are picked up immediately on creation; deletions are cleaned up on the next resync. Only a single trailing `*` is supported, and it can be mixed with plain names (`"argocd,ihg-*"`). |

Key safety properties: **allow-before-deny** ordering (the allow rules are applied
before the default-deny backstop so a namespace is never left deny-only
mid-reconcile), **baseline allows** so an empty annotation cannot black-hole a
namespace, **system-namespace exclusion**, and **dry-run** mode for first rollout.

> **Prerequisite:** the cluster's CNI must actually enforce NetworkPolicies, or the
> operator's policies are accepted by the API server but ignored. On EKS with the AWS
> VPC CNI, enable it on the addon (`enableNetworkPolicy: "true"`) and verify with
> `kubectl get policyendpoints -A`.

## Install

From the TrueFoundry Helm repository:

```bash
helm repo add truefoundry https://truefoundry.github.io/infra-charts
helm repo update

helm upgrade --install tfy-netpol-operator truefoundry/tfy-netpol-operator \
  -n tfy-system --create-namespace \
  --set 'config.baselineAllowedNamespaces={istio-system,prometheus,tfy-agent}' \
  --set config.dryRun=true
```

Or from the OCI registry:

```bash
helm upgrade --install tfy-netpol-operator oci://tfy.jfrog.io/tfy-helm/tfy-netpol-operator \
  --version <chart-version> \
  -n tfy-system --create-namespace \
  --set 'config.baselineAllowedNamespaces={istio-system,prometheus,tfy-agent}' \
  --set config.dryRun=true
```

Roll out with `config.dryRun=true` first, review the logged intended policies, then set
`config.dryRun=false` to enforce.

Keep `replicaCount` at 1: the operator runs with `--standalone` (no Kopf peering).

## Enroll a namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-addon
  annotations:
    truefoundry.com/allowed-ingress-namespaces: "argocd,prometheus"
```

Prefix wildcards are supported, alone or mixed with plain names:

```yaml
    truefoundry.com/allowed-ingress-namespaces: "argocd,ihg-*"
```

## Disable / uninstall

Per namespace, remove the annotation and the operator deletes its policies there:

```bash
kubectl annotate ns <namespace> truefoundry.com/allowed-ingress-namespaces-
```

To remove everything, uninstall the release. A post-delete hook Job deletes every
operator-managed NetworkPolicy across all namespaces (disable with
`--set cleanupOnUninstall=false` to keep the policies):

```bash
helm uninstall tfy-netpol-operator -n tfy-system
```

For manual cleanup, scale the operator to zero **first** (it recreates its policies
on drift while running), then delete by label:

```bash
kubectl -n tfy-system scale deploy tfy-netpol-operator --replicas=0
kubectl delete netpol -A -l app.kubernetes.io/managed-by=tfy-netpol-operator
```

If policies created by an operator **older than 0.6.0** hang in `Terminating`
here, they carry a Kopf finalizer only the (now stopped) operator could remove;
strip it to let the deletion finish:

```bash
kubectl get netpol -A -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' | \
  while read ns name; do kubectl patch netpol "$name" -n "$ns" --type=merge -p '{"metadata":{"finalizers":null}}'; done
```

Note that `config.dryRun: true` only stops new writes — it does not remove policies
that were already applied.

## Argo CD coexistence

Generated policies carry `app.kubernetes.io/managed-by: tfy-netpol-operator` and are not
in any Argo CD Application's Git source. Exclude them from Argo pruning (resource
exclusion or `ignoreDifferences`) so Argo does not delete operator-owned policies.

## Parameters

### Image configuration

| Name               | Description               | Value                                         |
| ------------------ | ------------------------- | --------------------------------------------- |
| `image.repository` | Operator image repository | `tfy.jfrog.io/tfy-images/tfy-netpol-operator` |
| `image.tag`        | Operator image tag        | `0.6.0`                                       |
| `image.pullPolicy` | Image pull policy         | `IfNotPresent`                                |
| `imagePullSecrets` | Image pull secrets        | `[]`                                          |

### Deployment configuration

| Name                         | Description                                                                                                                                                                                                                                                         | Value  |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `nameOverride`               | Override the chart name used in resource names and labels                                                                                                                                                                                                           | `""`   |
| `fullnameOverride`           | Override the fully qualified resource name                                                                                                                                                                                                                          | `""`   |
| `replicaCount`               | Number of operator replicas. Keep at 1: the operator runs with `--standalone` (no Kopf peering). For HA, enable peering in the image entrypoint and raise this.                                                                                                     | `1`    |
| `serviceAccount.create`      | Create a dedicated ServiceAccount for the operator                                                                                                                                                                                                                  | `true` |
| `serviceAccount.name`        | ServiceAccount name (defaults to the release fullname when `create` is true, otherwise `default`)                                                                                                                                                                   | `""`   |
| `serviceAccount.annotations` | Annotations for the ServiceAccount                                                                                                                                                                                                                                  | `{}`   |
| `podAnnotations`             | Annotations for the operator pod                                                                                                                                                                                                                                    | `{}`   |
| `podSecurityContext`         | Pod security context                                                                                                                                                                                                                                                | `{}`   |
| `securityContext`            | Container security context                                                                                                                                                                                                                                          | `{}`   |
| `resources`                  | Container resources                                                                                                                                                                                                                                                 | `{}`   |
| `nodeSelector`               | Node selector                                                                                                                                                                                                                                                       | `{}`   |
| `tolerations`                | Tolerations                                                                                                                                                                                                                                                         | `[]`   |
| `affinity`                   | Affinity                                                                                                                                                                                                                                                            | `{}`   |
| `cleanupOnUninstall`         | On `helm uninstall`, run a post-delete hook Job that deletes every NetworkPolicy the operator created (label `app.kubernetes.io/managed-by=tfy-netpol-operator`) across all namespaces. Set to false to keep the policies in place after uninstalling the operator. | `true` |

### Operator behavior (rendered into the ConfigMap)

| Name                               | Description                                                                                                                                                                                                       | Value   |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `config.dryRun`                    | Start in report-only mode. Set to false to enforce.                                                                                                                                                               | `true`  |
| `config.allowWildcard`             | Allow the `*` wildcard (allow-all-namespaces) in the namespace annotation                                                                                                                                         | `false` |
| `config.defaultDenyIngress`        | Create the explicit default-deny-ingress backstop policy in managed namespaces. Disable only if you intend to rely on the allow-ingress policy alone for isolation.                                               | `true`  |
| `config.resyncIntervalSeconds`     | Full resync interval in seconds                                                                                                                                                                                   | `300`   |
| `config.baselineAllowedNamespaces` | Always-allowed ingress source namespaces injected into every managed namespace so an empty/incomplete annotation cannot black-hole a namespace. Tune per cluster, e.g. `istio-system`, `prometheus`, `tfy-agent`. | `[]`    |
| `config.denylist`                  | Extra namespaces the operator must never touch (`kube-*` / `openshift-*` are always excluded)                                                                                                                     | `[]`    |
| `config.nodeCIDRs`                 | Optional ipBlock CIDRs injected into the allow-ingress policy (node / hostNetwork edge cases), e.g. `10.0.0.0/16`                                                                                                 | `[]`    |
