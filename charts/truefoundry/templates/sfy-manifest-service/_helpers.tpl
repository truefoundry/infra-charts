{{/*
Expand the name of the chart.
*/}}
{{- define "sfy-manifest-service.name" -}}
{{- default "sfy-manifest-service" .Values.sfyManifestService.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "sfy-manifest-service.fullname" -}}
{{- if .Values.sfyManifestService.fullnameOverride }}
{{- .Values.sfyManifestService.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "sfy-manifest-service" .Values.sfyManifestService.nameOverride }}
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
{{- define "sfy-manifest-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "sfy-manifest-service.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "sfy-manifest-service") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "sfy-manifest-service.commonLabels" -}}
{{- $baseLabels := include "sfy-manifest-service.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.sfyManifestService.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "sfy-manifest-service.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.sfyManifestService.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "sfy-manifest-service.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "sfy-manifest-service") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.sfyManifestService.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "sfy-manifest-service.podAnnotations" -}}
{{- $commonAnnotations := include "sfy-manifest-service.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.sfyManifestService.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "sfy-manifest-service.serviceLabels" -}}
{{- $commonLabels := include "sfy-manifest-service.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.sfyManifestService.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "sfy-manifest-service.serviceAnnotations" -}}
{{- $commonAnnotations := include "sfy-manifest-service.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.sfyManifestService.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "sfy-manifest-service.serviceAccountLabels" -}}
{{- $commonLabels := include "sfy-manifest-service.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.sfyManifestService.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "sfy-manifest-service.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "sfy-manifest-service.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.sfyManifestService.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "sfy-manifest-service.deploymentLabels" -}}
{{- $commonLabels := include "sfy-manifest-service.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.sfyManifestService.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "sfy-manifest-service.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "sfy-manifest-service.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.sfyManifestService.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "sfy-manifest-service.serviceMonitorLabels" -}}
{{- $commonLabels := include "sfy-manifest-service.commonLabels" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.sfyManifestService.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor-specific annotations
  */}}
{{- define "sfy-manifest-service.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "sfy-manifest-service.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.sfyManifestService.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}




{{/*
  Create the name of the service account to use
  */}}
{{- define "sfy-manifest-service.serviceAccountName" -}}
{{- if .Values.sfyManifestService.serviceAccount.name -}}
{{- .Values.sfyManifestService.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}



{{/*
  Parse env from template
  */}}
{{- define "sfy-manifest-service.parseEnv" -}}
{{ tpl (.Values.sfyManifestService.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "sfy-manifest-service.env" }}
{{- range $key, $val := (include "sfy-manifest-service.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.sfyManifestService.envSecretName }}
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
Resource Tier
*/}}
{{- define "sfy-manifest-service.resourceTier" }}
{{- $tier := .Values.sfyManifestService.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "sfy-manifest-service.replicas" }}
{{- $tier := include "sfy-manifest-service.resourceTier" . }}
{{- if .Values.sfyManifestService.replicaCount -}}
{{ .Values.sfyManifestService.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{- define "sfy-manifest-service.defaultResources.small"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.defaultResources.medium"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.defaultResources.large"}}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "sfy-manifest-service.resources" }}
{{- $tier := include "sfy-manifest-service.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "sfy-manifest-service.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.sfyManifestService.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}


{{- define "sfy-manifest-service.imagePullSecrets" -}}
{{- if .Values.sfyManifestService.imagePullSecrets -}}
{{- toYaml .Values.sfyManifestService.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}