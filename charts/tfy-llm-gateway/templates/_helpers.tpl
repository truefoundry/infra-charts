{{/*
Expand the name of the chart.
*/}}
{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}


{{- define "tfy-llm-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-llm-gateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "tfy-llm-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
 Base labels
  */}}
{{- define "tfy-llm-gateway.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-llm-gateway.commonLabels" -}}
{{- $baseLabels := include "tfy-llm-gateway.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-llm-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-llm-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Pod labels
  */}}
{{- define "tfy-llm-gateway.podLabels" -}}
{{- $selectorLabels := include "tfy-llm-gateway.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}


{{/*
  Ingress labels
  */}}
{{- define "tfy-llm-gateway.ingressLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $ingressLabels := mergeOverwrite $commonLabels .Values.ingress.labels }}
{{- toYaml $ingressLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-llm-gateway.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-llm-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end }}
{{- end }}

{{/*
  VirtualService Labels
*/}}
{{- define "tfy-llm-gateway.virtualserviceLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $virtualServiceLabels := mergeOverwrite $commonLabels .Values.istio.virtualservice.labels }}
{{- toYaml $virtualServiceLabels }}
{{- end }}

{{/*
  VirtualService annotations
  */}}
{{- define "tfy-llm-gateway.virtualserviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite $commonAnnotations .Values.istio.virtualservice.annotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-llm-gateway.deploymentLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-llm-gateway.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceMonitorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.serviceMonitor.additionalLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.serviceMonitor.additionalAnnotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-llm-gateway.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-llm-gateway.env" }}
{{- range $key, $val := (include "tfy-llm-gateway.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.envSecretName }}
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
{{- if .Values.global.redisEnabled }}
- name: REDIS_HOST
  value: {{ printf "redis-master.%s.svc.cluster.local" (include "global.namespace" .) | quote }}
{{- end }}
{{- end }}

{{/*
Ingress Annotations
*/}}
{{- define "tfy-llm-gateway.ingressAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $ingressAnnotations := mergeOverwrite $commonAnnotations .Values.ingress.annotations }}
{{- toYaml $ingressAnnotations }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-llm-gateway.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  PDB Annotations - merges commonAnnotations with pdb-specific annotations
*/}}
{{- define "tfy-llm-gateway.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.podDisruptionBudget.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end }}

{{/*
  PDB Labels - merges commonLabels with pdb-specific labels
*/}}
{{- define "tfy-llm-gateway.pdbLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.podDisruptionBudget.labels }}
{{- toYaml $pdbLabels }}
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.medium" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-llm-gateway.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.large" . }}
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

{{- define "tfy-llm-gateway.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
10
{{- end }}
{{- end }}

{{/*
Affinity for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{- toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.tolerations" -}}
{{- if .Values.tolerations -}}
{{- toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{- toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end }}

{{- define "tfy-llm-gateway.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}