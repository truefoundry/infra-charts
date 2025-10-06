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
Annotations
*/}}
{{- define "buildkitd-service.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
 Base labels
  */}}
{{- define "buildkitd-service.commonLabels" -}}
{{- $defaultLabels := dict "helm.sh/chart" (include "buildkitd-service.chart" .) "app.kubernetes.io/managed-by" .Release.Name "app.kubernetes.io/version" .Values.image.tag }}
{{- $mergedLabels := mergeOverwrite $defaultLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}


{{/*
  Pod Labels
  */}}
{{- define "buildkitd-service.podLabels" -}}
{{- $selectorLabels := include "buildkitd-service.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "buildkitd-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "buildkitd-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
  Statefulset Labels - merges commonLabels with statefulset-specific labels
  */}}
{{- define "buildkitd-service.statefulsetLabels" -}}
{{- $commonLabels := include "buildkitd-service.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.global.statefulsetLabels .Values.statefulsetLabels }}
{{- toYaml $mergedLabels }}
{{- end }}


{{/*
  Statefulset annotations
  */}}
{{- define "buildkitd-service.statefulsetAnnotations" -}}
{{- $commonAnnotations := include "buildkitd-service.commonAnnotations" . | fromYaml }}
{{- $statefulsetAnnotations := mergeOverwrite (deepCopy .Values.global.statefulsetAnnotations) $commonAnnotations .Values.statefulsetAnnotations }}
{{- toYaml $statefulsetAnnotations }}
{{- end }}

{{/*
  Service Account Labels
  */}}
{{- define "buildkitd-service.serviceAccountLabels" -}}
{{- $commonLabels := include "buildkitd-service.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "buildkitd-service.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "buildkitd-service.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}



{{/*
Create the name of the service account to use
*/}}
{{- define "buildkitd-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else }}
{{- .Values.global.serviceAccount.name -}}
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
{{- else if .Values.commonAnnotations }}
    {{- toYaml .Values.commonAnnotations }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Pod Annotations
*/}}
{{- define "buildkitd-service.podAnnotations" -}}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations ) .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
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