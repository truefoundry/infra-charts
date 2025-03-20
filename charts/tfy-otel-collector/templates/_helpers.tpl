{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-otel-collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-otel-collector.fullname" -}}
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
{{- define "tfy-otel-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-otel-collector.labels" -}}
helm.sh/chart: {{ include "tfy-otel-collector.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-otel-collector.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Ingress labels
  */}}
{{- define "tfy-otel-collector.ingress.labels" -}}
helm.sh/chart: {{ include "tfy-otel-collector.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-otel-collector.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.ingress.labels }}
{{- toYaml .Values.ingress.labels | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "tfy-otel-collector.annotations" -}}
{{- if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
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
{{- if .Values.serviceAccount.create }}
{{- default (include "tfy-otel-collector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Annotation
*/}}
{{- define "tfy-otel-collector.serviceAccount.annotations" -}}
{{- if .Values.serviceAccount.create }}
  {{- toYaml .Values.serviceAccount.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
  {}
{{- end }}
{{- end }}

{{/*
Virtual Service Annotations
*/}}

{{- define "tfy-otel-collector.virtualservice.annotations" -}}
{{- if .Values.istio.virtualservice.annotations }}
  {{- toYaml .Values.istio.virtualservice.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
  {}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-otel-collector.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
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

{{/*
Ingress Annotations
*/}}
{{- define "tfy-otel-collector.ingress.annotations" -}}
{{- if .Values.ingress.annotations }}
  {{- toYaml .Values.ingress.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Service Annotations
*/}}
{{- define "tfy-otel-collector.service.annotations" -}}
{{- if .Values.service.annotations }}
  {{- toYaml .Values.service.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Pod Annotation Labels
*/}}
{{- define "tfy-otel-collector.podAnnotations" -}}
{{- if .Values.podAnnotations }}
  {{- toYaml .Values.podAnnotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- end }}
prometheus.io/scrape: "true"
prometheus.io/port: "8787"
{{- end }}