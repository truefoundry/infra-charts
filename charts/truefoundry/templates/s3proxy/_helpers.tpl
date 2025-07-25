{{/*
Expand the name of the chart.
*/}}
{{- define "s3proxy.name" -}}
{{- default "s3proxy" .Values.s3proxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "s3proxy.fullname" -}}
{{- if .Values.s3proxy.fullnameOverride }}
{{- .Values.s3proxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "s3proxy" .Values.s3proxy.nameOverride }}
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
{{- define "s3proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "s3proxy.podLabels" -}}
{{ include "s3proxy.selectorLabels" . }}
{{- if .Values.s3proxy.image.tag }}
app.kubernetes.io/version: {{ .Values.s3proxy.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.s3proxy.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "s3proxy.labels" -}}
{{- include "s3proxy.podLabels" . }}
helm.sh/chart: {{ include "s3proxy.chart" . }}
{{- if .Values.s3proxy.commonLabels }}
{{ toYaml .Values.s3proxy.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "s3proxy.annotations" -}}
{{- if .Values.s3proxy.annotations }}
{{ toYaml .Values.s3proxy.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "s3proxy.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "3") (include "s3proxy.annotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "s3proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "s3proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "s3proxy.serviceAccountName" -}}
{{- if .Values.s3proxy.serviceAccount.create }}
{{- .Values.s3proxy.serviceAccount.name }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "s3proxy.serviceAccountAnnotations" -}}
{{- if .Values.s3proxy.serviceAccount.annotations }}
{{ toYaml .Values.s3proxy.serviceAccount.annotations }}
{{- else if .Values.s3proxy.annotations }}
{{ toYaml .Values.s3proxy.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "s3proxy.parseEnv" -}}
{{ tpl (.Values.s3proxy.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "s3proxy.env" }}
{{- range $key, $val := (include "s3proxy.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.s3proxy.envSecretName }}
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
  Create the name of the configmap to use
  */}}
{{- define "s3proxy.configmapName" -}}
{{- printf "%s-cm" (include "s3proxy.name" .) }}
{{- end }}

{{- define "s3proxy.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.s3proxy.extraVolumes }}
  {{- range .Values.s3proxy.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes = append $volumes (dict "name" "config-vol" "configMap" (dict "name" (include "s3proxy.configmapName" .))) }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "s3proxy.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.s3proxy.extraVolumeMounts }}
  {{- range .Values.s3proxy.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts = append $volumeMounts (dict "name" "config-vol" "mountPath" "/opt/s3proxy/config.properties" "subPath" "config.properties") }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{- define "s3proxy.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.s3proxy.replicaCount }}
{{ .Values.s3proxy.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{- define "s3proxy.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "s3proxy.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "s3proxy.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "s3proxy.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "s3proxy.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.s3proxy.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}