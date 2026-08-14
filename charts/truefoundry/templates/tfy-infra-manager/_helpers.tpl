{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-infra-manager.name" -}}
{{- default "tfy-infra-manager" .Values.tfyInfraManager.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tfy-infra-manager.fullname" -}}
{{- if .Values.tfyInfraManager.fullnameOverride }}
{{- .Values.tfyInfraManager.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-infra-manager" .Values.tfyInfraManager.nameOverride }}
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
{{- define "tfy-infra-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "tfy-infra-manager.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-infra-manager") }}
{{- end }}

{{- define "tfy-infra-manager.commonLabels" -}}
{{- $baseLabels := include "tfy-infra-manager.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyInfraManager.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{- define "tfy-infra-manager.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyInfraManager.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "tfy-infra-manager.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-infra-manager") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyInfraManager.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{- define "tfy-infra-manager.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-infra-manager.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyInfraManager.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{- define "tfy-infra-manager.serviceLabels" -}}
{{- $commonLabels := include "tfy-infra-manager.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.tfyInfraManager.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{- define "tfy-infra-manager.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-infra-manager.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.tfyInfraManager.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{- define "tfy-infra-manager.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-infra-manager.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyInfraManager.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{- define "tfy-infra-manager.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-infra-manager.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyInfraManager.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{- define "tfy-infra-manager.deploymentLabels" -}}
{{- $commonLabels := include "tfy-infra-manager.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyInfraManager.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{- define "tfy-infra-manager.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "3" }}
{{- $commonAnnotations := include "tfy-infra-manager.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyInfraManager.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{- define "tfy-infra-manager.serviceAccountName" -}}
{{- if .Values.tfyInfraManager.serviceAccount.name -}}
{{- .Values.tfyInfraManager.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "tfy-infra-manager.parseEnv" -}}
{{ tpl (.Values.tfyInfraManager.env | toYaml) . }}
{{- end }}

{{- define "tfy-infra-manager.env" }}
{{- range $key, $val := (include "tfy-infra-manager.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyInfraManager.envSecretName }}
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

{{- define "tfy-infra-manager.replicas" }}
{{- if .Values.tfyInfraManager.replicaCount -}}
{{ .Values.tfyInfraManager.replicaCount }}
{{- else -}}
1
{{- end }}
{{- end }}

{{- define "tfy-infra-manager.defaultResources"}}
requests:
  cpu: 100m
  memory: 64Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 500m
  memory: 128Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-infra-manager.resources" }}
{{- $defaults := fromYaml (include "tfy-infra-manager.defaultResources" .) | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyInfraManager.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}
{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}
{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "tfy-infra-manager.imagePullSecrets" -}}
{{- if .Values.tfyInfraManager.imagePullSecrets -}}
{{- toYaml .Values.tfyInfraManager.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}

{{- define "tfy-infra-manager.volumes" -}}
{{- $userVolumes := .Values.tfyInfraManager.extraVolumes | default (list) -}}
{{- $final := $userVolumes -}}
{{- $caData := include "truefoundry.customCA.volumeItems" . | fromJson -}}
{{- if $caData.items -}}
{{- $final = concat $final $caData.items -}}
{{- end -}}
{{- toYaml $final }}
{{- end }}

{{- define "tfy-infra-manager.volumeMounts" -}}
{{- $userMounts := .Values.tfyInfraManager.extraVolumeMounts | default (list) -}}
{{- $final := $userMounts -}}
{{- $caData := include "truefoundry.customCA.volumeMountItems" . | fromJson -}}
{{- if $caData.items -}}
{{- $final = concat $final $caData.items -}}
{{- end -}}
{{- toYaml $final }}
{{- end }}
