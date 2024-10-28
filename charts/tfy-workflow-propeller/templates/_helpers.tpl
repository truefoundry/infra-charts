{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-signed-url-server.name" -}}
{{- default "tfy-signed-url-server" .Values.tfySignedUrlServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-signed-url-server.fullname" -}}
{{- if .Values.tfySignedUrlServer.fullnameOverride }}
{{- .Values.tfySignedUrlServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-signed-url-server" .Values.tfySignedUrlServer.nameOverride }}
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
{{- define "tfy-signed-url-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-signed-url-server.labels" -}}
helm.sh/chart: {{ include "tfy-signed-url-server.chart" . }}
{{- range $name, $value := .Values.tfySignedUrlServer.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-signed-url-server.selectorLabels" . }}
{{- if .Values.tfySignedUrlServer.imageTag }}
app.kubernetes.io/version: {{ .Values.tfySignedUrlServer.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-signed-url-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-signed-url-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-signed-url-server.serviceAccountName" -}}
{{- default (include "tfy-signed-url-server.fullname" .) "tfy-signed-url-server" }}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "tfy-signed-url-server.parseEnv" -}}
{{ tpl (.Values.tfySignedUrlServer.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-signed-url-server.env" }}
{{- range $key, $val := (include "tfy-signed-url-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfySignedUrlServer.envSecretName }}
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
  Merge nodeSelector
  */}}
{{- define "tfy-signed-url-server.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge $defaultNodeSelector .Values.tfySignedUrlServer.nodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
