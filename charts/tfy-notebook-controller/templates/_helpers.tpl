{{- define "notebook-controller.selectorLabels" -}}
app.kubernetes.io/name: notebook-controller
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "sds-server.selectorLabels" -}}
app.kubernetes.io/name: sds-server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }} 