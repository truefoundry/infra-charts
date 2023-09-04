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