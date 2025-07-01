{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-workflow-admin.name" -}}
{{- default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-workflow-admin.fullname" -}}
{{- if .Values.tfyWorkflowAdmin.fullnameOverride }}
{{- .Values.tfyWorkflowAdmin.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-workflow-admin" .Values.tfyWorkflowAdmin.nameOverride }}
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
{{- define "tfy-workflow-admin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "tfy-workflow-admin.podLabels" -}}
{{ include "tfy-workflow-admin.selectorLabels" . }}
{{- if .Values.tfyWorkflowAdmin.image.tag }}
app.kubernetes.io/version: {{ .Values.tfyWorkflowAdmin.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- range $name, $value := .Values.tfyWorkflowAdmin.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}

{{/*
  Server Pod Labels
  */}}
{{- define "tfy-workflow-admin.server.podLabels" -}}
{{ include "tfy-workflow-admin.podLabels" . }}
app.kubernetes.io/workflow-component: server
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-workflow-admin.labels" -}}
helm.sh/chart: {{ include "tfy-workflow-admin.chart" . }}
{{ include "tfy-workflow-admin.podLabels" . }}
{{- if .Values.tfyWorkflowAdmin.commonLabels }}
{{ toYaml .Values.tfyWorkflowAdmin.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Scheduler Pod Labels
  */}}
{{- define "tfy-workflow-admin.scheduler.podLabels" -}}
{{- include "tfy-workflow-admin.podLabels" . }}
app.kubernetes.io/workflow-component: scheduler
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "tfy-workflow-admin.annotations" -}}
{{- if .Values.tfyWorkflowAdmin.annotations }}
{{ toYaml .Values.tfyWorkflowAdmin.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-workflow-admin.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "2") (include "tfy-workflow-admin.annotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  ConfigMap annotations
  */}}
{{- define "tfy-workflow-admin.configMap.annotations" -}}
{{- if .Values.tfyWorkflowAdmin.annotations }}
{{ toYaml .Values.tfyWorkflowAdmin.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- end }}
argocd.argoproj.io/sync-options: PruneLast=true
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "tfy-workflow-admin.serviceAccountAnnotations" -}}
{{- if .Values.tfyWorkflowAdmin.serviceAccount.annotations }}
{{ toYaml .Values.tfyWorkflowAdmin.serviceAccount.annotations }}
{{- else if .Values.tfyWorkflowAdmin.annotations }}
{{ toYaml .Values.tfyWorkflowAdmin.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-workflow-admin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-workflow-admin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Server selector labels
  */}}
{{- define "tfy-workflow-admin.server.selectorLabels" -}}
{{- include "tfy-workflow-admin.selectorLabels" . }}
app.kubernetes.io/workflow-component: server
{{- end }}

{{/*
  Scheduler selector labels
  */}}
{{- define "tfy-workflow-admin.scheduler.selectorLabels" -}}
{{- include "tfy-workflow-admin.selectorLabels" . }}
app.kubernetes.io/workflow-component: scheduler
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-workflow-admin.serviceAccountName" -}}
{{- default (include "tfy-workflow-admin.fullname" .) "tfy-workflow-admin"}}

{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-workflow-admin.parseEnv" -}}
{{ tpl (.Values.tfyWorkflowAdmin.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-workflow-admin.env" }}
{{- range $key, $val := (include "tfy-workflow-admin.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyWorkflowAdmin.envSecretName }}
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

{{- define "tfy-workflow-admin-server.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyWorkflowAdmin.replicaCount -}}
{{ .Values.tfyWorkflowAdmin.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{- define "tfy-workflow-admin-scheduler.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyWorkflowAdmin.replicaCount -}}
{{ .Values.tfyWorkflowAdmin.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
1
{{- else if eq $tier "large" -}}
1
{{- end }}
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-scheduler.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 512Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-workflow-admin-server.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyWorkflowAdmin.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged | indent 8 }}
{{- end }}

{{- define "tfy-workflow-admin-scheduler.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-workflow-admin-scheduler.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyWorkflowAdmin.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged | indent 8 }}
{{- end }}