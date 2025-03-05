{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-inferentia-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels for device plugin
*/}}
{{- define "neuron-device-plugin.labels" -}}
helm.sh/chart: {{ include "tfy-inferentia-operator.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.devicePlugin.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations for device plugin
*/}}
{{- define "neuron-device-plugin.annotations" -}}
{{- if .Values.devicePlugin.annotations }}
  {{- toYaml .Values.devicePlugin.annotations | nindent 4 }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Labels for neuron scheduler
*/}}
{{- define "neuron-scheduler.labels" -}}
helm.sh/chart: {{ include "tfy-inferentia-operator.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.scheduler.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations for neuron scheduler
*/}}
{{- define "neuron-scheduler.annotations" -}}
{{- if .Values.scheduler.annotations }}
  {{- toYaml .Values.scheduler.annotations | nindent 4 }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Labels for neuron scheduler extension
*/}}
{{- define "neuron-scheduler-extension.labels" -}}
helm.sh/chart: {{ include "tfy-inferentia-operator.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.scheduler.extension.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations for neuron scheduler extension
*/}}
{{- define "neuron-scheduler-extension.annotations" -}}
{{- if .Values.scheduler.extension.annotations }}
  {{- toYaml .Values.scheduler.extension.annotations | nindent 4 }}
{{- else }}
{}
{{- end }}
{{- end }}