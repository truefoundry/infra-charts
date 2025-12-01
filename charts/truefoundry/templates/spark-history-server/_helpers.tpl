{{/*
Expand the name of the chart.
*/}}
{{- define "spark-history-server.name" -}}
{{- default "spark-history-server" .Values.sparkHistoryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "spark-history-server.fullname" -}}
{{- if .Values.sparkHistoryServer.fullnameOverride }}
{{- .Values.sparkHistoryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "spark-history-server" .Values.sparkHistoryServer.nameOverride }}
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
{{- define "spark-history-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "spark-history-server.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "spark-history-server") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "spark-history-server.commonLabels" -}}
{{- $baseLabels := include "spark-history-server.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.sparkHistoryServer.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "spark-history-server.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.sparkHistoryServer.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "spark-history-server.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "spark-history-server") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.sparkHistoryServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "spark-history-server.podAnnotations" -}}
{{- $commonAnnotations := include "spark-history-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.sparkHistoryServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "spark-history-server.serviceLabels" -}}
{{- $commonLabels := include "spark-history-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.sparkHistoryServer.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "spark-history-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "spark-history-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.sparkHistoryServer.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "spark-history-server.serviceAccountLabels" -}}
{{- $commonLabels := include "spark-history-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.sparkHistoryServer.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "spark-history-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "spark-history-server.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.sparkHistoryServer.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "spark-history-server.deploymentLabels" -}}
{{- $commonLabels := include "spark-history-server.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.sparkHistoryServer.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "spark-history-server.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "spark-history-server.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.sparkHistoryServer.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}



{{/*
  Create the name of the service account to use
  */}}
{{- define "spark-history-server.serviceAccountName" -}}
{{- if .Values.sparkHistoryServer.serviceAccount.name -}}
{{- .Values.sparkHistoryServer.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "spark-history-server.parseEnv" -}}
{{ tpl (.Values.sparkHistoryServer.env | toYaml) . }}
{{- end }}


{{/*
  Create the env file
  */}}
{{- define "spark-history-server.env" }}
{{- range $key, $val := (include "spark-history-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.sparkHistoryServer.envSecretName }}
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

{{- define "spark-history-server.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.sparkHistoryServer.extraVolumes }}
  {{- range .Values.sparkHistoryServer.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "spark-history-server.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.sparkHistoryServer.extraVolumeMounts }}
  {{- range .Values.sparkHistoryServer.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{/*
Resource Tier
*/}}
{{- define "spark-history-server.resourceTier" }}
{{- $tier := .Values.sparkHistoryServer.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "spark-history-server.replicas" }}
{{- $tier := include "spark-history-server.resourceTier" . }}
{{- if .Values.sparkHistoryServer.replicaCount -}}
{{ .Values.sparkHistoryServer.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{- define "spark-history-server.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 6144Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 7168Mi
{{- end }}

{{- define "spark-history-server.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 8192Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 9216Mi
{{- end }}
{{- define "spark-history-server.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 10240Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 11264Mi
{{- end }}

{{- define "spark-history-server.resources" }}
{{- $tier := include "spark-history-server.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.sparkHistoryServer.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "spark-history-server.imagePullSecrets" -}}
{{- if .Values.sparkHistoryServer.imagePullSecrets -}}
{{- toYaml .Values.sparkHistoryServer.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}