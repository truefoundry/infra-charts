{{/*
  Global Labels
*/}}
{{- define "global-labels" }}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Global Annotations
*/}}
{{- define "global-annotations" }}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Service Account Annotations
  */}}
{{- define "global-serviceAccountAnnotations" -}}
{{- if .Values.global.serviceAccount.annotations }}
{{ toYaml .Values.global.serviceAccount.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}
