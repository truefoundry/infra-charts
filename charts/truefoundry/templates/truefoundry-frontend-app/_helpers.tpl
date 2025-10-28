{{/*
Expand the name of the chart.
*/}}
{{- define "truefoundry-frontend-app.name" -}}
{{- default "truefoundry-frontend-app" .Values.truefoundryFrontendApp.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "truefoundry-frontend-app.fullname" -}}
{{- if .Values.truefoundryFrontendApp.fullnameOverride }}
{{- .Values.truefoundryFrontendApp.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "truefoundry-frontend-app" .Values.truefoundryFrontendApp.nameOverride }}
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
{{- define "truefoundry-frontend-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "truefoundry-frontend-app.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "truefoundry-frontend-app") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "truefoundry-frontend-app.commonLabels" -}}
{{- $baseLabels := include "truefoundry-frontend-app.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.truefoundryFrontendApp.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "truefoundry-frontend-app.commonAnnotations" -}}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.truefoundryFrontendApp.commonAnnotations }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "truefoundry-frontend-app.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "truefoundry-frontend-app") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.truefoundryFrontendApp.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "truefoundry-frontend-app.podAnnotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.truefoundryFrontendApp.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "truefoundry-frontend-app.serviceLabels" -}}
{{- $commonLabels := include "truefoundry-frontend-app.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.truefoundryFrontendApp.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "truefoundry-frontend-app.serviceAnnotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.truefoundryFrontendApp.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "truefoundry-frontend-app.serviceAccountLabels" -}}
{{- $commonLabels := include "truefoundry-frontend-app.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.truefoundryFrontendApp.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "truefoundry-frontend-app.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.truefoundryFrontendApp.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "truefoundry-frontend-app.deploymentLabels" -}}
{{- $commonLabels := include "truefoundry-frontend-app.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.truefoundryFrontendApp.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment Annotations - merges commonAnnotations with deployment-specific annotations
  */}}
{{- define "truefoundry-frontend-app.deploymentAnnotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "5" }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.truefoundryFrontendApp.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Ingress Annotations
  */}}
{{- define "truefoundry-frontend-app.ingress.annotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }}
{{- $ingressAnnotations := mergeOverwrite $commonAnnotations .Values.truefoundryFrontendApp.ingress.annotations }}
{{- toYaml $ingressAnnotations }}
{{- end }}

{{/*
  Ingress VirtualService Annotations
  */}}
{{- define "truefoundry-frontend-app.istio.virtualService.annotations" -}}
{{- $commonAnnotations := include "truefoundry-frontend-app.commonAnnotations" . | fromYaml }}
{{- $virtualServiceAnnotations := mergeOverwrite $commonAnnotations .Values.truefoundryFrontendApp.istio.virtualservice.annotations }}
{{- toYaml $virtualServiceAnnotations }}
{{- end }}

{{/*
  Ingress Labels - merges commonLabels with ingress-specific labels
  */}}
{{- define "truefoundry-frontend-app.ingress.labels" -}}
{{- $commonLabels := include "truefoundry-frontend-app.commonLabels" . | fromYaml }}
{{- $ingressLabels := mergeOverwrite $commonLabels .Values.truefoundryFrontendApp.ingress.labels }}
{{- toYaml $ingressLabels }}
{{- end }}


{{/*
  Create the name of the service account to use
  */}}
{{- define "truefoundry-frontend-app.serviceAccountName" -}}
{{- default (include "truefoundry-frontend-app.fullname" .) "truefoundry-frontend-app" }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "truefoundry-frontend-app.parseEnv" -}}
{{ tpl (.Values.truefoundryFrontendApp.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "truefoundry-frontend-app.env" }}
{{- range $key, $val := (include "truefoundry-frontend-app.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.truefoundryFrontendApp.envSecretName }}
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
  Merge default nodeSelector with nodeSelector specified in truefoundry-frontend-app nodeSelector
  Priority: default > component > global (defaults cannot be overwritten)
  */}}
{{- define "truefoundry-frontend-app.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $temp := mergeOverwrite (deepCopy .Values.global.nodeSelector) (deepCopy .Values.truefoundryFrontendApp.nodeSelector) }}
{{- $mergedNodeSelector := mergeOverwrite (deepCopy $temp) (deepCopy $defaultNodeSelector) }}
{{- toYaml $mergedNodeSelector }}
{{- end }}

{{/*
Resource Tier
*/}}
{{- define "truefoundry-frontend-app.resourceTier" }}
{{- $tier := .Values.truefoundryFrontendApp.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "truefoundry-frontend-app.replicas" }}
{{- $tier := include "truefoundry-frontend-app.resourceTier" . }}
{{- if .Values.truefoundryFrontendApp.replicaCount -}}
{{ .Values.truefoundryFrontendApp.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "truefoundry-frontend-app.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "truefoundry-frontend-app.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 400Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 800Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "truefoundry-frontend-app.defaultResources.large" }}
requests:
  cpu: 300m
  memory: 800Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 600m
  memory: 1600Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "truefoundry-frontend-app.resources" }}
{{- $tier := include "truefoundry-frontend-app.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "truefoundry-frontend-app.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "truefoundry-frontend-app.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "truefoundry-frontend-app.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.truefoundryFrontendApp.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "truefoundry-frontend-app.imagePullSecrets" -}}
{{- if .Values.truefoundryFrontendApp.imagePullSecrets -}}
{{- toYaml .Values.truefoundryFrontendApp.imagePullSecrets | nindent 2 }}
{{- else }}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}