{{/*
  LLM Gateway service scrape labels
*/}}
{{- define "llmGateway.labels" -}}
{{- if .Values.controlPlaneMonitors.llmGateway.labels }}
{{- toYaml .Values.controlPlaneMonitors.llmGateway.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  LLM Gateway service scrape annotations
*/}}
{{- define "llmGateway.annotations" -}}
{{- if .Values.controlPlaneMonitors.llmGateway.annotations }}
{{- toYaml .Values.controlPlaneMonitors.llmGateway.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Servicefoundry server service scrape labels
*/}}
{{- define "servicefoundry.labels" -}}
{{- if .Values.controlPlaneMonitors.servicefoundryServer.labels }}
{{- toYaml .Values.controlPlaneMonitors.servicefoundryServer.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Servicefoundry server service scrape annotations
*/}}
{{- define "servicefoundry.annotations" -}}
{{- if .Values.controlPlaneMonitors.servicefoundryServer.annotations }}
{{- toYaml .Values.controlPlaneMonitors.servicefoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  MLFoundry server service scrape labels
*/}}
{{- define "mlfoundry.labels" -}}
{{- if .Values.controlPlaneMonitors.mlfoundryServer.labels }}
{{- toYaml .Values.controlPlaneMonitors.mlfoundryServer.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  MLFoundry server service scrape annotations
*/}}
{{- define "mlfoundry.annotations" -}}
{{- if .Values.controlPlaneMonitors.mlfoundryServer.annotations }}
{{- toYaml .Values.controlPlaneMonitors.mlfoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Sfy-manifests service scrape labels
*/}}
{{- define "sfyManifestService.labels" -}}
{{- if .Values.controlPlaneMonitors.sfyManifestService.labels }}
{{- toYaml .Values.controlPlaneMonitors.sfyManifestService.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Sfy-manifests service scrape annotations
*/}}
{{- define "sfyManifestService.annotations" -}}
{{- if .Values.controlPlaneMonitors.sfyManifestService.annotations }}
{{- toYaml .Values.controlPlaneMonitors.sfyManifestService.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  NATS pod scrape labels
*/}}
{{- define "nats.labels" -}}
{{- if .Values.controlPlaneMonitors.nats.labels }}
{{- toYaml .Values.controlPlaneMonitors.nats.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  NATS pod scrape annotations
*/}}
{{- define "nats.annotations" -}}
{{- if .Values.controlPlaneMonitors.nats.annotations }}
{{- toYaml .Values.controlPlaneMonitors.nats.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  TFY Controller service scrape labels
*/}}
{{- define "tfyController.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyController.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyController.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  TFY Controller service scrape annotations
*/}}
{{- define "tfyController.annotations" -}}
{{- if .Values.controlPlaneMonitors.tfyController.annotations }}
{{- toYaml .Values.controlPlaneMonitors.tfyController.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  TFY K8S Controller service scrape labels
*/}}
{{- define "tfyK8sController.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyK8sController.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyK8sController.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  TFY K8S Controller service scrape annotations
*/}}
{{- define "tfyK8sController.annotations" -}}
{{- if .Values.controlPlaneMonitors.tfyK8sController.annotations }}
{{- toYaml .Values.controlPlaneMonitors.tfyK8sController.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  TFY Otel Collector service scrape labels
*/}}
{{- define "tfyOtelCollector.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyOtelCollector.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyOtelCollector.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Otel Collector service scrape annotations
*/}}
{{- define "tfyOtelCollector.annotations" -}}
{{- if .Values.controlPlaneMonitors.tfyOtelCollector.annotations }}
{{- toYaml .Values.controlPlaneMonitors.tfyOtelCollector.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Altinity ClickHouse Operator service scrape labels
*/}}
{{- define "clickhouseOperator.labels" -}}
{{- if .Values.controlPlaneMonitors.clickHouseOperator.labels }}
{{- toYaml .Values.controlPlaneMonitors.clickHouseOperator.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Altinity ClickHouse Operator service scrape annotations
*/}}
{{- define "clickhouseOperator.annotations" -}}
{{- if .Values.controlPlaneMonitors.clickHouseOperator.annotations }}
{{- toYaml .Values.controlPlaneMonitors.clickHouseOperator.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Control Plane Alert Rules Labels
*/}}
{{- define "controlPlaneAlertRules.labels" -}}
{{- if .Values.controlPlaneMonitors.alerts.alertRules.labels }}
{{- toYaml .Values.controlPlaneMonitors.alerts.alertRules.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Control Plane Alert Rules Annotations
*/}}
{{- define "controlPlaneAlertRules.annotations" -}}
{{- if .Values.controlPlaneMonitors.alerts.alertRules.annotations }}
{{- toYaml .Values.controlPlaneMonitors.alerts.alertRules.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Control Plane Alert Manager Labels
*/}}
{{- define "controlPlaneAlertManager.labels" -}}
{{- if .Values.controlPlaneMonitors.alerts.alertManager.labels }}
{{- toYaml .Values.controlPlaneMonitors.alerts.alertManager.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Control Plane Alert Manager Annotations
*/}}
{{- define "controlPlaneAlertManager.annotations" -}}
{{- if .Values.controlPlaneMonitors.alerts.alertManager.annotations }}
{{- toYaml .Values.controlPlaneMonitors.alerts.alertManager.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}
