{{/*
Expand the name of the chart.
*/}}
{{- define "spark-history-server.name" -}}
{{- default "spark-history-server" .Values.sparkHistoryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "spark-history-server.fullname" -}}
{{- if .Values.sparkHistoryServer.fullnameOverride }}
{{- .Values.sparkHistoryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "spark-history-server" .Values.sparkHistoryServer.nameOverride }}
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
{{- define "spark-history-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "spark-history-server.podLabels" -}}
{{ include "spark-history-server.selectorLabels" . }}
{{- if .Values.sparkHistoryServer.image.tag }}
app.kubernetes.io/version: {{ .Values.sparkHistoryServer.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.sparkHistoryServer.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "spark-history-server.labels" -}}
{{- include "spark-history-server.podLabels" . }}
helm.sh/chart: {{ include "spark-history-server.chart" . }}
{{- if .Values.sparkHistoryServer.commonLabels }}
{{ toYaml .Values.sparkHistoryServer.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "spark-history-server.annotations" -}}
{{- if .Values.sparkHistoryServer.annotations }}
{{ toYaml .Values.sparkHistoryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "spark-history-server.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "3") (include "spark-history-server.annotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "spark-history-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spark-history-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "spark-history-server.serviceAccountName" -}}
{{- if .Values.sparkHistoryServer.serviceAccount.create }}
{{- .Values.sparkHistoryServer.serviceAccount.name }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}
{{/*
  Service Account Annotations
  */}}
{{- define "spark-history-server.serviceAccountAnnotations" -}}
{{- if .Values.sparkHistoryServer.serviceAccount.annotations }}
{{ toYaml .Values.sparkHistoryServer.serviceAccount.annotations }}
{{- else if .Values.sparkHistoryServer.annotations }}
{{ toYaml .Values.sparkHistoryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "spark-history-server.parseEnv" -}}
{{ tpl (.Values.sparkHistoryServer.env | toYaml) . }}
{{- end }}


{{/*
  Create the env file
  */}}
{{- define "spark-history-server.env" }}
{{- range $key, $val := (include "spark-history-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.sparkHistoryServer.envSecretName }}
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

{{- define "spark-history-server.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.sparkHistoryServer.extraVolumes }}
  {{- range .Values.sparkHistoryServer.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "spark-history-server.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.sparkHistoryServer.extraVolumeMounts }}
  {{- range .Values.sparkHistoryServer.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{- define "spark-history-server.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.sparkHistoryServer.replicaCount }}
{{ .Values.sparkHistoryServer.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{- define "spark-history-server.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 6144Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 7168Mi
{{- end }}

{{- define "spark-history-server.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 8192Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 9216Mi
{{- end }}
{{- define "spark-history-server.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 10240Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 11264Mi
{{- end }}

{{- define "spark-history-server.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "spark-history-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.sparkHistoryServer.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}