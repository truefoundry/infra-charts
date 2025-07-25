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
Common Annotations
*/}}
{{- define "deltafusion-query-server.inputCommonAnnotations" -}}
{{- if .Values.deltaFusionQueryServer.commonAnnotations }}
{{ toYaml .Values.deltaFusionQueryServer.commonAnnotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- end }}
{{- end }}

{{- define "deltafusion-query-server.commonAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "1") (include "deltafusion-query-server.inputCommonAnnotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}


{{/*
Pod Annotations
*/}}
{{- define "deltafusion-query-server.podAnnotations" -}}
{{- $merged := merge (include "deltafusion-query-server.commonAnnotations" . | fromYaml) (.Values.deltaFusionQueryServer.podAnnotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
ServiceAccount annotations
*/}}
{{- define "deltafusion-query-server.serviceAccountAnnotations" -}}
{{- $merged := merge (include "deltafusion-query-server.commonAnnotations" . | fromYaml) (.Values.deltaFusionQueryServer.serviceAccount.annotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Service Annotations
*/}}
{{- define "deltafusion-query-server.serviceAnnotations" -}}
{{- $merged := merge (include "deltafusion-query-server.commonAnnotations" . | fromYaml) (.Values.deltaFusionQueryServer.service.annotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Statefulset Annotations
*/}}
{{- define "deltafusion-query-server.deploymentAnnotations" -}}
{{- $merged := merge (include "deltafusion-query-server.commonAnnotations" . | fromYaml) (.Values.deltaFusionQueryServer.deploymentAnnotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deltafusion-query-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deltafusion-query-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deltafusion-query-server.commonLabels" -}}
helm.sh/chart: {{ include "deltafusion-query-server.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.deltaFusionQueryServer.image.tag | quote }}
{{- if .Values.deltaFusionQueryServer.commonLabels }}
{{ toYaml .Values.deltaFusionQueryServer.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
Pod Labels
*/}}
{{- define "deltafusion-query-server.podLabels" -}}
{{- $merged := merge (include "deltafusion-query-server.commonLabels" . | fromYaml) (.Values.deltaFusionQueryServer.podLabels) }}
{{- $merged = merge $merged (include "deltafusion-query-server.selectorLabels" . | fromYaml) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Service Labels
*/}}
{{- define "deltafusion-query-server.serviceLabels" -}}
{{- $merged := merge (include "deltafusion-query-server.commonLabels" . | fromYaml) (.Values.deltaFusionQueryServer.service.labels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
ServiceAccount Labels
*/}}
{{- define "deltafusion-query-server.serviceAccountLabels" -}}
{{- $merged := merge (include "deltafusion-query-server.commonLabels" . | fromYaml) (.Values.deltaFusionQueryServer.serviceAccount.labels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Deployment Labels
*/}}
{{- define "deltafusion-query-server.deploymentLabels" -}}
{{- $merged := merge (include "deltafusion-query-server.commonLabels" . | fromYaml) (.Values.deltaFusionQueryServer.deploymentLabels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deltafusion-query-server.serviceAccountName" -}}
{{- if .Values.deltaFusionQueryServer.serviceAccount.create -}}
{{- default (include "deltafusion-query-server.fullname" .) "deltafusion-query-server" }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "deltafusion-query-server.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

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
{{- $overrides := .Values.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define  "deltafusion-query-server.ephemeralStorage.limit" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if eq $tier "small" -}}
10000M
{{- else if eq $tier "medium" -}}
20000M
{{- else if eq $tier "large" -}}
40000M
{{- end }}
{{- end }}

{{- define "deltafusion-query-server.defaultResources.small" }}
requests:
  cpu: 1
  memory: 4000M
  ephemeral-storage: 5000M
limits:
  cpu: 2
  memory: 8000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}

{{- define "deltafusion-query-server.defaultResources.medium" }}
requests:
  cpu: 3
  memory: 12000M
  ephemeral-storage: 20000M
limits:
  cpu: 4
  memory: 16000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}

{{- define "deltafusion-query-server.defaultResources.large" }}
requests:
  cpu: 7
  memory: 28000M
  ephemeral-storage: 40000M
limits:
  cpu: 8
  memory: 32000M
  ephemeral-storage: {{ include "deltafusion-query-server.ephemeralStorage.limit" . }}
{{- end }}


{{/*
Resource Tied Envs
cache is 60% of memory limit
query is 40% of memory limit
spill is ??% of ephemeral storage requests
*/}}
{{- define "deltafusion-query-server.resourceTiedEnvs" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if eq $tier "small" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "1"
CACHE_MEMORY_MB: "4800"
QUERY_MEMORY_POOL_MB: "3200"
QUERY_SPILL_DISK_SIZE_MB: "5000"
{{- else if eq $tier "medium" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "3"
DATAFUSION_EXECUTION_BATCH_SIZE: "20000"
CACHE_MEMORY_MB: "9600"
QUERY_MEMORY_POOL_MB: "6400"
QUERY_SPILL_DISK_SIZE_MB: "20000"
{{- else if eq $tier "large" }}
DATAFUSION_EXECUTION_TARGET_PARTITIONS: "8"
DATAFUSION_EXECUTION_BATCH_SIZE: "20000"
CACHE_MEMORY_MB: "19200"
QUERY_MEMORY_POOL_MB: "12800"
QUERY_SPILL_DISK_SIZE_MB: "40000"
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "deltafusion-query-server.parseEnv" -}}
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
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if eq $tier "small" -}}
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
{{- with .Values.deltaFusionQueryServer.extraVolumeMounts }}
{{- toYaml . | nindent 0 }}
{{- end -}}
{{- end -}}
