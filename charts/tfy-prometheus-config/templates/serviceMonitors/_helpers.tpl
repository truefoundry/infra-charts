{{- define "argo-workflows.labels" -}}
{{- if .Values.serviceMonitors.workflows.labels }}
{{- toYaml .Values.serviceMonitors.workflows.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "elasti.labels" -}}
{{- if .Values.serviceMonitors.elasti.labels }}
{{- toYaml .Values.serviceMonitors.elasti.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "keda.labels" -}}
{{- if .Values.serviceMonitors.keda.labels }}
{{- toYaml .Values.serviceMonitors.keda.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "kubecost.labels" -}}
{{- if .Values.serviceMonitors.kubecost.labels }}
{{- toYaml .Values.serviceMonitors.kubecost.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "loki.labels" -}}
{{- if .Values.serviceMonitors.loki.labels }}
{{- toYaml .Values.serviceMonitors.loki.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "loki-promtail.labels" -}}
{{- if .Values.serviceMonitors.loki.promtail.labels }}
{{- toYaml .Values.serviceMonitors.loki.promtail.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "prometheus.labels" -}}
{{- if .Values.serviceMonitors.prometheus.labels }}
{{- toYaml .Values.serviceMonitors.prometheus.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "prometheusRules.labels" -}}
{{- if .Values.prometheusRules.containerRules.labels }}
{{- toYaml .Values.prometheusRules.containerRules.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "alert-manager.labels" -}}
{{- if .Values.serviceMonitors.alertManager.labels }}
{{- toYaml .Values.serviceMonitors.alertManager.labels }}
{{- else }}
{{- end }}

{{- define "kubelet.labels" -}}
{{- if .Values.serviceMonitors.kubelet.labels }}
{{- toYaml .Values.serviceMonitors.kubelet.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "nodeExporter.labels" -}}
{{- if .Values.serviceMonitors.nodeExporter.labels }}
{{- toYaml .Values.serviceMonitors.nodeExporter.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- define "stateMetrics.labels" -}}
{{- if .Values.serviceMonitors.stateMetrics.labels }}
{{- toYaml .Values.serviceMonitors.stateMetrics.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}
