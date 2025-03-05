{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-grafana.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels
*/}}
{{- define "tfy-grafana.labels" -}}
helm.sh/chart: {{ include "tfy-grafana.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "tfy-grafana.annotations" -}}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}