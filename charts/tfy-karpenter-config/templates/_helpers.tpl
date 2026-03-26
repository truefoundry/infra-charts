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
        {{- $amiFamily := splitList "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily 0 -}}
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
        {{- $amiFamily := splitList "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily 0 -}}
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
        {{- $amiFamily := splitList "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily 0 -}}
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
        {{- $amiFamily := splitList "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily 0 -}}
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
        {{- $amiFamily := splitList "@" .alias -}}
        {{- $inferredAmiFamily = index $amiFamily 0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $inferredAmiFamily -}}
    {{ lower $inferredAmiFamily }}
  {{- else -}}
    al2023
  {{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.nodeClassApiVersion" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
eks.amazonaws.com/v1
{{- else -}}
karpenter.k8s.aws/v1
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.nodeClassKind" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
NodeClass
{{- else -}}
EC2NodeClass
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.nodeClassGroup" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
eks.amazonaws.com
{{- else -}}
karpenter.k8s.aws
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.shouldRenderNodeClass" -}}
{{- $ctx := .context -}}
{{- $name := .name -}}
{{- $existing := lookup (include "tfyKarpenterConfig.nodeClassApiVersion" $ctx) (include "tfyKarpenterConfig.nodeClassKind" $ctx) "" $name -}}
{{- if not $existing -}}
true
{{- else -}}
{{- $metadata := get $existing "metadata" | default dict -}}
{{- $labels := get $metadata "labels" | default dict -}}
{{- $annotations := get $metadata "annotations" | default dict -}}
{{- if and (eq (get $labels "app.kubernetes.io/managed-by") "Helm") (eq (get $annotations "meta.helm.sh/release-name") $ctx.Release.Name) (eq (get $annotations "meta.helm.sh/release-namespace") $ctx.Release.Namespace) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.shouldRenderNodePool" -}}
{{- $ctx := .context -}}
{{- $name := .name -}}
{{- $existing := lookup "karpenter.sh/v1" "NodePool" "" $name -}}
{{- if not $existing -}}
true
{{- else -}}
{{- $metadata := get $existing "metadata" | default dict -}}
{{- $labels := get $metadata "labels" | default dict -}}
{{- $annotations := get $metadata "annotations" | default dict -}}
{{- if and (eq (get $labels "app.kubernetes.io/managed-by") "Helm") (eq (get $annotations "meta.helm.sh/release-name") $ctx.Release.Name) (eq (get $annotations "meta.helm.sh/release-namespace") $ctx.Release.Namespace) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.instanceFamilyRequirementKey" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
eks.amazonaws.com/instance-category
{{- else -}}
karpenter.k8s.aws/instance-family
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.instanceSizeRequirementKey" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
eks.amazonaws.com/instance-size
{{- else -}}
karpenter.k8s.aws/instance-size
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.instanceGenerationRequirementKey" -}}
{{- if .Values.karpenter.eksAutoMode.enabled -}}
eks.amazonaws.com/instance-generation
{{- else -}}
karpenter.k8s.aws/instance-generation
{{- end -}}
{{- end -}}

{{- define "tfyKarpenterConfig.instanceConstraintValues" -}}
{{- $values := .values -}}
{{- $eksAutoModeEnabled := .eksAutoModeEnabled -}}
{{- $treatAsCategory := .treatAsCategory | default false -}}
{{- $seen := dict -}}
{{- range $values }}
{{- $value := "" -}}
{{- if and $eksAutoModeEnabled (not $treatAsCategory) }}
{{- $value = regexReplaceAll "[0-9].*$" (toString .) "" -}}
{{- else }}
{{- $value = (toString .) -}}
{{- end }}
{{- if and $value (not (hasKey $seen $value)) }}
{{- $_ := set $seen $value true }}
- {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}
