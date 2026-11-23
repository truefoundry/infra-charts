{{/*
  Whether the bootstrap job runs. There is no separate switch: it runs whenever the gateway
  mounts a certificate this chart is responsible for issuing --
    - global.mTLS.enabled: something mounts the certificate;
    - global.mTLS.issuer == "gateway": this chart, not a parent, issues it. The truefoundry
      umbrella chart sets "truefoundry", and its own bootstrap job issues the certificate into
      the same secret; running both would have two jobs fighting over it;
    - no global.mTLS.externalMtlsSecret: nobody supplied one already.
*/}}
{{- define "tfy-llm-gateway.bootstrap.enabled" -}}
{{- $tls := (.Values.global).mTLS | default dict -}}
{{- if and $tls.enabled (eq ($tls.issuer | toString) "gateway") (not $tls.externalMtlsSecret) }}true{{ else }}false{{ end -}}
{{- end -}}

{{/*
  Fail fast on a bootstrap configuration that cannot do what it says. Only checked when the job
  would actually run.
*/}}
{{- define "tfy-llm-gateway.bootstrap.validate" -}}
{{- if eq (include "tfy-llm-gateway.bootstrap.enabled" .) "true" }}
{{- if and (not .Values.bootstrap.serviceAccount.create) (not .Values.bootstrap.serviceAccount.name) }}
{{- fail "bootstrap.serviceAccount.create is false but bootstrap.serviceAccount.name is empty: set it to the service account you created for the job." }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
  Name shared by the bootstrap Job, Secret, ServiceAccount, Role and RoleBinding.
*/}}
{{- define "tfy-llm-gateway.bootstrap.fullname" -}}
{{- printf "%s-bootstrap" (include "tfy-llm-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.serviceAccountName" -}}
{{- .Values.bootstrap.serviceAccount.name | default (include "tfy-llm-gateway.bootstrap.fullname" .) -}}
{{- end -}}

{{/*
  Secret holding the root CA (ca.crt + ca.key). No workload mounts it; only this job reads it,
  so renewals re-sign with the same CA.
*/}}
{{- define "tfy-llm-gateway.bootstrap.caSecretName" -}}
{{- ((.Values.global).mTLS).caSecretName | default "truefoundry-internal-ca" -}}
{{- end -}}

{{/*
  Secret holding the leaf the gateway mounts (ca.crt + tls.crt + tls.key).
  Must match tfy-llm-gateway.mtls.volume.
*/}}
{{- define "tfy-llm-gateway.bootstrap.tlsSecretName" -}}
{{- .Values.global.mTLS.tlsSecretName | default "truefoundry-internal-tls" -}}
{{- end -}}

{{/*
  Hook annotations. The certificate has to exist before the Deployment rolls, so every bootstrap
  object is a pre-install/pre-upgrade hook (PreSync for Argo); the Job runs after its Secret and
  RBAC, hence the heavier weight.
*/}}
{{- define "tfy-llm-gateway.bootstrap.hookAnnotations" -}}
{{- $weight := .weight | default "-5" -}}
argocd.argoproj.io/hook: PreSync
argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
argocd.argoproj.io/sync-wave: {{ $weight | quote }}
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation
helm.sh/hook-weight: {{ $weight | quote }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.commonAnnotations" -}}
{{- $hookAnnotations := include "tfy-llm-gateway.bootstrap.hookAnnotations" (dict "weight" "-5") | fromYaml }}
{{- $baseAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) (deepCopy .Values.bootstrap.commonAnnotations) }}
{{- toYaml (mergeOverwrite $baseAnnotations $hookAnnotations) }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.jobAnnotations" -}}
{{- $hookAnnotations := include "tfy-llm-gateway.bootstrap.hookAnnotations" (dict "weight" "-1") | fromYaml }}
{{- $commonAnnotations := include "tfy-llm-gateway.bootstrap.commonAnnotations" . | fromYaml }}
{{- toYaml (mergeOverwrite $commonAnnotations $hookAnnotations) }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.podAnnotations" -}}
{{- $jobAnnotations := include "tfy-llm-gateway.bootstrap.jobAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $jobAnnotations .Values.bootstrap.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-llm-gateway.bootstrap.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.commonLabels" -}}
{{- $standardLabels := dict
  "helm.sh/chart" (include "tfy-llm-gateway.chart" .)
  "app.kubernetes.io/managed-by" .Release.Service
  "app.kubernetes.io/component" "bootstrap" }}
{{- $standardLabels = mergeOverwrite $standardLabels (include "tfy-llm-gateway.bootstrap.selectorLabels" . | fromYaml) }}
{{- toYaml (mergeOverwrite $standardLabels (deepCopy .Values.global.labels) .Values.bootstrap.commonLabels) }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.podLabels" -}}
{{- $selectorLabels := include "tfy-llm-gateway.bootstrap.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.bootstrap.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.bootstrap.commonLabels" . | fromYaml }}
{{- toYaml (mergeOverwrite $commonLabels .Values.bootstrap.serviceAccount.labels) }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.bootstrap.commonAnnotations" . | fromYaml }}
{{- toYaml (mergeOverwrite $commonAnnotations .Values.bootstrap.serviceAccount.annotations) }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.imagePullSecrets" -}}
{{- if .Values.bootstrap.imagePullSecrets -}}
{{- toYaml .Values.bootstrap.imagePullSecrets }}
{{- else -}}
{{- include "tfy-llm-gateway.imagePullSecrets" . }}
{{- end }}
{{- end -}}

{{- define "tfy-llm-gateway.bootstrap.resources" -}}
{{- if .Values.bootstrap.resources }}
{{- toYaml .Values.bootstrap.resources }}
{{- else }}
limits:
  cpu: 500m
  memory: 512Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end }}
{{- end -}}

{{/*
  mTLS leaf SAN DNS names.
  - Namespace wildcards (*.<ns>.svc, *.<ns>.svc.cluster.local) cover the FQDN form of every
    service in the release namespace (a cert wildcard matches the single <svc> label), so an
    in-namespace peer dialled by its service FQDN is covered without being named here.
  - The gateway Service also gets its bare name and <name>.<ns> form, for clients that connect
    by the short names.
  - localhost is included so in-pod HTTPS probes can verify the leaf when dialing 127.0.0.1.
  - Anything else -- a peer reached by a per-pod name under a headless Service, say -- goes in
    global.mTLS.extraDnsNames, which is appended here.
*/}}
{{- define "tfy-llm-gateway.bootstrap.mtlsDnsNames" -}}
{{- $ns := include "global.namespace" . | trim -}}
{{- $names := list "localhost" (printf "*.%s.svc" $ns) (printf "*.%s.svc.cluster.local" $ns) -}}
{{- $svc := include "tfy-llm-gateway.fullname" . -}}
{{- $names = append $names $svc -}}
{{- $names = append $names (printf "%s.%s" $svc $ns) -}}
{{- range $d := .Values.global.mTLS.extraDnsNames -}}
{{- $names = append $names $d -}}
{{- end -}}
{{- range $n := $names }}
- {{ $n | quote }}
{{- end }}
{{- end -}}
