{{- define "tfy-cloudflared.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-cloudflared.fullname" -}}
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

{{- define "tfy-cloudflared.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-cloudflared.labels" -}}
helm.sh/chart: {{ include "tfy-cloudflared.chart" . }}
{{ include "tfy-cloudflared.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "tfy-cloudflared.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-cloudflared.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-cloudflared.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-cloudflared.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "tfy-cloudflared.image" -}}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) -}}
{{- end -}}

{{/* Tunnel token secret name */}}
{{- define "tfy-cloudflared.tunnelSecretName" -}}
{{- if .Values.tunnel.existingSecret -}}
{{- .Values.tunnel.existingSecret -}}
{{- else -}}
{{- printf "%s-tunnel" (include "tfy-cloudflared.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Tunnel token secret key */}}
{{- define "tfy-cloudflared.tunnelSecretKey" -}}
{{- .Values.tunnel.existingSecretKey | default "token" -}}
{{- end -}}
