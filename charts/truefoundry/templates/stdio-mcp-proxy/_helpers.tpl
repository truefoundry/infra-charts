{{/*
Expand the name of the chart.
*/}}
{{- define "stdio-mcp-proxy.name" -}}
{{- default "stdio-mcp-proxy" .Values.stdioMcpProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "stdio-mcp-proxy.fullname" -}}
{{- if .Values.stdioMcpProxy.fullnameOverride }}
{{- .Values.stdioMcpProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "stdio-mcp-proxy" .Values.stdioMcpProxy.nameOverride }}
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
{{- define "stdio-mcp-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "stdio-mcp-proxy.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "stdio-mcp-proxy") }}
{{- end }}

{{- define "stdio-mcp-proxy.commonLabels" -}}
{{- $baseLabels := include "stdio-mcp-proxy.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.stdioMcpProxy.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.stdioMcpProxy.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "stdio-mcp-proxy.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "stdio-mcp-proxy") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.stdioMcpProxy.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.podAnnotations" -}}
{{- $commonAnnotations := include "stdio-mcp-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.stdioMcpProxy.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceLabels" -}}
{{- $commonLabels := include "stdio-mcp-proxy.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.stdioMcpProxy.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceAnnotations" -}}
{{- $commonAnnotations := include "stdio-mcp-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.stdioMcpProxy.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceAccountLabels" -}}
{{- $commonLabels := include "stdio-mcp-proxy.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.stdioMcpProxy.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "stdio-mcp-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.stdioMcpProxy.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{- define "stdio-mcp-proxy.deploymentLabels" -}}
{{- $commonLabels := include "stdio-mcp-proxy.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.stdioMcpProxy.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "stdio-mcp-proxy.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.stdioMcpProxy.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceMonitorLabels" -}}
{{- $commonLabels := include "stdio-mcp-proxy.commonLabels" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.stdioMcpProxy.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "stdio-mcp-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.stdioMcpProxy.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{- define "stdio-mcp-proxy.serviceAccountName" -}}
{{- if .Values.stdioMcpProxy.serviceAccount.name -}}
{{- .Values.stdioMcpProxy.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "stdio-mcp-proxy.parseEnv" -}}
{{ tpl (.Values.stdioMcpProxy.env | toYaml) . }}
{{- end }}

{{- define "stdio-mcp-proxy.env" }}
{{- range $key, $val := (include "stdio-mcp-proxy.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.stdioMcpProxy.envSecretName }}
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

{{- define "stdio-mcp-proxy.resourceTier" }}
{{- $tier := .Values.stdioMcpProxy.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "stdio-mcp-proxy.replicas" }}
{{- $tier := include "stdio-mcp-proxy.resourceTier" . }}
{{- if .Values.stdioMcpProxy.replicaCount -}}
{{ .Values.stdioMcpProxy.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{- define "stdio-mcp-proxy.defaultResources.small"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 1Gi
{{- end }}

{{- define "stdio-mcp-proxy.defaultResources.medium"}}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 1Gi
{{- end }}

{{- define "stdio-mcp-proxy.defaultResources.large"}}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 512Mi
limits:
  cpu: 500m
  memory: 1Gi
  ephemeral-storage: 2Gi
{{- end }}

{{- define "stdio-mcp-proxy.resources" }}
{{- $tier := include "stdio-mcp-proxy.resourceTier" . }}
{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "stdio-mcp-proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "stdio-mcp-proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "stdio-mcp-proxy.defaultResources.large" . }}
{{- end }}
{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.stdioMcpProxy.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}
{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}
{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "stdio-mcp-proxy.imagePullSecrets" -}}
{{- if .Values.stdioMcpProxy.imagePullSecrets -}}
{{- toYaml .Values.stdioMcpProxy.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}

{{- define "stdio-mcp-proxy.volumes" -}}
{{- $userVolumes := .Values.stdioMcpProxy.extraVolumes | default (list) -}}
{{- $final := $userVolumes -}}
{{- $caData := include "truefoundry.customCA.volumeItems" . | fromJson -}}
{{- if $caData.items -}}
{{- $final = concat $final $caData.items -}}
{{- end -}}
{{- toYaml $final }}
{{- end }}

{{- define "stdio-mcp-proxy.volumeMounts" -}}
{{- $userMounts := .Values.stdioMcpProxy.extraVolumeMounts | default (list) -}}
{{- $final := $userMounts -}}
{{- $caData := include "truefoundry.customCA.volumeMountItems" . | fromJson -}}
{{- if $caData.items -}}
{{- $final = concat $final $caData.items -}}
{{- end -}}
{{- toYaml $final }}
{{- end }}
