{{/*
Expand the name of the chart.
*/}}
{{- define "mlfoundry-server.name" -}}
{{- default "mlfoundry-server" .Values.mlfoundryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "mlfoundry-server.fullname" -}}
{{- if .Values.mlfoundryServer.fullnameOverride }}
{{- .Values.mlfoundryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "mlfoundry-server" .Values.mlfoundryServer.nameOverride }}
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
{{- define "mlfoundry-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "mlfoundry-server.podLabels" -}}
{{ include "mlfoundry-server.selectorLabels" . }}
{{- if .Values.mlfoundryServer.image.tag }}
app.kubernetes.io/version: {{ .Values.mlfoundryServer.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.mlfoundryServer.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "mlfoundry-server.labels" -}}
{{- include "mlfoundry-server.podLabels" . }}
helm.sh/chart: {{ include "mlfoundry-server.chart" . }}
{{- if .Values.mlfoundryServer.commonLabels }}
{{ toYaml .Values.mlfoundryServer.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "mlfoundry-server.annotations" -}}
{{- if .Values.mlfoundryServer.annotations }}
{{ toYaml .Values.mlfoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "mlfoundry-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mlfoundry-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "mlfoundry-server.serviceAccountName" -}}
{{- default (include "mlfoundry-server.fullname" .) "mlfoundry-server" }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "mlfoundry-server.serviceAccountAnnotations" -}}
{{- if .Values.mlfoundryServer.serviceAccount.annotations }}
{{ toYaml .Values.mlfoundryServer.serviceAccount.annotations }}
{{- else if .Values.mlfoundryServer.annotations }}
{{ toYaml .Values.mlfoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "mlfoundry-server.parseEnv" -}}
{{ tpl (.Values.mlfoundryServer.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "mlfoundry-server.env" }}
{{- range $key, $val := (include "mlfoundry-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.mlfoundryServer.envSecretName }}
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
