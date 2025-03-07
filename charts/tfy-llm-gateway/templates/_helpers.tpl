{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-llm-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-llm-gateway.fullname" -}}
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
{{- define "tfy-llm-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-llm-gateway.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Ingress labels
  */}}
{{- define "tfy-llm-gateway.ingress.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
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
{{- define "tfy-llm-gateway.annotations" -}}
{{- if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-llm-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-llm-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-llm-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tfy-llm-gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Annotation
*/}}
{{- define "tfy-llm-gateway.serviceAccount.annotations" -}}
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

{{- define "tfy-llm-gateway.virtualservice.annotations" -}}
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
{{- define "tfy-llm-gateway.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-llm-gateway.env" }}
{{- range $key, $val := (include "tfy-llm-gateway.parseEnv" .) | fromYaml }}
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
{{- define "tfy-llm-gateway.ingress.annotations" -}}
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
{{- define "tfy-llm-gateway.service.annotations" -}}
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
{{- define "tfy-llm-gateway.podAnnotations" -}}
{{- if .Values.podAnnotations }}
  {{- toYaml .Values.podAnnotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- end }}
prometheus.io/scrape: "true"
prometheus.io/port: "8787"
{{- end }}