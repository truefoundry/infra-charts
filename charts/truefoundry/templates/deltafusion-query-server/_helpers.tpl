{{/*
Expand the name of the chart.
*/}}
{{- define "deltafusion-query-server.name" -}}
{{- default "deltafusion-query-server" .Values.deltaFusionQueryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deltafusion-query-server.fullname" -}}
{{- if .Values.deltaFusionQueryServer.fullnameOverride }}
{{- .Values.deltaFusionQueryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "deltafusion-query-server" .Values.deltaFusionQueryServer.nameOverride }}
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
{{- define "deltafusion-query-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "deltafusion-query-server.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "deltafusion-query-server") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "deltafusion-query-server.commonLabels" -}}
{{- $baseLabels := include "deltafusion-query-server.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.deltaFusionQueryServer.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "deltafusion-query-server.commonAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "1" }}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.deltaFusionQueryServer.commonAnnotations $syncWaveAnnotation }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "deltafusion-query-server.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "deltafusion-query-server") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.deltaFusionQueryServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "deltafusion-query-server.podAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-query-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.deltaFusionQueryServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "deltafusion-query-server.serviceLabels" -}}
{{- $commonLabels := include "deltafusion-query-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.deltaFusionQueryServer.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "deltafusion-query-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-query-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.deltaFusionQueryServer.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "deltafusion-query-server.serviceAccountLabels" -}}
{{- $commonLabels := include "deltafusion-query-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.deltaFusionQueryServer.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "deltafusion-query-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-query-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.deltaFusionQueryServer.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "deltafusion-query-server.deploymentLabels" -}}
{{- $commonLabels := include "deltafusion-query-server.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deltaFusionQueryServer.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment Annotations - merges commonAnnotations with deployment-specific annotations
  */}}
{{- define "deltafusion-query-server.deploymentAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-query-server.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite  (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deltaFusionQueryServer.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}


{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "deltafusion-query-server.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-query-server.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.deltaFusionQueryServer.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}


{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor specific labels
  */}}
{{- define "deltafusion-query-server.serviceMonitorLabels" -}}
{{- $commonLabels := include "deltafusion-query-server.commonLabels" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.deltaFusionQueryServer.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}


{{/*
  Create the name of the service account to use
  */}}
{{- define "deltafusion-query-server.serviceAccountName" -}}
{{- if .Values.deltaFusionQueryServer.serviceAccount.name -}}
{{- .Values.deltaFusionQueryServer.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
Resource Tier
*/}}
{{- define "deltafusion-query-server.resourceTier" }}
{{- $tier := .Values.deltaFusionQueryServer.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{/*
Ephemeral Storage Limit
*/}}
{{- define  "deltafusion-query-server.ephemeralStorage.limit" }}
{{- $tier := include "deltafusion-query-server.resourceTier" . }}
{{- if eq $tier "small" -}}
10000M
{{- else if eq $tier "medium" -}}
20000M
{{- else if eq $tier "large" -}}
40000M
{{- end }}
{{- end }}

{{/*
Default Resources
cpu limit is not set explicitly. We want to allow it to use up to the node limits
*/}}
{{- define "deltafusion-query-server.defaultResources.small" }}
requests:
  cpu: 1
  memory: 4000M
  ephemeral-storage: 5000M
limits:
  memory: 8000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}

{{- define "deltafusion-query-server.defaultResources.medium" }}
requests:
  cpu: 3
  memory: 12000M
  ephemeral-storage: 20000M
limits:
  memory: 16000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}

{{- define "deltafusion-query-server.defaultResources.large" }}
requests:
  cpu: 7
  memory: 28000M
  ephemeral-storage: 40000M
limits:
  memory: 32000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}


{{/*
Resource Tied Envs
partitions is (cpu request + 1) x 4
cache is 60% of memory limit
query is 40% of memory limit
spill is 40% of ephemeral storage requests
*/}}
{{- define "deltafusion-query-server.resourceTiedEnvs" }}
{{- $tier := include "deltafusion-query-server.resourceTier" . }}
{{- if eq $tier "small" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "8"
DATAFUSION_EXECUTION_BATCH_SIZE: "20000"
CACHE_MEMORY_MB: "4800"
QUERY_MEMORY_POOL_MB: "3200"
QUERY_SPILL_DISK_SIZE_MB: "2000"
{{- else if eq $tier "medium" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "16"
DATAFUSION_EXECUTION_BATCH_SIZE: "20000"
CACHE_MEMORY_MB: "9600"
QUERY_MEMORY_POOL_MB: "6400"
QUERY_SPILL_DISK_SIZE_MB: "8000"
{{- else if eq $tier "large" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "32"
DATAFUSION_EXECUTION_BATCH_SIZE: "20000"
CACHE_MEMORY_MB: "19200"
QUERY_MEMORY_POOL_MB: "12800"
QUERY_SPILL_DISK_SIZE_MB: "16000"
{{- end }}
{{- end }}

{{/*
Resources
*/}}
{{- define "deltafusion-query-server.resources" }}
{{- $tier := include "deltafusion-query-server.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
{{- $defaultsYaml = include "deltafusion-query-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
{{- $defaultsYaml = include "deltafusion-query-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
{{- $defaultsYaml = include "deltafusion-query-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.deltaFusionQueryServer.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "deltafusion-query-server.parseEnv" -}}
{{- include "truefoundry.storage-credentials" . }}
TRUEFOUNDRY_CONTROL_PLANE_VERSION: "{{ .Values.global.controlPlaneChartVersion }}"
IMAGE_TAG: "{{ .Values.deltaFusionQueryServer.image.tag }}"
PORT: "{{ .Values.deltaFusionQueryServer.service.port }}"
{{ tpl (.Values.deltaFusionQueryServer.env | toYaml) . }}
{{- end }}


{{/*merge envs*/}}
{{- define "deltafusion-query-server.mergedEnvs" -}}
{{- $merged := merge (include "deltafusion-query-server.parseEnv" . | fromYaml) (include "deltafusion-query-server.resourceTiedEnvs" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "deltafusion-query-server.env" }}
{{- range $key, $val := (include "deltafusion-query-server.mergedEnvs" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.deltaFusionQueryServer.envSecretName }}
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

{{- define "deltafusion-query-server.replicas" }}
{{- $tier := include "deltafusion-query-server.resourceTier" . }}
{{- if .Values.deltaFusionQueryServer.replicaCount -}}
{{ .Values.deltaFusionQueryServer.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- else -}}
1
{{- end }}
{{- end }}

{{/*
NodeSelector merge logic
*/}}
{{- define "deltafusion-query-server.nodeSelector" -}}
{{- if .Values.deltaFusionQueryServer.nodeSelector -}}
{{- toYaml .Values.deltaFusionQueryServer.nodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- toYaml .Values.global.nodeSelector }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for the deltafusion-query-server service
*/}}
{{- define "deltafusion-query-server.tolerations" -}}
{{- if .Values.deltaFusionQueryServer.tolerations }}
{{ toYaml .Values.deltaFusionQueryServer.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}


{{- define "deltafusion-query-server.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.deltaFusionQueryServer.extraVolumes }}
  {{- range .Values.deltaFusionQueryServer.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "deltafusion-query-server.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.deltaFusionQueryServer.extraVolumeMounts }}
  {{- range .Values.deltaFusionQueryServer.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{/*
Image Pull Secrets
*/}}
{{- define "deltafusion-query-server.imagePullSecrets" -}}
{{- if .Values.deltaFusionQueryServer.imagePullSecrets -}}
{{- toYaml .Values.deltaFusionQueryServer.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}