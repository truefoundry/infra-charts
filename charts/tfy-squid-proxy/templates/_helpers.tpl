{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-squid-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tfy-squid-proxy.fullname" -}}
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
{{- define "tfy-squid-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tfy-squid-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-squid-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Release.Name }}-squid-proxy
{{- end }}


{{/*
 Base labels
  */}}
{{- define "tfy-squid-proxy.labels" -}}
helm.sh/chart: {{ include "tfy-squid-proxy.chart" . }}
{{ include "tfy-squid-proxy.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-squid-proxy.commonLabels" -}}
{{- $baseLabels := include "tfy-squid-proxy.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-squid-proxy.serviceLabels" -}}
{{- $commonLabels := include "tfy-squid-proxy.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Pod labels
  */}}
{{- define "tfy-squid-proxy.podLabels" -}}
{{- $selectorLabels := include "tfy-squid-proxy.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-squid-proxy.commonAnnotations" -}}
{{- $commonAnnotations := (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-squid-proxy.deploymentLabels" -}}
{{- $commonLabels := include "tfy-squid-proxy.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-squid-proxy.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-squid-proxy.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-squid-proxy.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-squid-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-squid-proxy.podAnnotations" -}}
{{- $checksumAnnotation := dict "checksum/config" (include (print $.Template.BasePath "/configmap.yaml") . | sha256sum) }}
{{- $commonAnnotations := include "tfy-squid-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $checksumAnnotation $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{- define "tfy-squid-proxy.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
{{- end }}

{{- define "tfy-squid-proxy.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-squid-proxy.defaultResources.large" }}
requests:
  cpu: 250m
  memory: 512Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-squid-proxy.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-squid-proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-squid-proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-squid-proxy.defaultResources.large" . }}
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

{{- define "tfy-squid-proxy.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{/*
Affinity for tfy-squid-proxy deployment
*/}}
{{- define "tfy-squid-proxy.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{- toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for tfy-squid-proxy deployment
*/}}
{{- define "tfy-squid-proxy.tolerations" -}}
{{- if .Values.tolerations -}}
{{- toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{- toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for tfy-squid-proxy deployment
*/}}
{{- define "tfy-squid-proxy.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end }}

{{- define "tfy-squid-proxy.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Container Security Context for tfy-squid-proxy deployment
*/}}
{{- define "tfy-squid-proxy.containerSecurityContext" -}}
{{- if .Values.containerSecurityContext -}}
{{- toYaml .Values.containerSecurityContext }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Pod Security Context for tfy-squid-proxy deployment
*/}}
{{- define "tfy-squid-proxy.podSecurityContext" -}}
{{- if .Values.podSecurityContext -}}
{{- toYaml .Values.podSecurityContext }}
{{- else -}}
{}
{{- end }}
{{- end }}
