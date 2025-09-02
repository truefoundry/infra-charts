{{/* vim: set filetype=mustache: */}}
{{/*
  Global Labels
*/}}
{{- define "global.labels" }}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Global Annotations
*/}}
{{- define "global.annotations" }}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Service Account Annotations
  */}}
{{- define "global.serviceAccountAnnotations" -}}
{{- if .Values.global.serviceAccount.annotations }}
{{ toYaml .Values.global.serviceAccount.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Image Pull Secrets
  Only include image pull secrets if:
  1. existingTruefoundryImagePullSecretName is provided, OR
  2. truefoundryImagePullConfigJSON is provided (which will create the secret)
*/}}
{{- define "global.imagePullSecrets" -}}
{{- if .Values.global.existingTruefoundryImagePullSecretName }}
  - name: {{ .Values.global.existingTruefoundryImagePullSecretName }}
{{- else if .Values.global.truefoundryImagePullConfigJSON }}
  - name: truefoundry-image-pull-secret
{{- end }}
{{- end }}
{{/*
Expand the name of the chart.
*/}}
{{- define "truefoundry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "truefoundry.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "truefoundry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Argo CD app version
*/}}
{{- define "truefoundry.defaultTag" -}}
{{- .Chart.AppVersion }}
{{- end -}}

{{/*
Return valid version label
*/}}
{{- define "truefoundry.versionLabelValue" -}}
{{ regexReplaceAll "[^-A-Za-z0-9_.]" (include "truefoundry.defaultTag" .) "-" | trunc 63 | trimAll "-" | trimAll "_" | trimAll "." | quote }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "truefoundry.labels" -}}
helm.sh/chart: {{ include "truefoundry.chart" .context }}
{{ include "truefoundry.selectorLabels" (dict "context" .context "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: truefoundry
app.kubernetes.io/version: {{ include "truefoundry.versionLabelValue" .context }}
{{- with .context.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "truefoundry.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end }}  
