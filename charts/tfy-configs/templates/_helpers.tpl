{{/* vim: set filetype=mustache: */}}
{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}