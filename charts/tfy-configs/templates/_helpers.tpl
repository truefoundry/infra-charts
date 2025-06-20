{{/*
Common annotations for tfy-configs resources
*/}}
{{- define "tfy-configs.annotations" -}}
helm.sh/hook: "pre-install,pre-upgrade"
helm.sh/hook-weight: "1"
helm.sh/hook-delete-policy: "before-hook-creation"
argocd.argoproj.io/hook: "PreSync"
argocd.argoproj.io/sync-wave: "1"
argocd.argoproj.io/hook-delete-policy: "BeforeHookCreation"
{{- if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- end }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}

{{- end }}
