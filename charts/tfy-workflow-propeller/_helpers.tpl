{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-workflow-propeller.name" -}}
{{- default "tfy-workflow-propeller" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-workflow-propeller.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-workflow-propeller" .Values.nameOverride }}
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
{{- define "tfy-workflow-propeller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-workflow-propeller.labels" -}}
helm.sh/chart: {{ include "tfy-workflow-propeller.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-workflow-propeller.selectorLabels" . }}
{{- if .Values.imageTag }}
app.kubernetes.io/version: {{ .Values.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-workflow-propeller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-workflow-propeller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-workflow-propeller.serviceAccountName" -}}
{{- default (include "tfy-workflow-propeller.fullname" .) "tfy-workflow-propeller"}}

{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-workflow-propeller.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-workflow-propeller.env" }}
{{- range $key, $val := (include "tfy-workflow-propeller.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.envSecretName }}
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
