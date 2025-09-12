{{/*
Expand the name of the chart.
*/}}
{{- define "mlfoundry-server.name" -}}
{{- default "mlfoundry-server" .Values.mlfoundryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "mlfoundry-server.fullname" -}}
{{- if .Values.mlfoundryServer.fullnameOverride }}
{{- .Values.mlfoundryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "mlfoundry-server" .Values.mlfoundryServer.nameOverride }}
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
{{- define "mlfoundry-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "mlfoundry-server.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "mlfoundry-server") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "mlfoundry-server.commonLabels" -}}
{{- $baseLabels := include "mlfoundry-server.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.mlfoundryServer.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "mlfoundry-server.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.mlfoundryServer.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "mlfoundry-server.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "mlfoundry-server") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.mlfoundryServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "mlfoundry-server.podAnnotations" -}}
{{- $commonAnnotations := include "mlfoundry-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.mlfoundryServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "mlfoundry-server.serviceLabels" -}}
{{- $commonLabels := include "mlfoundry-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.mlfoundryServer.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "mlfoundry-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "mlfoundry-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.mlfoundryServer.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "mlfoundry-server.serviceAccountLabels" -}}
{{- $commonLabels := include "mlfoundry-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.mlfoundryServer.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "mlfoundry-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "mlfoundry-server.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.mlfoundryServer.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "mlfoundry-server.deploymentLabels" -}}
{{- $commonLabels := include "mlfoundry-server.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.mlfoundryServer.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "mlfoundry-server.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "mlfoundry-server.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.mlfoundryServer.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "mlfoundry-server.serviceAccountName" -}}
{{- if .Values.mlfoundryServer.serviceAccount.name -}}
{{- .Values.mlfoundryServer.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}



{{/*
  Parse env from template
  */}}
{{- define "mlfoundry-server.parseEnv" -}}
{{ tpl (.Values.mlfoundryServer.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "mlfoundry-server.env" }}
{{- range $key, $val := (include "mlfoundry-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.mlfoundryServer.envSecretName }}
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
{{- define "mlfoundry-server.resourceTier" }}
{{- $tier := .Values.mlfoundryServer.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "mlfoundry-server.replicas" }}
{{- $tier := include "mlfoundry-server.resourceTier" . }}
{{- if .Values.mlfoundryServer.replicaCount -}}
{{ .Values.mlfoundryServer.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "mlfoundry-server.defaultResources.small" }}
requests:
  cpu: 100m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "mlfoundry-server.defaultResources.medium" }}
requests:
  cpu: 200m
  memory: 1024Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 2048Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "mlfoundry-server.defaultResources.large" }}
requests:
  cpu: 600m
  memory: 1536Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1200m
  memory: 3072Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "mlfoundry-server.resources" }}
{{- $tier := include "mlfoundry-server.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "mlfoundry-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "mlfoundry-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "mlfoundry-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.mlfoundryServer.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "mlfoundry-server.volumes" -}}
{{- $required := dict "name" "truefoundry-tmpdir" "emptyDir" (dict) -}}
{{- $userVolumes := .Values.mlfoundryServer.extraVolumes | default (list) -}}
{{- $final := prepend $userVolumes $required }}
{{- toYaml $final }}
{{- end }}

{{- define "mlfoundry-server.volumeMounts" -}}
{{- $required := dict "name" "truefoundry-tmpdir" "mountPath" "/tmp" -}}
{{- $userMounts := .Values.mlfoundryServer.extraVolumeMounts | default (list) -}}
{{- $final := prepend $userMounts $required }}
{{- toYaml $final }}
{{- end }}

{{- define "mlfoundry-server.imagePullSecrets" -}}
{{- if .Values.mlfoundryServer.imagePullSecrets -}}
{{- toYaml .Values.mlfoundryServer.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}