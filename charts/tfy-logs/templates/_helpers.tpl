{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-logs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tfy-logs.fullname" -}}
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
{{- define "tfy-logs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
labels for vector
*/}}
{{- define "tfy-logs.labels" -}}
helm.sh/chart: {{ include "tfy-logs.chart" . }}
{{ include "tfy-logs.selectorLabels" . }}
app.kubernetes.io/component: vector
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
annotations for vector
*/}}
{{- define "tfy-logs.annotations" -}}
{{- with .Values.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tfy-logs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-logs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
Labels for resource quotas
*/}}
{{- define "resource-quotas.labels" -}}
helm.sh/chart: {{ include "tfy-logs.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.resourceQuota.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations for resource quotas
*/}}
{{- define "resource-quotas.annotations" -}}
{{- with .Values.resourceQuota.annotations }}
  {{ toYaml . }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Image pull secrets for Windows Vector with fallback to global
*/}}
{{- define "tfy-logs.windowsVector.imagePullSecrets" -}}
{{- if .Values.windowsVector.imagePullSecrets }}
{{- toYaml .Values.windowsVector.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets }}
{{- toYaml .Values.global.imagePullSecrets }}
{{- end }}
{{- end }} 