{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-distributor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
tfy-distributor common labels
*/}}
{{- define "tfy-distributor.labels" -}}
helm.sh/chart: {{ include "tfy-distributor.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.distributor.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
tfy-distributor common Annotations
*/}}
{{- define "tfy-distributor.annotations" -}}
{{- with .Values.distributor.annotations }}
{{ toYaml . | nindent 4 }}
{{- end }}
{{- end }}


{{/*
nats common labels
*/}}
{{- define "nats.labels" -}}
{{- include "tfy-distributor.labels" . | nindent 4 }}
{{- with .Values.nats.labels }}
{{ toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
nats common Annotations
*/}}
{{- define "nats.annotations" -}}
{{- include "tfy-distributor.annotations" . | nindent 4 }}
{{- with .Values.nats.annotations }}
{{ toYaml . | nindent 4 }}
{{- end }}
{{- end }}

