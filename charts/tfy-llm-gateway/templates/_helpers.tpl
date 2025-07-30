{{/*
Expand the name of the chart.
*/}}
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
  Common labels
  */}}
{{- define "tfy-llm-gateway.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Ingress labels
  */}}
{{- define "tfy-llm-gateway.ingress.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
{{- if .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.ingress.labels }}
{{- toYaml .Values.ingress.labels | nindent 4 }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "tfy-llm-gateway.annotations" -}}
{{- if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-llm-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-llm-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-llm-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Annotation
*/}}
{{- define "tfy-llm-gateway.serviceAccount.annotations" -}}
{{- if .Values.serviceAccount.create }}
  {{- toYaml .Values.serviceAccount.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
  {}
{{- end }}
{{- end }}

{{/*
Virtual Service Annotations
*/}}

{{- define "tfy-llm-gateway.virtualservice.annotations" -}}
{{- if .Values.istio.virtualservice.annotations }}
  {{- toYaml .Values.istio.virtualservice.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
  {}
{{- end }}
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
{{- end }}

{{/*
Ingress Annotations
*/}}
{{- define "tfy-llm-gateway.ingress.annotations" -}}
{{- if .Values.ingress.annotations }}
  {{- toYaml .Values.ingress.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Service Annotations
*/}}
{{- define "tfy-llm-gateway.service.annotations" -}}
{{- if .Values.service.annotations }}
  {{- toYaml .Values.service.annotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Pod Annotation Labels
*/}}
{{- define "tfy-llm-gateway.podAnnotations" -}}
{{- if .Values.podAnnotations }}
  {{- toYaml .Values.podAnnotations }}
{{- else if .Values.commonAnnotations }}
  {{- toYaml .Values.commonAnnotations }}
{{- end }}
prometheus.io/scrape: "true"
prometheus.io/port: "8787"
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.medium" }}
requests:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 2048Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 2048Mi
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
{{- if .Values.nodeSelector -}}
{{- toYaml .Values.nodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- toYaml .Values.global.nodeSelector }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Image Pull Secret for tfy-llm-gateway
*/}}
{{/*
  Image Pull Secrets
  Only include image pull secrets if:
  1. existingTruefoundryImagePullSecretName is provided, OR
  2. truefoundryImagePullConfigJSON is provided (which will create the secret)
*/}}
{{- define "global-imagePullSecrets" -}}
{{- if .Values.global.existingTruefoundryImagePullSecretName }}
imagePullSecrets:
  - name: {{ .Values.global.existingTruefoundryImagePullSecretName }}
{{- else if .Values.global.truefoundryImagePullConfigJSON }}
imagePullSecrets:
  - name: truefoundry-image-pull-secret
{{- end }}
{{- end }}