{{/*
Expand the name of the chart.
*/}}
{{- define "deltafusion-ingestor.name" -}}
{{- default "tfy-deltafusion-ingestor" .Values.tfyDeltaFusionIngestor.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "deltafusion-ingestor.fullname" -}}
{{- if .Values.tfyDeltaFusionIngestor.fullnameOverride }}
{{- .Values.tfyDeltaFusionIngestor.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-deltafusion-ingestor" .Values.tfyDeltaFusionIngestor.nameOverride }}
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
{{- define "deltafusion-ingestor.annotations" -}}
{{- if .Values.tfyDeltaFusionIngestor.annotations }}
{{ toYaml .Values.tfyDeltaFusionIngestor.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Pod Labels
*/}}
{{- define "deltafusion-ingestor.podLabels" -}}
{{ include "deltafusion-ingestor.selectorLabels" . }}
{{- if .Values.tfyDeltaFusionIngestor.image.tag }}
app.kubernetes.io/version: {{ .Values.tfyDeltaFusionIngestor.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.tfyDeltaFusionIngestor.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deltafusion-ingestor.labels" -}}
{{- include "deltafusion-ingestor.podLabels" . }}
helm.sh/chart: {{ include "deltafusion-ingestor.chart" . }}
{{- if .Values.tfyDeltaFusionIngestor.commonLabels }}
{{ toYaml .Values.tfyDeltaFusionIngestor.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deltafusion-ingestor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deltafusion-ingestor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "deltafusion-ingestor.serviceAccountName" -}}
{{- if .Values.tfyDeltaFusionIngestor.serviceAccount.create }}
{{- .Values.tfyDeltaFusionIngestor.serviceAccount.name }}
{{- else }}
{{- .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceAccount annotations
*/}}
{{- define "deltafusion-ingestor.serviceAccountAnnotations" -}}
{{- if .Values.tfyDeltaFusionIngestor.serviceAccount.annotations }}
{{ toYaml .Values.tfyDeltaFusionIngestor.serviceAccount.annotations }}
{{- else if .Values.tfyDeltaFusionIngestor.annotations }}
{{ toYaml .Values.tfyDeltaFusionIngestor.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
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
{{ .Values.tfyDeltaFusionIngestor.replicaCount }}
{{- else if eq $tier "small" -}}
2
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
2
{{- end }}
{{- end }}

{{- define "deltafusion-ingestor.storageSize" }}
{{- if .Values.tfyDeltaFusionIngestor.storage.size -}}
{{ .Values.tfyDeltaFusionIngestor.storage.size }}
{{- else -}}
50Gi
{{- end }}
{{- end }}

{{/*
NodeSelector merge logic
*/}}
{{- define "deltafusion-ingestor.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- if .Values.nodeSelector -}}
{{- $mergedNodeSelector := merge .Values.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else if .Values.global.nodeSelector -}}
{{- $mergedNodeSelector := merge .Values.global.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- else -}}
{{- $mergedNodeSelector := $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
{{- end }}

{{/*
Affinity for the deltafusion-ingestor service
*/}}
{{- define "deltafusion-ingestor.affinity" -}}
{{- if .Values.tfyDeltaFusionIngestor.affinity -}}
{{ toYaml .Values.tfyDeltaFusionIngestor.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for the deltafusion-ingestor service
*/}}
{{- define "deltafusion-ingestor.tolerations" -}}
{{- if .Values.tolerations }}
{{ toYaml .Values.tolerations }}
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
SPANS_DATASET_PATH: {{ .Values.tfyDeltaFusionIngestor.storage.mountPath }}
PORT: "{{ .Values.tfyDeltaFusionIngestor.service.port }}"
{{ tpl (.Values.tfyDeltaFusionIngestor.env | toYaml) . }}
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
      name: {{ $.Values.tfyDeltaFusionIngestor.envSecretName }}
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
{{- if .Values.tfyDeltaFusionIngestor.extraVolumes }}
  {{- range .Values.tfyDeltaFusionIngestor.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- $volumes | toYaml -}}
{{- end -}}


{{- define "deltafusion-ingestor.volumeMounts" -}}
- name: data
  mountPath: {{ .Values.tfyDeltaFusionIngestor.storage.mountPath }}
{{- with .Values.tfyDeltaFusionIngestor.extraVolumeMounts }}
{{- toYaml . | nindent 0 }}
{{- end -}}
{{- end -}}
