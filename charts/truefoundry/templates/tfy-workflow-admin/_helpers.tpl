{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-workflow-admin.name" -}}
{{- default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-workflow-admin.fullname" -}}
{{- if .Values.tfyWorkflowAdmin.fullnameOverride }}
{{- .Values.tfyWorkflowAdmin.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride }}
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
{{- define "tfy-workflow-admin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "tfy-workflow-admin.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-workflow-admin") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-workflow-admin.commonLabels" -}}
{{- $baseLabels := include "tfy-workflow-admin.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyWorkflowAdmin.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-workflow-admin.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyWorkflowAdmin.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "tfy-workflow-admin.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-workflow-admin") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyWorkflowAdmin.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-workflow-admin.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-workflow-admin.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyWorkflowAdmin.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Server Pod Labels
  */}}
{{- define "tfy-workflow-admin.server.podLabels" -}}
{{- $podLabels := include "tfy-workflow-admin.podLabels" . | fromYaml }}
{{- $serverLabels := mergeOverwrite $podLabels (dict "app.kubernetes.io/workflow-component" "server") }}
{{- toYaml $serverLabels }}
{{- end }}

{{/*
  Scheduler Pod Labels
  */}}
{{- define "tfy-workflow-admin.scheduler.podLabels" -}}
{{- $podLabels := include "tfy-workflow-admin.podLabels" . | fromYaml }}
{{- $schedulerLabels := mergeOverwrite $podLabels (dict "app.kubernetes.io/workflow-component" "scheduler") }}
{{- toYaml $schedulerLabels }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-workflow-admin.serviceLabels" -}}
{{- $commonLabels := include "tfy-workflow-admin.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.tfyWorkflowAdmin.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-workflow-admin.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-workflow-admin.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.tfyWorkflowAdmin.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-workflow-admin.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-workflow-admin.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyWorkflowAdmin.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-workflow-admin.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-workflow-admin.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyWorkflowAdmin.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-workflow-admin.deploymentLabels" -}}
{{- $commonLabels := include "tfy-workflow-admin.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyWorkflowAdmin.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-workflow-admin.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "tfy-workflow-admin.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyWorkflowAdmin.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  ConfigMap annotations
  */}}
{{- define "tfy-workflow-admin.configMap.annotations" -}}
{{- $commonAnnotations := include "tfy-workflow-admin.commonAnnotations" . | fromYaml }}
{{- $configMapAnnotations := mergeOverwrite $commonAnnotations (dict "argocd.argoproj.io/sync-options" "PruneLast=true") }}
{{- toYaml $configMapAnnotations }}
{{- end }}



{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-workflow-admin.serviceAccountName" -}}
{{- if .Values.tfyWorkflowAdmin.serviceAccount.name -}}
{{- .Values.tfyWorkflowAdmin.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-workflow-admin.parseEnv" -}}
{{ tpl (.Values.tfyWorkflowAdmin.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-workflow-admin.env" }}
{{- range $key, $val := (include "tfy-workflow-admin.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyWorkflowAdmin.envSecretName }}
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
{{- define "tfy-workflow-admin.resourceTier" }}
{{- $tier := .Values.tfyWorkflowAdmin.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "tfy-workflow-admin-server.replicas" }}
{{- $tier := include "tfy-workflow-admin.resourceTier" . }}
{{- if .Values.tfyWorkflowAdmin.replicaCount -}}
{{ .Values.tfyWorkflowAdmin.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "tfy-workflow-admin-scheduler.replicas" }}
{{- $tier := include "tfy-workflow-admin.resourceTier" . }}
{{- if .Values.tfyWorkflowAdmin.replicaCount -}}
{{ .Values.tfyWorkflowAdmin.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.resources" }}
{{- $tier := include "tfy-workflow-admin.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyWorkflowAdmin.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged | indent 8 }}
{{- end }}

{{- define "tfy-workflow-admin-scheduler.resources" }}
{{- $tier := include "tfy-workflow-admin.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyWorkflowAdmin.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged | indent 8 }}
{{- end }}

{{- define "tfy-workflow-admin.imagePullSecrets" -}}
{{- if .Values.tfyWorkflowAdmin.imagePullSecrets -}}
{{- toYaml .Values.tfyWorkflowAdmin.imagePullSecrets | indent 8 }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets | indent 8 }}
{{- end -}}
{{- end }}