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
Common Annotations
*/}}
{{- define "deltafusion-ingestor.inputCommonAnnotations" -}}
{{- if .Values.deltaFusionIngestor.commonAnnotations }}
{{ toYaml .Values.deltaFusionIngestor.commonAnnotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- end }}
{{- end }}

{{- define "deltafusion-ingestor.commonAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "1") (include "deltafusion-ingestor.inputCommonAnnotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}


{{/*
Pod Annotations
*/}}
{{- define "deltafusion-ingestor.podAnnotations" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonAnnotations" . | fromYaml) (.Values.deltaFusionIngestor.podAnnotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
ServiceAccount annotations
*/}}
{{- define "deltafusion-ingestor.serviceAccountAnnotations" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonAnnotations" . | fromYaml) (.Values.deltaFusionIngestor.serviceAccount.annotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Service Annotations
*/}}
{{- define "deltafusion-ingestor.serviceAnnotations" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonAnnotations" . | fromYaml) (.Values.deltaFusionIngestor.service.annotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Statefulset Annotations
*/}}
{{- define "deltafusion-ingestor.statefulsetAnnotations" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonAnnotations" . | fromYaml) (.Values.deltaFusionIngestor.statefulsetAnnotations) }}
{{- toYaml $merged }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deltafusion-ingestor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deltafusion-ingestor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deltafusion-ingestor.commonLabels" -}}
helm.sh/chart: {{ include "deltafusion-ingestor.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.deltaFusionIngestor.image.tag | quote }}
{{- if .Values.deltaFusionIngestor.commonLabels }}
{{ toYaml .Values.deltaFusionIngestor.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
Pod Labels
*/}}
{{- define "deltafusion-ingestor.podLabels" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonLabels" . | fromYaml) (.Values.deltaFusionIngestor.podLabels) }}
{{- $merged = merge $merged (include "deltafusion-ingestor.selectorLabels" . | fromYaml) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Service Labels
*/}}
{{- define "deltafusion-ingestor.serviceLabels" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonLabels" . | fromYaml) (.Values.deltaFusionIngestor.service.labels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
ServiceAccount Labels
*/}}
{{- define "deltafusion-ingestor.serviceAccountLabels" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonLabels" . | fromYaml) (.Values.deltaFusionIngestor.serviceAccount.labels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Statefulset Labels
*/}}
{{- define "deltafusion-ingestor.statefulsetLabels" -}}
{{- $merged := merge (include "deltafusion-ingestor.commonLabels" . | fromYaml) (.Values.deltaFusionIngestor.statefulsetLabels) }}
{{ toYaml $merged }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deltafusion-ingestor.serviceAccountName" -}}
{{- if .Values.deltaFusionIngestor.serviceAccount.create }}
{{- .Values.deltaFusionIngestor.serviceAccount.name }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "deltafusion-ingestor.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

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
{{- $overrides := .Values.resources | default dict }}
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
{{- $tier := .Values.global.resourceTier | default "medium" }}
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
SPANS_DATASET_PATH: {{ .Values.deltaFusionIngestor.storage.mountPath }}
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
