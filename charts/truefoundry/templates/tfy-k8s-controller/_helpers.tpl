{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-k8s-controller.name" -}}
{{- default "tfy-k8s-controller" .Values.tfyK8sController.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-k8s-controller.fullname" -}}
{{- if .Values.tfyK8sController.fullnameOverride }}
{{- .Values.tfyK8sController.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-k8s-controller" .Values.tfyK8sController.nameOverride }}
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
{{- define "tfy-k8s-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-k8s-controller.labels" -}}
helm.sh/chart: {{ include "tfy-k8s-controller.chart" . }}
{{- range $name, $value := .Values.tfyK8sController.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-k8s-controller.selectorLabels" . }}
{{- if .Values.tfyK8sController.imageTag }}
app.kubernetes.io/version: {{ .Values.tfyK8sController.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-k8s-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-k8s-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-k8s-controller.serviceAccountName" -}}
{{- default (include "tfy-k8s-controller.fullname" .) "tfy-k8s-controller" }}

{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "tfy-k8s-controller.parseEnv" -}}
{{ tpl (.Values.tfyK8sController.env | toYaml) . }}

{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-k8s-controller.env" }}
{{- range $key, $val := (include "tfy-k8s-controller.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyK8sController.envSecretName }}
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

{{- define "tfy-k8s-controller.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.tfyK8sController.extraVolumes }}
  {{- range .Values.tfyK8sController.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "tfy-k8s-controller.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.tfyK8sController.extraVolumeMounts }}
  {{- range .Values.tfyK8sController.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}
