{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "app.fullname" -}}
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
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ }}
{{- end }}
{{ include "app.selectorLabels" . }}
{{- if .Values.imageTag }}
app.kubernetes.io/version: {{ .Values.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "app.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "app.env" }}
{{- range $key, $val := (include "app.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.envSecretName }}
      key: {{ $val | trimPrefix "${k8s-secret/" | trimSuffix "}" }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "app.imagePullSecrets" }}
{{- if (tpl .Values.imagePullCredentials .) }}
- name: {{ include "app.fullname" . }}-image-pull-secret
{{- end }}
{{- if (tpl .Values.imagePullSecretName .) }}
- name: {{ tpl .Values.imagePullSecretName . }}
{{- end }}
{{- end }}