{{/*
Expand the name of the chart.
*/}}
{{- define "truefoundry-frontend-app.name" -}}
{{- default "truefoundry-frontend-app" .Values.truefoundryFrontendApp.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "truefoundry-frontend-app.fullname" -}}
{{- if .Values.truefoundryFrontendApp.fullnameOverride }}
{{- .Values.truefoundryFrontendApp.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "truefoundry-frontend-app" .Values.truefoundryFrontendApp.nameOverride }}
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
{{- define "truefoundry-frontend-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "truefoundry-frontend-app.podLabels" -}}
{{ include "truefoundry-frontend-app.selectorLabels" . }}
{{- if .Values.truefoundryFrontendApp.image.tag }}
app.kubernetes.io/version: {{ .Values.truefoundryFrontendApp.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.truefoundryFrontendApp.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "truefoundry-frontend-app.labels" -}}
helm.sh/chart: {{ include "truefoundry-frontend-app.chart" . }}
{{ include "truefoundry-frontend-app.podLabels" . }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "truefoundry-frontend-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "truefoundry-frontend-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "truefoundry-frontend-app.serviceAccountName" -}}
{{- default (include "truefoundry-frontend-app.fullname" .) "truefoundry-frontend-app" }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "truefoundry-frontend-app.parseEnv" -}}
{{ tpl (.Values.truefoundryFrontendApp.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "truefoundry-frontend-app.env" }}
{{- range $key, $val := (include "truefoundry-frontend-app.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.truefoundryFrontendApp.envSecretName }}
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
  Merge default nodeSelector with nodeSelector specified in truefoundry-frontend-app nodeSelector
  */}}
{{- define "truefoundry-frontend-app.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge .Values.truefoundryFrontendApp.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
