{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-otel-collector.name" -}}
{{- default "tfy-otel-collector" .Values.tfyOtelCollector.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-otel-collector.fullname" -}}
{{- if .Values.tfyOtelCollector.fullnameOverride }}
{{- .Values.tfyOtelCollector.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-otel-collector" .Values.tfyOtelCollector.nameOverride }}
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
{{- define "tfy-otel-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "tfy-otel-collector.podLabels" -}}
{{ include "tfy-otel-collector.selectorLabels" . }}
{{- if .Values.tfyOtelCollector.image.tag }}
app.kubernetes.io/version: {{ .Values.tfyOtelCollector.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.tfyOtelCollector.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-otel-collector.labels" -}}
helm.sh/chart: {{ include "tfy-otel-collector.chart" . }}
{{ include "tfy-otel-collector.podLabels" . }}
{{- if .Values.tfyOtelCollector.commonLabels }}
{{ toYaml .Values.tfyOtelCollector.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "tfy-otel-collector.annotations" -}}
{{- if .Values.tfyOtelCollector.annotations }}
{{ toYaml .Values.tfyOtelCollector.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "tfy-otel-collector.serviceAccountAnnotations" -}}
{{- if .Values.tfyOtelCollector.serviceAccount.annotations }}
{{ toYaml .Values.tfyOtelCollector.serviceAccount.annotations }}
{{- else if .Values.tfyOtelCollector.annotations }}
{{ toYaml .Values.tfyOtelCollector.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-otel-collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-otel-collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-otel-collector.serviceAccountName" -}}
{{- default (include "tfy-otel-collector.fullname" .) "tfy-otel-collector" }}

{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "tfy-otel-collector.parseEnv" -}}
{{ tpl (.Values.tfyOtelCollector.env | toYaml) . }}

{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-otel-collector.env" }}
{{- range $key, $val := (include "tfy-otel-collector.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyOtelCollector.envSecretName }}
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

{{- define "tfy-otel-collector.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.tfyOtelCollector.extraVolumes }}
  {{- range .Values.tfyOtelCollector.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "tfy-otel-collector.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.tfyOtelCollector.extraVolumeMounts }}
  {{- range .Values.tfyOtelCollector.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}
