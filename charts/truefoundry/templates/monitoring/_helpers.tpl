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
