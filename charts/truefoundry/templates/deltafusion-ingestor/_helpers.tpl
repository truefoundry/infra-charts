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
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "1" }}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.deltaFusionIngestor.commonAnnotations $syncWaveAnnotation }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges commonLabels with pod-specific labels
  */}}
{{- define "deltafusion-ingestor.podLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "deltafusion-ingestor") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.labels) $commonLabels (deepCopy .Values.global.podLabels) .Values.deltaFusionIngestor.podLabels $selectorLabels }}
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
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "deltafusion-ingestor.serviceMonitorLabels" -}}
{{- $commonLabels := include "deltafusion-ingestor.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels .Values.deltaFusionIngestor.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor-specific annotations
  */}}
{{- define "deltafusion-ingestor.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "deltafusion-ingestor.commonAnnotations" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations $prometheusLabel .Values.deltaFusionIngestor.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
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
  memory: 1000Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 1000m
  memory: 2000Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "deltafusion-ingestor.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1000Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 1000m
  memory: 2000Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "deltafusion-ingestor.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 1000Mi
  ephemeral-storage: 100Mi
limits:
  cpu: 1000m
  memory: 2000Mi
  ephemeral-storage: 100Mi
{{- end }}

{{- define "deltafusion-ingestor.replicas" }}
{{- $tier := include "deltafusion-ingestor.resourceTier" . }}
{{- if .Values.replicaCount -}}
2
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
{{/*SPANS_DATASET_PATH is Deprecated*/}}
SPANS_DATASET_PATH: {{ .Values.deltaFusionIngestor.storage.mountPath }}
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
{{- toYaml .Values.deltaFusionIngestor.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}