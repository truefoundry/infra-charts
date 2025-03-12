{{/*
  bootstrap annotation
*/}}
{{- define "bootstrap-annotations" -}}
helm.sh/hook: "pre-install,pre-upgrade"
helm.sh/hook-weight: "{{ .hookWeight }}"
helm.sh/hook-delete-policy: "before-hook-creation"
argocd.argoproj.io/hook: "PreSync"
argocd.argoproj.io/sync-wave: "{{ .syncWave }}"
argocd.argoproj.io/hook-delete-policy: "BeforeHookCreation"
{{- if .annotations }}
{{ toYaml .annotations | nindent 2 }}
{{- else if .globalAnnotations }}
{{ toYaml .globalAnnotations | nindent 2 }}
{{- end }}
{{- end }}

{{/*
  bootstrap labels
*/}}
{{- define "bootstrap-labels" -}}
{{- if .Values.truefoundryBootstrap.labels }}
{{ toYaml .Values.truefoundryBootstrap.labels | nindent 2 }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels | nindent 2 }}
{{- else }}
{}
{{- end -}}
{{- end -}}