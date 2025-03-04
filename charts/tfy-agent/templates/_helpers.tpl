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
Create a default fully qualified sds-server name
*/}}
{{- define "sds-server.fullname" -}}
{{- include "tfy-agent.fullname" . | trunc 52 | trimSuffix "-" }}-sds-server
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
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.tfyAgent.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations for tfyAgent
*/}}
{{- define "tfy-agent.annotations" -}}
{{- with .Values.tfyAgent.annotations -}}
{{ toYaml . }}
{{- end }}
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
Common labels
*/}}
{{- define "sds-server.labels" -}}
helm.sh/chart: {{ include "tfy-agent.chart" . }}
{{ include "sds-server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.sdsServer.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for sdsServer
*/}}
{{- define "sds-server.selectorLabels" -}}
app.kubernetes.io/name: sds-server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }} 

{{/*
Create the name of the service account to use for tfy-agent
*/}}
{{- define "tfy-agent.serviceAccountName" -}}
{{- if .Values.tfyAgent.serviceAccount.create }}
{{- default (include "tfy-agent.fullname" .) .Values.tfyAgent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tfyAgent.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for tfy-agent-proxy
*/}}
{{- define "tfy-agent-proxy.serviceAccountName" -}}
{{- if .Values.tfyAgentProxy.serviceAccount.create }}
{{- default (include "tfy-agent-proxy.fullname" .) .Values.tfyAgentProxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tfyAgentProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for sds-server
*/}}
{{- define "sds-server.serviceAccountName" -}}
{{- if .Values.sdsServer.serviceAccount.create }}
{{- default (include "sds-server.fullname" .) .Values.sdsServer.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.sdsServer.serviceAccount.name }}
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