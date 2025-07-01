{{/*
Expand the name of the chart.
*/}}
{{- define "sfy-manifest-service.name" -}}
{{- default "sfy-manifest-service" .Values.sfyManifestService.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "sfy-manifest-service.fullname" -}}
{{- if .Values.sfyManifestService.fullnameOverride }}
{{- .Values.sfyManifestService.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "sfy-manifest-service" .Values.sfyManifestService.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
  Create chart name and version as used by the chart label.
  */}}
{{- define "sfy-manifest-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "sfy-manifest-service.podLabels" -}}
{{ include "sfy-manifest-service.selectorLabels" . }}
{{- if .Values.sfyManifestService.image.tag }}
app.kubernetes.io/version: {{ .Values.sfyManifestService.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.sfyManifestService.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "sfy-manifest-service.labels" -}}
helm.sh/chart: {{ include "sfy-manifest-service.chart" . }}
{{ include "sfy-manifest-service.podLabels" . }}
{{- if .Values.sfyManifestService.commonLabels }}
{{ toYaml .Values.sfyManifestService.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "sfy-manifest-service.annotations" -}}
{{- if .Values.sfyManifestService.annotations }}
{{ toYaml .Values.sfyManifestService.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "sfy-manifest-service.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "2") (include "sfy-manifest-service.annotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}


{{/*
  Selector labels
  */}}
{{- define "sfy-manifest-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sfy-manifest-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "sfy-manifest-service.serviceAccountName" -}}
{{- default (include "sfy-manifest-service.fullname" .) "sfy-manifest-service"}}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "sfy-manifest-service.serviceAccountAnnotations" -}}
{{- if .Values.sfyManifestService.serviceAccount.annotations }}
{{ toYaml .Values.sfyManifestService.serviceAccount.annotations }}
{{- else if .Values.sfyManifestService.annotations }}
{{ toYaml .Values.sfyManifestService.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "sfy-manifest-service.parseEnv" -}}
{{ tpl (.Values.sfyManifestService.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "sfy-manifest-service.env" }}
{{- range $key, $val := (include "sfy-manifest-service.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.sfyManifestService.envSecretName }}
      key: {{ index (regexSplit "/" $val -1) 1 | trimSuffix "}" }}
{{- else if eq (regexSplit "/" $val -1 | len) 3 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ index (regexSplit "/" $val -1) 1 }}
      key: {{ index (regexSplit "/" $val -1) 2 | trimSuffix "}" }}
{{- else }}
{{- fail "Invalid secret supplied" }}
{{- end }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "sfy-manifest-service.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.sfyManifestService.replicaCount -}}
{{ .Values.sfyManifestService.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{- define "sfy-manifest-service.defaultResources.small"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.defaultResources.medium"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.defaultResources.large"}}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.sfyManifestService.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}