{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-proxy.name" -}}
{{- default "tfy-proxy" .Values.tfyProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-proxy.fullname" -}}
{{- if .Values.tfyProxy.fullnameOverride }}
{{- .Values.tfyProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-proxy" .Values.tfyProxy.nameOverride }}
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
{{- define "tfy-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "tfy-proxy.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-proxy") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-proxy.commonLabels" -}}
{{- $baseLabels := include "tfy-proxy.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyProxy.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-proxy.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyProxy.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "tfy-proxy.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-proxy") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyProxy.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-proxy.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyProxy.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-proxy.serviceLabels" -}}
{{- $commonLabels := include "tfy-proxy.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.tfyProxy.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-proxy.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.tfyProxy.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-proxy.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-proxy.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyProxy.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-proxy.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyProxy.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  HPA Labels - merges commonLabels with hpa-specific labels
  */}}
{{- define "tfy-proxy.hpaLabels" -}}
{{- $commonLabels := include "tfy-proxy.commonLabels" . | fromYaml }}
{{- $hpaLabels := mergeOverwrite $commonLabels .Values.tfyProxy.autoscaling.labels }}
{{- toYaml $hpaLabels }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-proxy.deploymentLabels" -}}
{{- $commonLabels := include "tfy-proxy.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyProxy.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-proxy.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyProxy.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  HPA annotations
  */}}
{{- define "tfy-proxy.hpaAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $hpaAnnotations := mergeOverwrite $commonAnnotations $syncWaveAnnotation .Values.tfyProxy.autoscaling.annotations }}
{{- toYaml $hpaAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "tfy-proxy.serviceMonitorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $commonLabels := include "tfy-proxy.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.tfyProxy.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor-specific annotations
  */}}
{{- define "tfy-proxy.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.tfyProxy.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-proxy.serviceAccountName" -}}
{{- if .Values.tfyProxy.serviceAccount.create -}}
{{- default (include "tfy-proxy.fullname" .) "tfy-proxy" }}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
  Image Pull Secret
*/}}
{{- define "tfy-proxy.imagePullSecrets" -}}
{{- if .Values.tfyProxy.imagePullSecrets -}}
{{- toYaml .Values.tfyProxy.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-proxy.parseEnv" -}}
{{ tpl (.Values.tfyProxy.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-proxy.env" }}
{{- range $key, $val := (include "tfy-proxy.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyProxy.envSecretName }}
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

{{- define "tfy-proxy.volumes" -}}
{{- $cmName := (.Values.tfyProxy.existingProxyConfigMapName | default (include "tfy-proxy.fullname" .)) -}}
{{- $defaultVolume := dict "name" (include "tfy-proxy.fullname" .) "configMap" (dict "defaultMode" 420 "name" $cmName) -}}

{{- $caddyData := dict "name" "caddy-data" "emptyDir" (dict) -}}
{{- $caddyConfigData := dict "name" "caddy-config-data"   "emptyDir" (dict) -}}
{{- $volumes := list $defaultVolume $caddyData $caddyConfigData  -}}

{{- /* If extraVolumes are defined, concatenate them with the default list */}}
{{- if .Values.tfyProxy.extraVolumes -}}
  {{- $volumes = concat $volumes .Values.tfyProxy.extraVolumes -}}
{{- end -}}

{{- toYaml $volumes -}}
{{- end -}}


{{- define "tfy-proxy.volumeMounts" -}}
{{- $cmName := (.Values.tfyProxy.existingProxyConfigMapName | default (include "tfy-proxy.fullname" .)) -}}
{{- $defaultVolumeMounts := dict "name" $cmName "mountPath" "/etc/caddy/Caddyfile" "subPath" "Caddyfile" -}}

{{- $caddyData := dict "name" "caddy-data" "mountPath" "/data" -}}
{{- $caddyConfigData := dict "name" "caddy-config-data" "mountPath" "/config" -}}
{{- $volumeMounts := list $defaultVolumeMounts $caddyData $caddyConfigData -}}


{{- /* If extraVolumeMounts are defined, concatenate them with the default list */}}
{{- if .Values.tfyProxy.extraVolumeMounts -}}
  {{- $volumeMounts = concat $volumeMounts .Values.tfyProxy.extraVolumeMounts -}}
{{- end -}}

{{- /* Convert the final, combined list of volume mounts to YAML */}}
{{- toYaml $volumeMounts -}}
{{- end -}}

{{- define "tfy-proxy.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyProxy.replicaCount -}}
{{ .Values.tfyProxy.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "tfy-proxy.defaultResources.small"}}
requests:
  cpu: 50m
  memory: 64Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 512Mi
{{- end }}
{{- define "tfy-proxy.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 512Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 1024Mi
{{- end }}
{{- define "tfy-proxy.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 512Mi
  ephemeral-storage: 1024Mi
limits:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 2048Mi
{{- end }}

{{- define "tfy-proxy.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-proxy.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyProxy.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}