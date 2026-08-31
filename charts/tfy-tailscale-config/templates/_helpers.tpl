{{- define "tfy-tailscale-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-tailscale-config.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "tfy-tailscale-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-tailscale-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-tailscale-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-tailscale-config.labels" -}}
helm.sh/chart: {{ include "tfy-tailscale-config.chart" . }}
{{ include "tfy-tailscale-config.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
{{- end -}}

{{/*
The cluster slug: clusterName with a leading "tfy-" removed IF PRESENT.

The prefix is not universal across the fleet -- az-prod-eaus and labs-training carry no
"tfy-" -- so the strip is conditional and its absence is not an error. Nothing else is
ever derived from the cluster name: role, region and environment appear in different
orders across the fleet, so the name is treated as an opaque slug.

Validated here because every tailnet-global name and tag in this chart is built from it.
An empty or malformed slug renders names and tags that pass their own checks -- the tag
pattern permits a trailing dash -- and then stall the device at "0/N proxy backends ready"
with nothing logged.
*/}}
{{- define "tfy-tailscale-config.clusterSlug" -}}
{{- $slug := "" -}}
{{- if .Values.clusterSlug -}}
{{- $slug = .Values.clusterSlug | lower -}}
{{- else -}}
{{- $slug = trimPrefix "tfy-" (.Values.clusterName | lower) -}}
{{- end -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?$" $slug) -}}
{{- fail (printf "tfy-tailscale-config: cluster slug %q must match ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ -- it is the stem of every tailnet-global name and ACL tag here. Set clusterName, or clusterSlug to override it." $slug) -}}
{{- end -}}
{{- $slug -}}
{{- end -}}

{{/*
A per-role DEVICE tag. Tags what the proxy devices are, via ProxyGroup.spec.tags --
NOT what access rules match. Call as:
  include "tfy-tailscale-config.roleTag" (dict "root" $ "role" "ingress")

Fails on a tag that the ProxyGroup CRD would reject. The CRD pattern is
^tag:[a-zA-Z][a-zA-Z0-9-]*$ -- no underscores or dots -- and EKS and AKS both permit
underscores in cluster names, so this is reachable with a real cluster name. Without the
guard the value renders green in CI (which does no schema validation) and fails later at
apply time on a cluster nobody is watching.
*/}}
{{- define "tfy-tailscale-config.roleTag" -}}
{{- $root := .root -}}
{{- $role := .role -}}
{{- $override := index $root.Values.tailnet.roleTags $role | default "" -}}
{{- $tag := "" -}}
{{- if $override -}}
{{- $tag = $override -}}
{{- else -}}
{{- $tag = printf "tag:k8s-%s-%s" $role (include "tfy-tailscale-config.clusterSlug" $root) -}}
{{- end -}}
{{- if not (regexMatch "^tag:[a-zA-Z][a-zA-Z0-9-]*$" $tag) -}}
{{- fail (printf "tfy-tailscale-config: derived tag %q is not a valid Tailscale tag (must match ^tag:[a-zA-Z][a-zA-Z0-9-]*$ -- no underscores or dots). Set tailnet.roleTags.%s explicitly." $tag $role) -}}
{{- end -}}
{{- $tag -}}
{{- end -}}

{{/*
The coarse tags for a role -- env, cloud and plane, from the same registry columns that
build the slug. Access rules target these, so "everything in dev" is one rule rather than
seventeen; the per-cluster roleTag above stays for the case that needs to isolate one
cluster.

Returns a COMMA-SEPARATED string, possibly empty, because a Helm template cannot return a
list. Callers splitList it and skip empty elements.

Call as:
  include "tfy-tailscale-config.coarseTags" (dict "root" $ "role" "ingress")
*/}}
{{- define "tfy-tailscale-config.coarseTags" -}}
{{- $root := .root -}}
{{- $role := .role -}}
{{- $tags := list -}}
{{- range $dimension := (list "env" "cloud" "plane") -}}
{{- $value := index $root.Values.tailnet.coarse $dimension | default "" | lower -}}
{{- if $value -}}
{{- $tag := printf "tag:k8s-%s-%s-%s" $role $dimension $value -}}
{{- if not (regexMatch "^tag:[a-zA-Z][a-zA-Z0-9-]*$" $tag) -}}
{{- fail (printf "tfy-tailscale-config: derived coarse tag %q is not a valid Tailscale tag (must match ^tag:[a-zA-Z][a-zA-Z0-9-]*$ -- no underscores or dots). Fix tailnet.coarse.%s." $tag $dimension) -}}
{{- end -}}
{{- $tags = append $tags $tag -}}
{{- end -}}
{{- end -}}
{{- join "," $tags -}}
{{- end -}}

{{/*
Every DEVICE tag for a role, as a YAML list ready to nindent under `tags:`.

Recorders take base=false: a Recorder carries only its own role tags today, never the
shared tag:k8s, and adding it would change the identity of a device that cannot be
retagged without re-provisioning.

Call as:
  include "tfy-tailscale-config.deviceTags" (dict "root" $ "role" "ingress" "base" true)
*/}}
{{- define "tfy-tailscale-config.deviceTags" -}}
{{- $root := .root -}}
{{- $tags := list -}}
{{- if .base -}}
{{- $tags = append $tags $root.Values.tailnet.baseTag -}}
{{- end -}}
{{- $tags = append $tags (include "tfy-tailscale-config.roleTag" (dict "root" $root "role" .role)) -}}
{{- range (include "tfy-tailscale-config.coarseTags" (dict "root" $root "role" .role) | splitList ",") -}}
{{- if . -}}
{{- $tags = append $tags . -}}
{{- end -}}
{{- end -}}
{{- $lines := list -}}
{{- range $tags -}}
{{- $lines = append $lines (printf "- %s" (quote .)) -}}
{{- end -}}
{{- join "\n" $lines -}}
{{- end -}}

{{/*
The SERVICE tags for ingress-fronted Services. Access rules match THESE, not the device
tags on the ProxyGroup.

Rendered as a COMMA-SEPARATED STRING, which is the form both proxyConfig.defaultTags and
the tailscale.com/tags annotation take -- unlike ProxyGroup.spec.tags, which is a YAML
list. The two are not interchangeable.

The base tag rides alongside the role tag because the Services carry it and the admin UIs
are reached through it. Dropping it here silently removes tag:k8s from every one of them.
*/}}
{{- define "tfy-tailscale-config.ingressServiceTags" -}}
{{- if .Values.serviceTags.ingress -}}
{{- .Values.serviceTags.ingress -}}
{{- else -}}
{{- $role := include "tfy-tailscale-config.roleTag" (dict "root" . "role" "ingress") -}}
{{- $coarse := include "tfy-tailscale-config.coarseTags" (dict "root" . "role" "ingress") -}}
{{- $tags := list .Values.tailnet.baseTag $role -}}
{{- range (splitList "," $coarse) -}}
{{- if . -}}
{{- $tags = append $tags . -}}
{{- end -}}
{{- end -}}
{{- join "," $tags -}}
{{- end -}}
{{- end -}}

{{/*
Tailnet-global names, every one WRITE-ONCE: changing one re-registers the device on a new
100.x address and orphans any DNS record pointing at it.

Length and charset are enforced per name, against patterns that differ by field:
  hostnamePrefix          ^[a-z0-9][a-z0-9-]{0,61}$            -> max 62
  kubeAPIServer.hostname  ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ -> max 63, no trailing dash
  Recorder name           device is "<name>-0"                 -> max 61, RFC 1123
  gateway Service hostname                                     -> max 63, RFC 1123
*/}}
{{- define "tfy-tailscale-config.ingressHostnamePrefix" -}}
{{- $v := .Values.proxyGroups.ingress.hostnamePrefix | default (printf "%s-ing" (include "tfy-tailscale-config.clusterSlug" .)) -}}
{{- $v = $v | lower | trunc 62 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9][a-z0-9-]*$" $v) -}}
{{- fail (printf "tfy-tailscale-config: hostnamePrefix %q must match ^[a-z0-9][a-z0-9-]{0,61}$. Set proxyGroups.ingress.hostnamePrefix explicitly." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{/*
The egress ProxyGroup's DEVICE hostname prefix. Unlike the apiserver equivalent below this
DOES default, and clusters run on that default -- so it is write-once like any other name
here, not a free choice.
*/}}
{{- define "tfy-tailscale-config.egressHostnamePrefix" -}}
{{- $v := .Values.proxyGroups.egress.hostnamePrefix | default (printf "%s-egress" (include "tfy-tailscale-config.clusterSlug" .)) -}}
{{- $v = $v | lower | trunc 62 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9][a-z0-9-]*$" $v) -}}
{{- fail (printf "tfy-tailscale-config: egress hostnamePrefix %q must match ^[a-z0-9][a-z0-9-]{0,61}$. Set proxyGroups.egress.hostnamePrefix explicitly." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{- define "tfy-tailscale-config.apiserverHostname" -}}
{{- $v := .Values.proxyGroups.apiserver.hostname | default (printf "%s-k8s" (include "tfy-tailscale-config.clusterSlug" .)) -}}
{{- $v = $v | lower | trunc 63 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?$" $v) -}}
{{- fail (printf "tfy-tailscale-config: kubeAPIServer hostname %q must match ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$. Set proxyGroups.apiserver.hostname explicitly." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{/*
The apiserver ProxyGroup's DEVICE hostname prefix -- distinct from apiserverHostname
above, which names the Tailscale Service that kubectl talks to.

DELIBERATELY HAS NO DEFAULT. Every other name here defaults from the slug, but this one
is unset on existing clusters, where the operator falls back to the Kubernetes object
name ("k8s-apiserver-0" / "-1"). Defaulting it would mean a chart upgrade silently
re-registers those devices on new 100.x addresses -- the exact failure this chart's
write-once warnings exist to prevent. Opt in per cluster instead.
*/}}
{{- define "tfy-tailscale-config.apiserverHostnamePrefix" -}}
{{- $v := .Values.proxyGroups.apiserver.hostnamePrefix | lower | trunc 62 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9][a-z0-9-]*$" $v) -}}
{{- fail (printf "tfy-tailscale-config: apiserver hostnamePrefix %q must match ^[a-z0-9][a-z0-9-]{0,61}$." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{- define "tfy-tailscale-config.recorderName" -}}
{{- $v := .Values.recorder.name | default (printf "%s-recorder" (include "tfy-tailscale-config.clusterSlug" .)) -}}
{{- $v = $v | lower | trunc 61 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?$" $v) -}}
{{- fail (printf "tfy-tailscale-config: recorder name %q must be a valid RFC 1123 name (^[a-z0-9]([a-z0-9-]{0,59}[a-z0-9])?$ -- no underscores or dots). Set recorder.name explicitly." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{- define "tfy-tailscale-config.gatewayServiceHostname" -}}
{{- $v := .Values.istioGateway.service.hostname | default (printf "%s-gw" (include "tfy-tailscale-config.clusterSlug" .)) -}}
{{- $v = $v | lower | trunc 63 | trimSuffix "-" -}}
{{- if not (regexMatch "^[a-z0-9]([a-z0-9-]*[a-z0-9])?$" $v) -}}
{{- fail (printf "tfy-tailscale-config: gateway Service hostname %q must match ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$. Set istioGateway.service.hostname explicitly." $v) -}}
{{- end -}}
{{- $v -}}
{{- end -}}

{{/*
Require the named fields on one item of an items map. Every items block interpolates
namespace and a backend directly into an object; omitted, they render null or a printf
error rather than failing, and the result is a resource in the wrong namespace or a route
to nowhere that reports healthy.

Call as:
  include "tfy-tailscale-config.requireFields" (dict "block" "mgmt" "key" $key "item" $ui "fields" (list "namespace" "service" "port"))
*/}}
{{- define "tfy-tailscale-config.requireFields" -}}
{{- $block := .block -}}
{{- $key := .key -}}
{{- $item := .item -}}
{{- range $field := .fields -}}
{{- if not (index $item $field) -}}
{{- fail (printf "tfy-tailscale-config: %s.items.%s needs %s." $block $key $field) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the ProxyGroup an items block hangs off, failing when it would default to one this
chart is not creating. The operator silently ignores a tailscale.com/proxy-group annotation
naming a ProxyGroup that does not exist: nothing is advertised and Argo CD still reports
Synced and Healthy.

An explicit value is passed through unchecked -- it names a ProxyGroup owned elsewhere.

`what` names the thing that would break; `key` is the values key that overrides it. They
are separate because the gateway Service has no override of its own and rides
ingresses.proxyGroup, so naming it after itself would send the reader to a key that does
not exist.

Call as:
  include "tfy-tailscale-config.proxyGroupRef" (dict "root" $ "explicit" .Values.egress.proxyGroup "role" "egress" "what" "egress" "key" "egress.proxyGroup")
*/}}
{{- define "tfy-tailscale-config.proxyGroupRef" -}}
{{- if .explicit -}}
{{- .explicit -}}
{{- else -}}
{{- $cfg := index .root.Values.proxyGroups .role -}}
{{- if not $cfg.enabled -}}
{{- fail (printf "tfy-tailscale-config: %s defaults to the %q ProxyGroup, but proxyGroups.%s.enabled is false, so nothing creates it. The operator ignores an annotation naming a ProxyGroup that does not exist and advertises nothing, while Argo CD reports Synced. Enable it, or set %s to one owned elsewhere." .what $cfg.name .role .key) -}}
{{- end -}}
{{- $cfg.name -}}
{{- end -}}
{{- end -}}

{{/*
The host suffix for platform surfaces routed through Istio (Mode H), e.g.
"mgmt.example-ctl.internal.example.com".

ASSERTS THE GATEWAY ACTUALLY SERVES IT. Istio intersects a VirtualService's hosts with the
gateway's server hosts and silently drops the route when the intersection is empty -- Envoy
answers 404 and nothing anywhere reports a misconfiguration. That is the same class of
silent failure as a missing autoApprovers entry, and it is worth failing the render for.

Only checked when this chart owns the gateway. With mgmt.gateway pointed at someone else's
Gateway we cannot see its hosts, so the caller is on their own.
*/}}
{{- define "tfy-tailscale-config.mgmtBaseDomain" -}}
{{- $base := .Values.mgmt.baseDomain | required "tfy-tailscale-config: mgmt.enabled requires mgmt.baseDomain (e.g. mgmt.<slug>.internal.example.com)" -}}
{{- if and (not .Values.istioGateway.enabled) (not .Values.mgmt.gateway) -}}
{{- fail "tfy-tailscale-config: mgmt.enabled with istioGateway.enabled false and no mgmt.gateway. The routes would bind to a Gateway this chart does not create, and Istio drops a route whose Gateway is missing without an error -- Envoy just answers 404. Enable istioGateway, or set mgmt.gateway to an existing one." -}}
{{- end -}}
{{- if and .Values.istioGateway.enabled (not .Values.mgmt.gateway) -}}
{{- $covered := false -}}
{{- range .Values.istioGateway.hosts -}}
{{- if or (eq . (printf "*.%s" $base)) (eq . $base) -}}
{{- $covered = true -}}
{{- end -}}
{{- end -}}
{{- if not $covered -}}
{{- fail (printf "tfy-tailscale-config: mgmt.baseDomain %q is not served by istioGateway.hosts %v. Istio would drop every mgmt route silently -- add \"*.%s\" to istioGateway.hosts (and to certificate.dnsNames)." $base .Values.istioGateway.hosts $base) -}}
{{- end -}}
{{- end -}}
{{- $base -}}
{{- end -}}
