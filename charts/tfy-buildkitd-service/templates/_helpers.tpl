{{/*
Expand the name of the chart.
*/}}
{{- define "buildkitd-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "buildkitd-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "buildkitd-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "buildkitd-service.labels" -}}
helm.sh/chart: {{ include "buildkitd-service.chart" . }}
{{ include "buildkitd-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "buildkitd-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "buildkitd-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "buildkitd-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "buildkitd-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Merge nodeSelector
  */}}
{{- define "buildkitd-service.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge .Values.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
