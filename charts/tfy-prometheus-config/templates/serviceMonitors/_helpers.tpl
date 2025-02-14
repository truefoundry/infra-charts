{{- /*
  Labels for service monitors
*/ -}}
{{- /*
  Argo workflows service monitor labels
*/ -}}
{{- define "argo-workflows.labels" -}}
{{- if .Values.serviceMonitors.workflows.labels }}
{{- toYaml .Values.serviceMonitors.workflows.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Elasti service monitor labels
*/ -}}
{{- define "elasti.labels" -}}
{{- if .Values.serviceMonitors.elasti.labels }}
{{- toYaml .Values.serviceMonitors.elasti.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Keda service monitor labels
*/ -}}
{{- define "keda.labels" -}}
{{- if .Values.serviceMonitors.keda.labels }}
{{- toYaml .Values.serviceMonitors.keda.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Kubecost service monitor labels
*/ -}}
{{- define "kubecost.labels" -}}
{{- if .Values.serviceMonitors.kubecost.labels }}
{{- toYaml .Values.serviceMonitors.kubecost.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Loki service monitor labels
*/ -}}
{{- define "loki.labels" -}}
{{- if .Values.serviceMonitors.loki.labels }}
{{- toYaml .Values.serviceMonitors.loki.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Loki promtail service monitor labels
*/ -}}
{{- define "loki-promtail.labels" -}}
{{- if .Values.serviceMonitors.loki.promtail.labels }}
{{- toYaml .Values.serviceMonitors.loki.promtail.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Prometheus service monitor labels
*/ -}}
{{- define "prometheus.labels" -}}
{{- if .Values.serviceMonitors.prometheus.labels }}
{{- toYaml .Values.serviceMonitors.prometheus.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Alerting rules labels
*/ -}}
{{- define "alerting-rules.labels" -}}
{{- if .Values.prometheusRules.containerRules.labels }}
{{- toYaml .Values.prometheusRules.containerRules.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Kubecost rules labels
*/ -}}
{{- define "kubecostRules.labels" -}}
{{- if .Values.prometheusRules.kubecostRules.labels }}
{{- toYaml .Values.prometheusRules.kubecostRules.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Container rules labels
*/ -}}
{{- define "containerRules.labels" -}}
{{- if .Values.serviceMonitors.alertManager.labels }}
{{- toYaml .Values.serviceMonitors.alertManager.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Kubelet service monitor labels
*/ -}}
{{- define "kubelet.labels" -}}
{{- if .Values.serviceMonitors.kubelet.labels }}
{{- toYaml .Values.serviceMonitors.kubelet.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Node exporter service monitor labels
*/ -}}
{{- define "nodeExporter.labels" -}}
{{- if .Values.serviceMonitors.nodeExporter.labels }}
{{- toYaml .Values.serviceMonitors.nodeExporter.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{- /*
  Kube state metrics service monitor labels
*/ -}}
{{- define "kubeStateMetrics.labels" -}}
{{- if .Values.serviceMonitors.kubeStateMetrics.labels }}
{{- toYaml .Values.serviceMonitors.kubeStateMetrics.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}
