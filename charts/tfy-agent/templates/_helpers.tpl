{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tfy-agent.fullname" -}}
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
Create a default fully qualified tfy-agent-proxy name
*/}}
{{- define "tfy-agent-proxy.fullname" -}}
{{- include "tfy-agent.fullname" . | trunc 57 | trimSuffix "-" }}-proxy
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tfy-agent.labels" -}}
helm.sh/chart: {{ include "tfy-agent.chart" . }}
{{ include "tfy-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for tfyAgent
*/}}
{{- define "tfy-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tfy-agent-proxy.labels" -}}
helm.sh/chart: {{ include "tfy-agent.chart" . }}
{{ include "tfy-agent-proxy.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.tfyAgentProxy.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for tfyAgentProxy
*/}}
{{- define "tfy-agent-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-agent-proxy.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tfy-agent.serviceAccountName" -}}
{{- if .Values.tfyAgent.serviceAccount.create }}
{{- default (include "tfy-agent.fullname" .) .Values.tfyAgent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tfyAgent.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret which will contain cluster token
*/}}
{{- define "tfy-agent.secretName" -}}
{{- if .Values.config.clusterTokenSecret }}
{{- .Values.config.clusterTokenSecret }}
{{- else }}
{{- include "tfy-agent.fullname" . | trunc 57 | trimSuffix "-" }}-token
{{- end }}
{{- end }}
