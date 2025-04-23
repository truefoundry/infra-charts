{{/*
Expand the name of the chart.
*/}}
{{- define "buildkitd-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "buildkitd-service.fullname" -}}
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
{{- define "buildkitd-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common Annotations
*/}}
{{- define "buildkitd-service.annotations" -}}
{{- if .Values.annotations }}
  {{- toYaml .Values.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "buildkitd-service.labels" -}}
helm.sh/chart: {{ include "buildkitd-service.chart" . }}
{{ include "buildkitd-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
{{- end }}

{{/*
Selector labels
*/}}
{{- define "buildkitd-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "buildkitd-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "buildkitd-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "buildkitd-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Merge nodeSelector
  */}}
{{- define "buildkitd-service.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- if .Values.nodeSelector -}}
{{- $mergedNodeSelector := merge .Values.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- $mergedNodeSelector := merge .Values.global.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else -}}
{{- $mergedNodeSelector := $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
{{- end }}

{{/*
ServiceAccount annotations for sds-server
*/}}
{{- define "buildkitd-service.serviceAccount.annotations" -}}
{{- if .Values.serviceAccount.annotations }}
    {{- toYaml .Values.serviceAccount.annotations }}
{{- else if .Values.annotations }}
    {{- toYaml .Values.annotations }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Pod Annotations
*/}}
{{- define "buildkitd-service.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ toYaml .Values.podAnnotations }}
{{- else if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{- define "buildkitd-service.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "medium" }}
  {{- $defaultsYaml = include "buildkitd-service.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "buildkitd-service.defaultResources.large" . }}
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

{{- define "buildkitd-service.defaultResources.medium" }}
requests:
  cpu: 2500m
  memory: 8192Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 5000m
  memory: 16384Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "buildkitd-service.defaultResources.large" }}
requests:
  cpu: 2500m
  memory: 8192Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 5000m
  memory: 16384Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "buildkitd-service.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "buildkitd-service.storageSize" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.storage.size -}}
{{ .Values.storage.size }}
{{- else if eq $tier "medium" -}}
200Gi
{{- else if eq $tier "large" -}}
200Gi
{{- end }}
{{- end }}

{{/*
Affinity for the buildkitd service
*/}}
{{- define "buildkitd-service.affinity" -}}
{{- if .Values.affinity -}}
{{ toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for the buildkitd service
*/}}
{{- define "buildkitd-service.tolerations" -}}
{{- if .Values.tolerations }}
{{ toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations -}}
{{- else -}}
[]
{{- end }}
{{- end }}