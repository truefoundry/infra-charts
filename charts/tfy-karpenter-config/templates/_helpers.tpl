{{/*
Control plane labels
*/}}
{{- define "controlPlaneProvisioner.labels" -}}
{{- $labels := .Values.karpenter.controlPlaneProvisioner.labels -}}
class.truefoundry.io/component: control-plane
{{- with $labels }}
{{- range $key, $value := $labels }}
{{ printf "%s: %s" $key $value }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Control plane taints
*/}}
{{- define "controlPlaneProvisioner.taints" -}}
{{- $taints := .Values.karpenter.controlPlaneProvisioner.taints -}}
- effect: NoSchedule
  key: class.truefoundry.io/control-plane
{{- with $taints }}
{{- range $taint := $taints }}
- effect: {{ $taint.effect | quote }}
  key: {{ $taint.key | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "defaultNodeTemplate.inferredAmiFamily" -}}
  {{- $inferredAmiFamily := "" -}}
  {{- if .Values.karpenter.defaultNodeTemplate.amiFamily -}}
    {{- $inferredAmiFamily = .Values.karpenter.defaultNodeTemplate.amiFamily -}}
  {{- else -}}
    {{- range .Values.karpenter.defaultNodeTemplate.amiSelectorTerms -}}
      {{- if hasKey . "alias" -}}
        {{- $amiFamily := split "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily._0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}

{{- define "gpuDefaultNodeTemplate.inferredAmiFamily" -}}
  {{- $inferredAmiFamily := "" -}}
  {{- if .Values.karpenter.gpuDefaultNodeTemplate.amiFamily -}}
    {{- $inferredAmiFamily = .Values.karpenter.gpuDefaultNodeTemplate.amiFamily -}}
  {{- else -}}
    {{- range .Values.karpenter.gpuDefaultNodeTemplate.amiSelectorTerms -}}
      {{- if hasKey . "alias" -}}
        {{- $amiFamily := split "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily._0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}

{{- define "controlPlaneNodeTemplate.inferredAmiFamily" -}}
  {{- $inferredAmiFamily := "" -}}
  {{- if .Values.karpenter.controlPlaneNodeTemplate.amiFamily -}}
    {{- $inferredAmiFamily = .Values.karpenter.controlPlaneNodeTemplate.amiFamily -}}
  {{- else -}}
    {{- range .Values.karpenter.controlPlaneNodeTemplate.amiSelectorTerms -}}
      {{- if hasKey . "alias" -}}
        {{- $amiFamily := split "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily._0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}

{{- define "inferentiaDefaultNodeTemplate.inferredAmiFamily" -}}
  {{- $inferredAmiFamily := "" -}}
  {{- if .Values.karpenter.inferentiaDefaultNodeTemplate.amiFamily -}}
    {{- $inferredAmiFamily = .Values.karpenter.inferentiaDefaultNodeTemplate.amiFamily -}}
  {{- else -}}
    {{- range .Values.karpenter.inferentiaDefaultNodeTemplate.amiSelectorTerms -}}
      {{- if hasKey . "alias" -}}
        {{- $amiFamily := split "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily._0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}

{{- define "criticalNodeClass.inferredAmiFamily" -}}
  {{- $inferredAmiFamily := "" -}}
  {{- if .Values.karpenter.critical.nodeclass.amiFamily -}}
    {{- $inferredAmiFamily = .Values.karpenter.critical.nodeclass.amiFamily -}}
  {{- else -}}
    {{- range .Values.karpenter.critical.nodeclass.amiSelectorTerms -}}
      {{- if hasKey . "alias" -}}
        {{- $amiFamily := split "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily._0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}
