{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eks-node-monitoring-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eks-node-monitoring-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eks-node-monitoring-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common selector labels
*/}}
{{- define "eks-node-monitoring-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eks-node-monitoring-agent.name" . }}
helm.sh/chart: {{ include "eks-node-monitoring-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "eks-node-monitoring-agent.labels" -}}
{{ include "eks-node-monitoring-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: controller
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eks-node-monitoring-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "eks-node-monitoring-agent.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get the image for the dcgm-server DaemonSet.
Empty repository uses the eks-node-monitoring-agent image.
*/}}
{{- define "dcgm-server.image" -}}
{{- if .Values.dcgmAgent.image.repository -}}
{{- $registry := .Values.dcgmAgent.image.registry | default .Values.nodeAgent.image.registry -}}
{{- $tag := .Values.dcgmAgent.image.tag | default .Values.nodeAgent.image.tag -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.dcgmAgent.image.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.dcgmAgent.image.repository $tag -}}
{{- end -}}
{{- else -}}
{{- include "eks-node-monitoring-agent.image" . -}}
{{- end -}}
{{- end -}}

{{/*
Get the eks-node-monitoring-agent image.
*/}}
{{- define "eks-node-monitoring-agent.image" -}}
{{- $repo := required "nodeAgent.image.repository is required" .Values.nodeAgent.image.repository -}}
{{- $tag := required "nodeAgent.image.tag is required" .Values.nodeAgent.image.tag -}}
{{- if .Values.nodeAgent.image.registry -}}
{{- printf "%s/%s:%s" .Values.nodeAgent.image.registry $repo $tag -}}
{{- else -}}
{{- printf "%s:%s" $repo $tag -}}
{{- end -}}
{{- end -}}
