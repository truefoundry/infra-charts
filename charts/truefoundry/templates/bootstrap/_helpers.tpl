{{/*
  Merge default nodeSelector with nodeSelector specified in truefoundryBootstrap nodeSelector
  */}}
{{- define "truefoundry-bootstrap.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge .Values.truefoundryBootstrap.nodeSelector $defaultNodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
