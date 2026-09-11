{{/*
  ========================== tfy-buildkitd-service helpers ==========================
*/}}

{{- define "tfy-buildkitd-service.name" -}}
{{- default "tfy-buildkitd-service" .Values.tfyBuildkitdService.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-buildkitd-service.fullname" -}}
{{- if .Values.tfyBuildkitdService.fullnameOverride }}
{{- .Values.tfyBuildkitdService.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-buildkitd-service" .Values.tfyBuildkitdService.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-buildkitd-service") }}
{{- end }}

{{- define "tfy-buildkitd-service.selectorLabels" -}}
{{- include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-buildkitd-service") }}
{{- end }}

{{- define "tfy-buildkitd-service.commonLabels" -}}
{{- $baseLabels := include "tfy-buildkitd-service.labels" . | fromYaml }}
{{- $componentLabels := default dict .Values.tfyBuildkitdService.commonLabels }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) $componentLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{- define "tfy-buildkitd-service.commonAnnotations" -}}
{{- $componentAnnotations := default dict .Values.tfyBuildkitdService.commonAnnotations }}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) $componentAnnotations }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{- define "tfy-buildkitd-service.statefulsetLabels" -}}
{{- $commonLabels := include "tfy-buildkitd-service.commonLabels" . | fromYaml }}
{{- $globalStsLabels := default dict .Values.global.statefulsetLabels }}
{{- $componentStsLabels := default dict .Values.tfyBuildkitdService.statefulsetLabels }}
{{- $mergedLabels := mergeOverwrite $commonLabels $globalStsLabels $componentStsLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{- define "tfy-buildkitd-service.statefulsetAnnotations" -}}
{{- $commonAnnotations := include "tfy-buildkitd-service.commonAnnotations" . | fromYaml }}
{{- $globalStsAnnotations := default dict .Values.global.statefulsetAnnotations }}
{{- $componentStsAnnotations := default dict .Values.tfyBuildkitdService.statefulsetAnnotations }}
{{- $statefulsetAnnotations := mergeOverwrite $globalStsAnnotations $commonAnnotations $componentStsAnnotations }}
{{- toYaml $statefulsetAnnotations }}
{{- end }}

{{- define "tfy-buildkitd-service.podLabels" -}}
{{- $selectorLabels := include "tfy-buildkitd-service.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyBuildkitdService.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{- define "tfy-buildkitd-service.podAnnotations" -}}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) .Values.tfyBuildkitdService.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{- define "tfy-buildkitd-service.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-buildkitd-service.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyBuildkitdService.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{- define "tfy-buildkitd-service.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-buildkitd-service.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyBuildkitdService.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{- define "tfy-buildkitd-service.serviceAccountName" -}}
{{- if .Values.tfyBuildkitdService.serviceAccount.name -}}
{{- .Values.tfyBuildkitdService.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- if .Values.tfyBuildkitdService.nodeSelector -}}
{{- $mergedNodeSelector := merge (deepCopy .Values.tfyBuildkitdService.nodeSelector) $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- $mergedNodeSelector := merge (deepCopy .Values.global.nodeSelector) $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else -}}
{{- toYaml $defaultNodeSelector }}
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.affinity" -}}
{{- if .Values.tfyBuildkitdService.affinity -}}
{{ toYaml .Values.tfyBuildkitdService.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.tolerations" -}}
{{- if .Values.tfyBuildkitdService.tolerations }}
{{ toYaml .Values.tfyBuildkitdService.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations -}}
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.imagePullSecrets" -}}
{{- if .Values.tfyBuildkitdService.imagePullSecrets -}}
{{- toYaml .Values.tfyBuildkitdService.imagePullSecrets }}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- $defaultsYaml := "" }}
{{- if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-buildkitd-service.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-buildkitd-service.defaultResources.large" . }}
{{- end }}
{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyBuildkitdService.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}
{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}
{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "tfy-buildkitd-service.defaultResources.medium" }}
requests:
  cpu: 2500m
  memory: 8192Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 5000m
  memory: 16384Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "tfy-buildkitd-service.defaultResources.large" }}
requests:
  cpu: 2500m
  memory: 8192Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 5000m
  memory: 16384Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "tfy-buildkitd-service.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyBuildkitdService.replicaCount -}}
{{ .Values.tfyBuildkitdService.replicaCount }}
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "tfy-buildkitd-service.storageSize" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyBuildkitdService.storage.size -}}
{{ .Values.tfyBuildkitdService.storage.size }}
{{- else if eq $tier "medium" -}}
200Gi
{{- else if eq $tier "large" -}}
200Gi
{{- end }}
{{- end }}
