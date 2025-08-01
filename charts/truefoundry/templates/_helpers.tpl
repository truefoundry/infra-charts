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

{{/*
  Image Pull Secrets
  Only include image pull secrets if:
  1. existingTruefoundryImagePullSecretName is provided, OR
  2. truefoundryImagePullConfigJSON is provided (which will create the secret)
*/}}
{{- define "global.imagePullSecrets" -}}
{{- if .Values.global.existingTruefoundryImagePullSecretName }}
  - name: {{ .Values.global.existingTruefoundryImagePullSecretName }}
{{- else if .Values.global.truefoundryImagePullConfigJSON }}
  - name: truefoundry-image-pull-secret
{{- end }}
{{- end }}
