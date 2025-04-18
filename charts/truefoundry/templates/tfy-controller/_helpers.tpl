{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-controller.name" -}}
{{- default "tfy-controller" .Values.tfyController.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-controller.fullname" -}}
{{- if .Values.tfyController.fullnameOverride }}
{{- .Values.tfyController.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-controller" .Values.tfyController.nameOverride }}
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
{{- define "tfy-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "tfy-controller.podLabels" -}}
{{ include "tfy-controller.selectorLabels" . }}
{{- if .Values.tfyController.image.tag }}
app.kubernetes.io/version: {{ .Values.tfyController.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.tfyController.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-controller.labels" -}}
helm.sh/chart: {{ include "tfy-controller.chart" . }}
{{ include "tfy-controller.podLabels" . }}
{{- if .Values.tfyController.commonLabels }}
{{ toYaml .Values.tfyController.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "tfy-controller.annotations" -}}
{{- if .Values.tfyController.annotations }}
{{ toYaml .Values.tfyController.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "tfy-controller.serviceAccountAnnotations" -}}
{{- if .Values.tfyController.serviceAccount.annotations }}
{{ toYaml .Values.tfyController.serviceAccount.annotations }}
{{- else if .Values.tfyController.annotations }}
{{ toYaml .Values.tfyController.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-controller.serviceAccountName" -}}
{{- default (include "tfy-controller.fullname" .) "tfy-controller" }}

{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-controller.parseEnv" -}}
{{ tpl (.Values.tfyController.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-controller.env" }}
{{- range $key, $val := (include "tfy-controller.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyController.envSecretName }}
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

{{- define "tfy-controller.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyController.replicaCount }}
{{ .Values.tfyController.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "tfy-controller.defaultResources.small"}}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-controller.defaultResources.medium"}}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-controller.defaultResources.large"}}
requests:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 2000m
  memory: 2056Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-controller.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-controller.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-controller.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-controller.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyController.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}