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
{{- toYaml .Values.truefoundryBootstrap.imagePullSecrets | nindent 2 -}}
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
  serviceaccount name
*/}}
{{- define "bootstrap.serviceAccountName" -}}
{{- if .Values.truefoundryBootstrap.serviceAccount.name }}
{{- .Values.truefoundryBootstrap.serviceAccount.name }}
{{- else }}
{{- "truefoundry-bootstrap-job-sa" }}
{{- end }}
{{- end -}}