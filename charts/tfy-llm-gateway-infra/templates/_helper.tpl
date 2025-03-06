{{/*
Clickhouse labels
*/}}
{{- define "clickhouse.labels" -}}
{{- if .Values.clickhouse.labels }}
{{ toYaml .Values.clickhouse.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Clickhouse annotations
*/}}
{{- define "clickhouse.annotations" -}}
{{- if .Values.clickhouse.annotations }}
{{- toYaml .Values.clickhouse.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- end }}
{{- end }}

{{/*
Clickhouse virtualservice annotations
*/}}
{{- define "clickhouse.virtualservice.annotations" -}}
{{- if .Values.clickhouse.annotations }}
{{- toYaml .Values.clickhouse.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
nats annotations
*/}}
{{- define "nats.annotations" -}}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}