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

{{/*
  Merge nodeSelector
  */}}
{{- define "sfy-manifest-service.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge $defaultNodeSelector .Values.sfyManifestService.nodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
