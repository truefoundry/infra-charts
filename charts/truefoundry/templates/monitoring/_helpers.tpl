{{/*
  Base labels for monitoring resources
*/}}
{{- define "monitoring.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "monitoring") }}
{{- end }}

{{/*
  Common labels for monitoring resources - merges global labels with monitoring-specific labels
  Priority: MonitoringLabels > GlobalLabels
*/}}
{{- define "monitoring.commonLabels" -}}
{{- $baseLabels := include "monitoring.labels" . | fromYaml }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.monitoring.commonLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations for monitoring resources - merges global annotations with monitoring-specific annotations
  Priority: MonitoringAnnotations > GlobalAnnotations
*/}}
{{- define "monitoring.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.monitoring.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Secret labels for monitoring - merges common labels with secret-specific labels
  Priority: SecretLabels > CommonLabels > GlobalLabels
*/}}
{{- define "monitoring.secretLabels" -}}
{{- $commonLabels := include "monitoring.commonLabels" . | fromYaml }}
{{- $secretLabels := mergeOverwrite $commonLabels .Values.monitoring.alertManager.secret.labels }}
{{- toYaml $secretLabels }}
{{- end }}

{{/*
  Secret annotations for monitoring - merges common annotations with secret-specific annotations
  Priority: SecretAnnotations > CommonAnnotations > GlobalAnnotations
*/}}
{{- define "monitoring.secretAnnotations" -}}
{{- $commonAnnotations := include "monitoring.commonAnnotations" . | fromYaml }}
{{- $secretAnnotations := mergeOverwrite $commonAnnotations .Values.monitoring.alertManager.secret.annotations }}
{{- toYaml $secretAnnotations }}
{{- end }}

{{/*
  Alert Rules labels for monitoring - merges common labels with alert rules-specific labels
  Priority: AlertRulesLabels > CommonLabels > GlobalLabels
*/}}
{{- define "monitoring.alertRulesLabels" -}}
{{- $commonLabels := include "monitoring.commonLabels" . | fromYaml }}
{{- $alertRulesLabels := mergeOverwrite $commonLabels .Values.monitoring.alertRules.labels }}
{{- toYaml $alertRulesLabels }}
{{- end }}

{{/*
  Alert Rules annotations for monitoring - merges common annotations with alert rules-specific annotations
  Priority: AlertRulesAnnotations > CommonAnnotations > GlobalAnnotations
*/}}
{{- define "monitoring.alertRulesAnnotations" -}}
{{- $commonAnnotations := include "monitoring.commonAnnotations" . | fromYaml }}
{{- $alertRulesAnnotations := mergeOverwrite $commonAnnotations .Values.monitoring.alertRules.annotations }}
{{- toYaml $alertRulesAnnotations }}
{{- end }}

{{/*
  Alert Manager labels for monitoring - merges common labels with alert manager-specific labels
  Priority: AlertManagerLabels > CommonLabels > GlobalLabels
*/}}
{{- define "monitoring.alertManagerLabels" -}}
{{- $commonLabels := include "monitoring.commonLabels" . | fromYaml }}
{{- $alertManagerLabels := mergeOverwrite $commonLabels .Values.monitoring.alertManager.labels }}
{{- toYaml $alertManagerLabels }}
{{- end }}

{{/*
  Alert Manager annotations for monitoring - merges common annotations with alert manager-specific annotations
  Priority: AlertManagerAnnotations > CommonAnnotations > GlobalAnnotations
*/}}
{{- define "monitoring.alertManagerAnnotations" -}}
{{- $commonAnnotations := include "monitoring.commonAnnotations" . | fromYaml }}
{{- $alertManagerAnnotations := mergeOverwrite $commonAnnotations .Values.monitoring.alertManager.annotations }}
{{- toYaml $alertManagerAnnotations }}
{{- end }}

{{/*
  TfyNats labels for monitoring - merges common labels with tfyNats-specific labels
  Priority: TfyNatsLabels > CommonLabels > GlobalLabels
*/}}
{{- define "monitoring.tfyNatsLabels" -}}
{{- $commonLabels := include "monitoring.commonLabels" . | fromYaml }}
{{- $tfyNatsLabels := dict "app.kubernetes.io/component" "nats" "app.kubernetes.io/name" "tfy-nats" "release" "prometheus" }}
{{- $mergedLabels := mergeOverwrite $commonLabels $tfyNatsLabels }}
{{- if and .Values.monitoring.tfyNats (hasKey .Values.monitoring.tfyNats "labels") .Values.monitoring.tfyNats.labels }}
{{- $mergedLabels = mergeOverwrite $mergedLabels .Values.monitoring.tfyNats.labels }}
{{- end }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  TfyNats selector labels for monitoring
*/}}
{{- define "monitoring.tfyNatsSelectorLabels" -}}
app.kubernetes.io/component: nats
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: tfy-nats
{{- end }}

{{/*
  TfyNats annotations for monitoring - merges common annotations with tfyNats-specific annotations
  Priority: TfyNatsAnnotations > CommonAnnotations > GlobalAnnotations
*/}}
{{- define "monitoring.tfyNatsAnnotations" -}}
{{- $commonAnnotations := include "monitoring.commonAnnotations" . | fromYaml }}
{{- if and .Values.monitoring.tfyNats (hasKey .Values.monitoring.tfyNats "annotations") .Values.monitoring.tfyNats.annotations }}
{{- $commonAnnotations = mergeOverwrite $commonAnnotations .Values.monitoring.tfyNats.annotations }}
{{- end }}
{{- toYaml $commonAnnotations }}
{{- end }}
