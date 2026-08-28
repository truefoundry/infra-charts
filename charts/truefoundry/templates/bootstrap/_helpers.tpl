{{/*
  bootstrap annotation
*/}}
{{- define "bootstrap.commonAnnotations" -}}
{{- /*
The order of mergeOverwrite is important.
The bootstrap annotations are getting more priority than the globalAnnotations.
*/}}
{{ $syncWaveAnnotation := dict }} 
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/sync-wave" "-5" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook" "pre-install,pre-upgrade" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook-weight" "-5" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook-delete-policy" "before-hook-creation" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/hook" "PreSync" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/hook-delete-policy" "BeforeHookCreation" }}
{{ $baseAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) (deepCopy .Values.truefoundryBootstrap.commonAnnotations) }}
{{ $mergedAnnotations := mergeOverwrite $baseAnnotations $syncWaveAnnotation }}
{{ toYaml $mergedAnnotations }}
{{- end -}}

{{/*
  bootstrap labels
*/}}
{{- define "bootstrap.commonLabels" -}}
{{- $standardLabels := include "truefoundry.labels" (dict "context" . "name" "truefoundry-bootstrap") | fromYaml }}
{{- $baseLabels := mergeOverwrite $standardLabels (deepCopy .Values.global.labels) .Values.truefoundryBootstrap.commonLabels }}
{{ toYaml $baseLabels  }}
{{- end -}}

{{/*
  bootstrap resources
*/}}
{{- define "bootstrap.resources" -}}
{{- $resources := .Values.truefoundryBootstrap.resources -}}
{{- if $resources }}
{{- toYaml $resources }}
{{- else }}
limits:
  cpu: 500m
  memory: 512Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end -}}
{{- end -}}

{{/*
  image pull secrets
*/}}
{{- define "bootstrap.imagePullSecrets" -}}
{{- if .Values.truefoundryBootstrap.imagePullSecrets -}}
{{- toYaml .Values.truefoundryBootstrap.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}

{{/*
  pod labels
*/}}
{{ define "bootstrap.podlabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "truefoundry-bootstrap") | fromYaml }}
{{- $podLabels := mergeOverwrite  (deepCopy .Values.global.podLabels) .Values.truefoundryBootstrap.podLabels $selectorLabels  }}
{{- toYaml $podLabels }}
{{- end -}}

{{/*
  pod annotations
*/}}
{{ define "bootstrap.podAnnotations" -}}
{{- $baseAnnotations := include "bootstrap.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $baseAnnotations .Values.truefoundryBootstrap.podAnnotations  }}
{{- toYaml $podAnnotations }}
{{- end -}}

{{/*
  job annotations
*/}}
{{- define "bootstrap.jobAnnotations" -}}
{{ $syncWaveAnnotation:= dict }} 
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/sync-wave" "-1" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook" "pre-install,pre-upgrade" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook-weight" "-1" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "helm.sh/hook-delete-policy" "before-hook-creation" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/hook" "PreSync" }}
{{ $syncWaveAnnotation = set $syncWaveAnnotation "argocd.argoproj.io/hook-delete-policy" "BeforeHookCreation" }}
{{- $bootstrapAnnotations := include "bootstrap.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite $bootstrapAnnotations $syncWaveAnnotation }}
{{- toYaml $mergedAnnotations }}
{{- end -}}

{{/*
  serviceaccount annotations
*/}}
{{- define "bootstrap.serviceAccountAnnotations" -}}
{{- $bootstrapAnnotations := include "bootstrap.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite $bootstrapAnnotations .Values.truefoundryBootstrap.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end -}}

{{/*
  serviceaccount labels
*/}}
{{- define "bootstrap.serviceAccountLabels" -}}
{{- $bootstrapLabels := include "bootstrap.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite $bootstrapLabels .Values.truefoundryBootstrap.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end -}}

{{/*
  mTLS leaf SAN DNS names.
  - Namespace wildcards (*.<ns>.svc, *.<ns>.svc.cluster.local) cover the FQDN forms of every
    service in the release namespace (a cert wildcard matches the single <svc> label).
  - Each service also gets its bare name (<release>-<component>) and <name>.<ns> form, for
    clients that connect by the short names. Every component's fullname helper is called
    unconditionally; a SAN for a service that isn't deployed is harmless, which lets us skip
    per-service enable guards.
  - localhost is included so in-pod HTTPS probes / local loops (e.g. servicefoundry-server)
    can verify the leaf when dialing 127.0.0.1/localhost.
  - global.mTLS.extraDnsNames are appended.
*/}}
{{- define "bootstrap.mtlsDnsNames" -}}
{{- $ns := include "global.namespace" . | trim -}}
{{- $names := list "localhost" (printf "*.%s.svc" $ns) (printf "*.%s.svc.cluster.local" $ns) -}}
{{- /* Component Service names: fullname helpers + the two non-.svc special cases. */}}
{{- $svcs := list -}}
{{- $fullnameHelpers := list
  "deltafusion-ingestor.fullname"
  "deltafusion-query-server.fullname"
  "mlfoundry-server.fullname"
  "s3proxy.fullname"
  "servicefoundry-server.fullname"
  "sfy-manifest-service.fullname"
  "spark-history-server.fullname"
  "stdio-mcp-proxy.fullname"
  "tfy-buildkitd-service.fullname"
  "tfy-infra-manager.fullname"
  "tfy-k8s-controller.fullname"
  "tfy-proxy.fullname" -}}
{{- range $h := $fullnameHelpers -}}
{{- $svcs = append $svcs (include $h $) -}}
{{- end -}}
{{- /* tfy-workflow-admin's Service is <fullname>-server. */}}
{{- $svcs = append $svcs (printf "%s-server" (include "tfy-workflow-admin.fullname" .)) -}}
{{- /* Subcharts: Service name is <release>-<subchart>. */}}
{{- $svcs = append $svcs (printf "%s-tfy-llm-gateway" .Release.Name) -}}
{{- $svcs = append $svcs (printf "%s-tfy-otel-collector" .Release.Name) -}}
{{- $svcs = append $svcs (printf "%s-tfy-sandbox-server" .Release.Name) -}}
{{- $svcs = append $svcs (printf "%s-tfy-nats" .Release.Name) -}}
{{- /* Each service -> bare name and <name>.<ns>. */}}
{{- range $svc := $svcs -}}
{{- $names = append $names $svc -}}
{{- $names = append $names (printf "%s.%s" $svc $ns) -}}
{{- end -}}
{{- range $d := .Values.global.mTLS.extraDnsNames -}}
{{- $names = append $names $d -}}
{{- end -}}
{{- range $n := $names }}
- {{ $n | quote }}
{{- end }}
{{- end -}}

{{/*
  serviceaccount name
*/}}
{{- define "bootstrap.serviceAccountName" -}}
{{- if .Values.truefoundryBootstrap.serviceAccount.name }}
{{- .Values.truefoundryBootstrap.serviceAccount.name }}
{{- else }}
{{- "truefoundry-bootstrap-job-sa" }}
{{- end }}
{{- end -}}