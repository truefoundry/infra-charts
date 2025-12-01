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
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "tfy-k8s-controller.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-k8s-controller") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-k8s-controller.commonLabels" -}}
{{- $baseLabels := include "tfy-k8s-controller.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyK8sController.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-k8s-controller.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyK8sController.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - excludes commonLabels to prevent version-related restarts
  */}}
{{- define "tfy-k8s-controller.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-k8s-controller") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyK8sController.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-k8s-controller.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-k8s-controller.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyK8sController.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-k8s-controller.serviceLabels" -}}
{{- $commonLabels := include "tfy-k8s-controller.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.tfyK8sController.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-k8s-controller.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-k8s-controller.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.tfyK8sController.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-k8s-controller.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-k8s-controller.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyK8sController.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-k8s-controller.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-k8s-controller.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyK8sController.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-k8s-controller.deploymentLabels" -}}
{{- $commonLabels := include "tfy-k8s-controller.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyK8sController.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-k8s-controller.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "tfy-k8s-controller.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyK8sController.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "tfy-k8s-controller.serviceMonitorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $commonLabels := include "tfy-k8s-controller.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.tfyK8sController.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor-specific annotations
  */}}
{{- define "tfy-k8s-controller.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-k8s-controller.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.tfyK8sController.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-k8s-controller.serviceAccountName" -}}
{{- if .Values.tfyK8sController.serviceAccount.name -}}
{{- .Values.tfyK8sController.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
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

{{/*
Resource Tier
*/}}
{{- define "tfy-k8s-controller.resourceTier" }}
{{- $tier := .Values.tfyK8sController.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "tfy-k8s-controller.replicas" }}
{{- $tier := include "tfy-k8s-controller.resourceTier" . }}
{{- if .Values.tfyK8sController.replicaCount -}}
{{ .Values.tfyK8sController.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "tfy-k8s-controller.defaultResources.small"}}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "tfy-k8s-controller.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "tfy-k8s-controller.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 800Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 1600Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-k8s-controller.resources" }}
{{- $tier := include "tfy-k8s-controller.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-k8s-controller.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-k8s-controller.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-k8s-controller.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyK8sController.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "tfy-k8s-controller.imagePullSecrets" -}}
{{- if .Values.tfyK8sController.imagePullSecrets -}}
{{- toYaml .Values.tfyK8sController.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}