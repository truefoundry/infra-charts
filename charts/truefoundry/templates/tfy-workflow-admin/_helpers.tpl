{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-workflow-admin.name" -}}
{{- default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-workflow-admin.fullname" -}}
{{- if .Values.tfyWorkflowAdmin.fullnameOverride }}
{{- .Values.tfyWorkflowAdmin.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride }}
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
{{- define "tfy-workflow-admin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-workflow-admin.labels" -}}
helm.sh/chart: {{ include "tfy-workflow-admin.chart" . }}
{{- range $name, $value := .Values.tfyWorkflowAdmin.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-workflow-admin.selectorLabels" . }}
{{- if .Values.tfyWorkflowAdmin.imageTag }}
app.kubernetes.io/version: {{ .Values.tfyWorkflowAdmin.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-workflow-admin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-workflow-admin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-workflow-admin.serviceAccountName" -}}
{{- default (include "tfy-workflow-admin.fullname" .) "tfy-workflow-admin"}}

{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-workflow-admin.parseEnv" -}}
{{ tpl (.Values.tfyWorkflowAdmin.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-workflow-admin.env" }}
{{- range $key, $val := (include "tfy-workflow-admin.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyWorkflowAdmin.envSecretName }}
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
  Merge default nodeSelector with nodeSelector specified in tfyWorkflowAdmin nodeSelector
  */}}
{{- define "tfy-workflow-admin.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge $defaultNodeSelector .Values.tfyWorkflowAdmin.nodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
