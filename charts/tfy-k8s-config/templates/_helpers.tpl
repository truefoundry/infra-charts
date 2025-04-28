{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-k8s-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tfy-k8s-config.fullname" -}}
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
{{- define "tfy-k8s-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tfy-k8s-config.labels" -}}
{{- $global := dict }}
{{- $_ := set $global "helm.sh/chart" (include "tfy-k8s-config.chart" .) }}
{{- $_ := set $global "app.kubernetes.io/name" (include "tfy-k8s-config.name" .) }}
{{- $_ := set $global "app.kubernetes.io/instance" .Release.Name }}
{{- if .Chart.AppVersion }}
{{- $_ := set $global "app.kubernetes.io/version" .Chart.AppVersion }}
{{- end }}
{{- $_ := set $global "app.kubernetes.io/managed-by" .Release.Service }}
{{- $merged := merge $global (default dict .Values.priorityClassNodeCritical.labels) }}
{{- toYaml $merged | nindent 0 }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tfy-k8s-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-k8s-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "tfy-k8s-config.annotations" -}}
{{- $global := dict }}
{{- $_ := set $global "app.kubernetes.io/managed-by" .Release.Service }}
{{- $merged := merge $global (default dict .Values.priorityClassNodeCritical.annotations) }}
{{- toYaml $merged | nindent 0 }}
{{- end }}
