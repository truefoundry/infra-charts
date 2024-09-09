{{/*
  Merge default nodeSelector with nodeSelector specified in truefoundryBootstrap nodeSelector
  */}}
{{- define "truefoundry-bootstrap.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge $defaultNodeSelector .Values.truefoundryBootstrap.nodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
