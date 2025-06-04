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
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Deployment Volumes
*/}}
{{- define "tfy-otel-collector.volumes" -}}
- name: config-volume
  configMap:
    name: {{ include "tfy-otel-collector.fullname" . }}-cm
{{- with .Values.extraVolumes }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Deployment VolumeMounts
*/}}
{{- define "tfy-otel-collector.volumeMounts" -}}
- name: config-volume
  mountPath: /data/config.yaml
  readOnly: true
  subPath: config.yaml
{{- with .Values.extraVolumeMounts }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{- define "tfy-otel-collector.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "tfy-otel-collector.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-otel-collector.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-otel-collector.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 400m
  memory: 512Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-otel-collector.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
2
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{/*
Affinity rules for Otel-collector
*/}}
{{- define "tfy-otel-collector.affinity" -}}
{{- if .Values.affinity -}}
{{ toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for Otel-collector
*/}}
{{- define "tfy-otel-collector.tolerations" -}}
{{- if .Values.tolerations -}}
{{ toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for tfy-otel-collector deployment
*/}}
{{- define "tfy-otel-collector.nodeSelector" -}}
{{- if .Values.nodeSelector -}}
{{- toYaml .Values.nodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- toYaml .Values.global.nodeSelector }}
{{- else -}}
{}
{{- end }}
{{- end }}