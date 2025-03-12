{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-build.name" -}}
{{- default .Chart.Name .Values.tfyBuild.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-build.fullname" -}}
{{- if .Values.tfyBuild.fullnameOverride }}
{{- .Values.tfyBuild.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-build" .Values.tfyBuild.nameOverride }}
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
{{- define "tfy-build.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-build.serviceAccountName" -}}
{{- default (include "tfy-build.fullname" .) "tfy-build" }}
{{- end }}

{{/*
  Merge default nodeSelector with nodeSelector specified in tfy-build.nodeSelector
*/}}
{{- define "tfy-build.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge .Values.tfyBuild.truefoundryWorkflows.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}

{{/*
  Merge default nodeSelector with nodeSelector specified in tfy-buildkitd.nodeSelector
*/}}
{{- define "tfy-buildkitd.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge .Values.tfyBuild.truefoundryWorkflows.buildkitd.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-build.labels" -}}
helm.sh/chart: {{ include "tfy-build.chart" . }}
{{- if .Values.tfyBuild.labels }}
{{ toYaml .Values.tfyBuild.labels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "tfy-build.annotations" -}}
{{- if .Values.tfyBuild.annotations }}
{{ toYaml .Values.tfyBuild.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "tfy-build.serviceAccountAnnotations" -}}
{{- if .Values.tfyBuild.serviceAccount.annotations }}
{{ toYaml .Values.tfyBuild.serviceAccount.annotations }}
{{- else if .Values.tfyBuild.annotations }}
{{ toYaml .Values.tfyBuild.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}