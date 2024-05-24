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
{{ $name }}: {{ tpl $value $ | quote }}
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
{{- if (tpl .Values.configs.cicdTemplates .) }}
- name: CICD_TEMPLATES_DIRECTORY
  value: /opt/truefoundry/configs/cicd-templates
{{- end }}
{{- end }}

{{- define "app.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.extraVolumes }}
  {{- range .Values.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- if (tpl .Values.configs.cicdTemplates .) }}
  {{- $volumes = append $volumes (dict "name" "configs-cicd-templates" "configMap" (dict "name" (tpl .Values.configs.cicdTemplates .))) }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "app.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.extraVolumeMounts }}
  {{- range .Values.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- if (tpl .Values.configs.cicdTemplates .) }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-cicd-templates" "mountPath" "/opt/truefoundry/configs/cicd-templates") }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}