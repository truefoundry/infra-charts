{{/*
Upstream credential precedence is oauthSecretVolume > audience > clientSecret: a
lower-ranked key is silently ignored, not merged. Upstream's own values.yaml comment
claims the reverse for the audience/clientSecret pair.

oauth-secret.yaml is gated on `.oauth.clientId`, not `.oauth.clientSecret`, which is why
clientId is required on both non-volume paths.
*/}}
{{- define "tfy-tailscale.validateOauth" -}}
{{- $op := index .Values "tailscale-operator" | default dict -}}
{{- if $op.enabled -}}
{{- $oauth := $op.oauth | default dict -}}
{{- $vol := $op.oauthSecretVolume | default dict -}}
{{- if and $vol (or $oauth.audience $oauth.clientSecret) -}}
{{- fail "tfy-tailscale: oauthSecretVolume is set alongside tailscale-operator.oauth.audience or .clientSecret. The volume outranks both and they are silently ignored, so setting them together means one of them is not doing what you think. Pick one." -}}
{{- end -}}
{{- if and $oauth.audience $oauth.clientSecret -}}
{{- fail "tfy-tailscale: set either tailscale-operator.oauth.audience OR .clientSecret, not both. audience wins and clientSecret is silently ignored, so setting both means one of them is not doing what you think." -}}
{{- end -}}
{{- if and (not $oauth.audience) (not $oauth.clientSecret) (not $vol) -}}
{{- fail "tfy-tailscale: no operator credentials. Set tailscale-operator.oauth.audience (workload identity federation, preferred) or .clientSecret, or oauthSecretVolume. With none of them the operator mounts a Secret that does not exist and the Pod never starts." -}}
{{- end -}}
{{- if and (not $vol) (not $oauth.clientId) -}}
{{- fail "tfy-tailscale: tailscale-operator.oauth.clientId is empty. Both credential paths need it. With clientSecret, upstream gates the operator-oauth Secret on clientId rather than clientSecret, so no Secret renders and the Pod hangs mounting one that does not exist; with audience, CLIENT_ID renders empty and the operator never authenticates." -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "tfy-tailscale.validateHostname" -}}
{{- $op := index .Values "tailscale-operator" | default dict -}}
{{- if $op.enabled -}}
{{- $h := (($op.operatorConfig | default dict).hostname) | default "" -}}
{{- if or (eq $h "") (eq $h "tailscale-operator") -}}
{{- fail (printf "tfy-tailscale: tailscale-operator.operatorConfig.hostname is %q. It is tailnet-global, so every cluster needs a distinct value -- the upstream default collides the moment a second cluster joins. Set it in the cluster's values file." $h) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
No presence check, deliberately: Helm coalesces the subchart's defaults into .Values
before rendering, so an omitted key and one set to upstream's "tag:k8s" both read as
"tag:k8s" here and cannot be told apart.
*/}}
{{- define "tfy-tailscale.validateProxyTags" -}}
{{- $op := index .Values "tailscale-operator" | default dict -}}
{{- if $op.enabled -}}
{{- $tags := (($op.proxyConfig | default dict).defaultTags) -}}
{{- if kindIs "slice" $tags -}}
{{- fail "tfy-tailscale: tailscale-operator.proxyConfig.defaultTags is a list. It tags Services and must be a comma-separated string -- a list renders as [tag:a tag:b] into PROXY_TAGS, which is not valid for an env var value. The list form belongs to operatorConfig.defaultTags, which tags devices." -}}
{{- end -}}
{{- end -}}
{{- end -}}
