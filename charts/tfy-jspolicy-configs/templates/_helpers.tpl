{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-jspolicy-configs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels
*/}}
{{- define "tfy-jspolicy-configs.labels" -}}
helm.sh/chart: {{ include "tfy-jspolicy-configs.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "tfy-jspolicy-configs.annotations" -}}
{{- if .Values.global.annotations }}
{{ toYaml .Values.global.annotations | nindent 4 }}
{{- else }}
{}
{{- end }}
{{- end }}