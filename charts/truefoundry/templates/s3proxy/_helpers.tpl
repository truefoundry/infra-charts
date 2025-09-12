{{/*
Expand the name of the chart.
*/}}
{{- define "s3proxy.name" -}}
{{- default "s3proxy" .Values.s3proxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "s3proxy.fullname" -}}
{{- if .Values.s3proxy.fullnameOverride }}
{{- .Values.s3proxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "s3proxy" .Values.s3proxy.nameOverride }}
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
{{- define "s3proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "s3proxy.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "s3proxy") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "s3proxy.commonLabels" -}}
{{- $baseLabels := include "s3proxy.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.s3proxy.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "s3proxy.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.s3proxy.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "s3proxy.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "s3proxy") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.s3proxy.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "s3proxy.podAnnotations" -}}
{{- $commonAnnotations := include "s3proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.s3proxy.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "s3proxy.serviceLabels" -}}
{{- $commonLabels := include "s3proxy.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.s3proxy.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "s3proxy.serviceAnnotations" -}}
{{- $commonAnnotations := include "s3proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.s3proxy.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "s3proxy.serviceAccountLabels" -}}
{{- $commonLabels := include "s3proxy.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.s3proxy.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "s3proxy.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "s3proxy.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.s3proxy.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "s3proxy.deploymentLabels" -}}
{{- $commonLabels := include "s3proxy.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.s3proxy.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "s3proxy.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "s3proxy.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.s3proxy.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}



{{/*
  Create the name of the service account to use
  */}}
{{- define "s3proxy.serviceAccountName" -}}
{{- if .Values.s3proxy.serviceAccount.name -}}
{{- .Values.s3proxy.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}



{{/*
  Parse env from template
  */}}
{{- define "s3proxy.parseEnv" -}}
{{ tpl (.Values.s3proxy.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "s3proxy.env" }}
{{- range $key, $val := (include "s3proxy.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.s3proxy.envSecretName }}
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
  Create the name of the configmap to use
  */}}
{{- define "s3proxy.configmapName" -}}
{{- printf "%s-cm" (include "s3proxy.name" .) }}
{{- end }}

{{- define "s3proxy.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.s3proxy.extraVolumes }}
  {{- range .Values.s3proxy.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes = append $volumes (dict "name" "config-vol" "configMap" (dict "name" (include "s3proxy.configmapName" .))) }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "s3proxy.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.s3proxy.extraVolumeMounts }}
  {{- range .Values.s3proxy.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts = append $volumeMounts (dict "name" "config-vol" "mountPath" "/opt/s3proxy/config.properties" "subPath" "config.properties") }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{/*
Resource Tier
*/}}
{{- define "s3proxy.resourceTier" }}
{{- $tier := .Values.s3proxy.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "s3proxy.replicas" }}
{{- $tier := include "s3proxy.resourceTier" . }}
{{- if .Values.s3proxy.replicaCount -}}
{{ .Values.s3proxy.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{- define "s3proxy.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "s3proxy.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "s3proxy.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "s3proxy.resources" }}
{{- $tier := include "s3proxy.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.s3proxy.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "s3proxy.imagePullSecrets" -}}
{{- if .Values.s3proxy.imagePullSecrets -}}
{{- toYaml .Values.s3proxy.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}