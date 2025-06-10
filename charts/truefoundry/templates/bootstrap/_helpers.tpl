{{/*
  bootstrap annotation
*/}}
{{- define "bootstrap-annotations" -}}
helm.sh/hook: "pre-install,pre-upgrade"
helm.sh/hook-weight: "{{ .hookWeight | default "-5" }}"
helm.sh/hook-delete-policy: "before-hook-creation"
argocd.argoproj.io/hook: "PreSync"
argocd.argoproj.io/sync-wave: "{{ .syncWave | default "-5" }}"
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
{{ toYaml .Values.truefoundryBootstrap.labels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- else }}
{}
{{- end -}}
{{- end -}}

{{/*
  bootstrap resources
*/}}
{{- define "bootstrap.resources" -}}
{{- $resources := .Values.truefoundryBootstrap.resources -}}
{{- if $resources }}
{{- toYaml $resources }}
{{- else }}
limits:
  cpu: 500m
  memory: 512Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end -}}
{{- end -}}
