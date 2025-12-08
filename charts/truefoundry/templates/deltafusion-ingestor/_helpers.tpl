{{/*
Expand the name of the chart.
*/}}
{{- define "deltafusion-ingestor.name" -}}
{{- default "deltafusion-ingestor" .Values.deltaFusionIngestor.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deltafusion-ingestor.fullname" -}}
{{- if .Values.deltaFusionIngestor.fullnameOverride }}
{{- .Values.deltaFusionIngestor.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "deltafusion-ingestor" .Values.deltaFusionIngestor.nameOverride }}
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
{{- define "deltafusion-ingestor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "deltafusion-ingestor.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "deltafusion-ingestor") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "deltafusion-ingestor.commonLabels" -}}
{{- $baseLabels := include "deltafusion-ingestor.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.deltaFusionIngestor.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "deltafusion-ingestor.commonAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.deltaFusionIngestor.commonAnnotations $syncWaveAnnotation }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "deltafusion-ingestor.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "deltafusion-ingestor") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.deltaFusionIngestor.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "deltafusion-ingestor.podAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.deltaFusionIngestor.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "deltafusion-ingestor.serviceLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.deltaFusionIngestor.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "deltafusion-ingestor.serviceAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.deltaFusionIngestor.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "deltafusion-ingestor.serviceAccountLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.deltaFusionIngestor.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "deltafusion-ingestor.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.deltaFusionIngestor.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  StatefulSet Labels - merges commonLabels with statefulset-specific labels
  */}}
{{- define "deltafusion-ingestor.statefulsetLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $statefulsetLabels := mergeOverwrite $commonLabels .Values.deltaFusionIngestor.statefulsetLabels }}
{{- toYaml $statefulsetLabels }}
{{- end }}

{{/*
  StatefulSet Annotations - merges commonAnnotations with statefulset-specific annotations
  */}}
{{- define "deltafusion-ingestor.statefulsetAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $statefulsetAnnotations := mergeOverwrite $commonAnnotations .Values.deltaFusionIngestor.statefulsetAnnotations }}
{{- toYaml $statefulsetAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "deltafusion-ingestor.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.deltaFusionIngestor.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}


{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor specific labels
  */}}
{{- define "deltafusion-ingestor.serviceMonitorLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.deltaFusionIngestor.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}


{{/*
  Create the name of the service account to use
  */}}
{{- define "deltafusion-ingestor.serviceAccountName" -}}
{{- if .Values.deltaFusionIngestor.serviceAccount.name -}}
{{- .Values.deltaFusionIngestor.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
Resource Tier
*/}}
{{- define "deltafusion-ingestor.resourceTier" }}
{{- $tier := .Values.deltaFusionIngestor.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "deltafusion-ingestor.resources" }}
{{- $tier := include "deltafusion-ingestor.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "deltafusion-ingestor.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "deltafusion-ingestor.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "deltafusion-ingestor.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.deltaFusionIngestor.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "deltafusion-ingestor.defaultResources.small" }}
requests:
  cpu: 500m
  memory: 1000M
  ephemeral-storage: 100M
limits:
  cpu: 1000m
  memory: 1200M
  ephemeral-storage: 100M
{{- end }}

{{- define "deltafusion-ingestor.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1500M
  ephemeral-storage: 100M
limits:
  cpu: 1000m
  memory: 1700M
  ephemeral-storage: 100M
{{- end }}

{{- define "deltafusion-ingestor.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 2000M
  ephemeral-storage: 100M
limits:
  cpu: 1000m
  memory: 2200M
  ephemeral-storage: 100M
{{- end }}

{{- define "deltafusion-ingestor.replicas" }}
{{- $tier := include "deltafusion-ingestor.resourceTier" . }}
{{- if .Values.deltaFusionIngestor.replicaCount -}}
{{ .Values.deltaFusionIngestor.replicaCount }}
{{- else if eq $tier "small" -}}
2
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{/*
NodeSelector merge logic
*/}}
{{- define "deltafusion-ingestor.nodeSelector" -}}
{{- if .Values.deltaFusionIngestor.nodeSelector -}}
{{- toYaml .Values.deltaFusionIngestor.nodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- toYaml .Values.global.nodeSelector }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for the deltafusion-ingestor service
*/}}
{{- define "deltafusion-ingestor.tolerations" -}}
{{- if .Values.deltaFusionIngestor.tolerations }}
{{ toYaml .Values.deltaFusionIngestor.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations -}}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "deltafusion-ingestor.parseEnv" -}}
{{- include "truefoundry.storage-credentials" . }}
DATASET_PATH: {{ .Values.deltaFusionIngestor.storage.mountPath }}
PORT: "{{ .Values.deltaFusionIngestor.service.port }}"
{{ tpl (.Values.deltaFusionIngestor.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "deltafusion-ingestor.env" }}
{{- range $key, $val := (include "deltafusion-ingestor.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.deltaFusionIngestor.envSecretName }}
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

{{- define "deltafusion-ingestor.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.deltaFusionIngestor.extraVolumes }}
  {{- range .Values.deltaFusionIngestor.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}

{{- define "deltafusion-ingestor.volumeMounts" -}}
- name: data
  mountPath: {{ .Values.deltaFusionIngestor.storage.mountPath }}
{{- with .Values.deltaFusionIngestor.extraVolumeMounts }}
{{- toYaml . | nindent 0 }}
{{- end -}}
{{- end -}}

{{- define "deltafusion-ingestor.imagePullSecrets" -}}
{{- if .Values.deltaFusionIngestor.imagePullSecrets -}}
{{- toYaml .Values.deltaFusionIngestor.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}


{{/*Compaction*/}}

{{- define "deltafusion-compaction.name" -}}
{{- default "deltafusion-compaction" .Values.deltaFusionCompaction.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deltafusion-compaction.fullname" -}}
{{- if .Values.deltaFusionCompaction.fullnameOverride }}
{{- .Values.deltaFusionCompaction.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "deltafusion-compaction" .Values.deltaFusionCompaction.nameOverride }}
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
{{- define "deltafusion-compaction.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "deltafusion-compaction.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "deltafusion-compaction") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "deltafusion-compaction.commonLabels" -}}
{{- $baseLabels := include "deltafusion-compaction.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.deltaFusionCompaction.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "deltafusion-compaction.commonAnnotations" -}}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.deltaFusionCompaction.commonAnnotations }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "deltafusion-compaction.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "deltafusion-compaction") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.deltaFusionCompaction.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "deltafusion-compaction.podAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-compaction.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.deltaFusionCompaction.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "deltafusion-compaction.serviceAccountLabels" -}}
{{- $commonLabels := include "deltafusion-compaction.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.deltaFusionCompaction.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "deltafusion-compaction.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-compaction.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.deltaFusionCompaction.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  CronJob Labels - merges commonLabels with cronjob-specific labels
  */}}
{{- define "deltafusion-compaction.cronJobLabels" -}}
{{- $commonLabels := include "deltafusion-compaction.commonLabels" . | fromYaml }}
{{- $cronJobLabels := mergeOverwrite $commonLabels .Values.deltaFusionCompaction.cronJobLabels }}
{{- toYaml $cronJobLabels }}
{{- end }}

{{/*
  CronJob Annotations - merges commonAnnotations with statefulset-specific annotations
  */}}
{{- define "deltafusion-compaction.cronJobAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-compaction.commonAnnotations" . | fromYaml }}
{{- $cronJobAnnotations := mergeOverwrite $commonAnnotations .Values.deltaFusionCompaction.cronJobAnnotations }}
{{- toYaml $cronJobAnnotations }}
{{- end }}


{{/*
  Create the name of the service account to use
  */}}
{{- define "deltafusion-compaction.serviceAccountName" -}}
{{- if .Values.deltaFusionCompaction.serviceAccount.name -}}
{{- .Values.deltaFusionCompaction.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
Resource Tier
*/}}
{{- define "deltafusion-compaction.resourceTier" }}
{{- $tier := .Values.deltaFusionCompaction.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "deltafusion-compaction.defaultResources.small" }}
requests:
  cpu: 1000m
  memory: 2000M
  ephemeral-storage: 10000M
limits:
  cpu: 2000m
  memory: 2400M
  ephemeral-storage: 10000M
{{- end }}

{{- define "deltafusion-compaction.defaultResources.medium" }}
requests:
  cpu: 2000m
  memory: 4000M
  ephemeral-storage: 20000M
limits:
  cpu: 4000m
  memory: 4800M
  ephemeral-storage: 20000M
{{- end }}

{{- define "deltafusion-compaction.defaultResources.large" }}
requests:
  cpu: 4000m
  memory: 8000M
  ephemeral-storage: 40000M
limits:
  cpu: 8000m
  memory: 9600M
  ephemeral-storage: 40000M
{{- end }}

{{/*
Resource Tied Envs
spill pool size is ~1/3rd of memory requests
*/}}
{{- define "deltafusion-compaction.resourceTiedEnvs" }}
{{- $tier := include "deltafusion-compaction.resourceTier" . }}
{{- if eq $tier "small" }}
COMPACTION_MAX_SPILL_SIZE_MB: "650"
DATAFUSION_EXECUTION_BATCH_SIZE: "512"
{{- else if eq $tier "medium" }}
COMPACTION_MAX_SPILL_SIZE_MB: "1300"
DATAFUSION_EXECUTION_BATCH_SIZE: "1024"
{{- else if eq $tier "large" }}
COMPACTION_MAX_SPILL_SIZE_MB: "2600"
DATAFUSION_EXECUTION_BATCH_SIZE: "2048"
{{- end }}
{{- end }}


{{- define "deltafusion-compaction.resources" }}
{{- $tier := include "deltafusion-compaction.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "deltafusion-compaction.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "deltafusion-compaction.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "deltafusion-compaction.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.deltaFusionCompaction.resources | default dict }}
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
{{- define "deltafusion-compaction.parseEnv" -}}
{{- include "truefoundry.storage-credentials" . }}
{{ tpl (.Values.deltaFusionCompaction.env | toYaml) . }}
{{- end }}

{{/*merge envs*/}}
{{- define "deltafusion-compaction.mergedEnvs" -}}
{{- $merged := merge (include "deltafusion-compaction.parseEnv" . | fromYaml) (include "deltafusion-compaction.resourceTiedEnvs" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "deltafusion-compaction.env" }}
{{- range $key, $val := (include "deltafusion-compaction.mergedEnvs" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.deltaFusionCompaction.envSecretName }}
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
Tolerations for the deltafusion-compaction service
*/}}
{{- define "deltafusion-compaction.tolerations" -}}
{{- if .Values.deltaFusionCompaction.tolerations }}
{{ toYaml .Values.deltaFusionCompaction.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations -}}
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "deltafusion-compaction.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.deltaFusionCompaction.extraVolumes }}
  {{- range .Values.deltaFusionCompaction.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}

{{- define "deltafusion-compaction.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.deltaFusionCompaction.extraVolumeMounts }}
  {{- range .Values.deltaFusionCompaction.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{- define "deltafusion-compaction.imagePullSecrets" -}}
{{- if .Values.deltaFusionCompaction.imagePullSecrets -}}
{{- toYaml .Values.deltaFusionCompaction.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}