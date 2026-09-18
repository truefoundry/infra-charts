{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-scim-bridge.name" -}}
{{- default "tfy-scim-bridge" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-scim-bridge.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-scim-bridge" .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "tfy-scim-bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-scim-bridge.labels" -}}
helm.sh/chart: {{ include "tfy-scim-bridge.chart" . }}
{{ include "tfy-scim-bridge.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "tfy-scim-bridge.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-scim-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-scim-bridge
{{- end }}

{{- define "tfy-scim-bridge.image" -}}
{{- $repo := required "image.repository is required" .Values.image.repository }}
{{- $tag := required "image.tag is required" .Values.image.tag }}
{{- if .Values.image.registry }}
{{- printf "%s/%s:%s" .Values.image.registry $repo $tag }}
{{- else }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
{{- end }}

{{- define "tfy-scim-bridge.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "tfy-scim-bridge.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-scim-bridge.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "tfy-scim-bridge.secretName" -}}
{{- if .Values.secret.existingName -}}
{{- .Values.secret.existingName -}}
{{- else -}}
{{- include "tfy-scim-bridge.fullname" . -}}
{{- end -}}
{{- end }}

{{- define "tfy-scim-bridge.scimTokenKey" -}}
{{- .Values.secret.scimTokenKey | default "SCIM_TOKEN" -}}
{{- end }}

{{- define "tfy-scim-bridge.googleSaJsonB64Key" -}}
{{- .Values.secret.googleSaJsonB64Key | default "GOOGLE_SA_JSON_B64" -}}
{{- end }}
