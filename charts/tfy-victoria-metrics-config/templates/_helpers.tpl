{{/*
  LLM Gateway service scrape labels
*/}}
{{- define "vmconfig.llmGateway.labels" -}}
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
{{- define "vmconfig.llmGateway.annotations" -}}
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
{{- define "vmconfig.servicefoundry.labels" -}}
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
{{- define "vmconfig.servicefoundry.annotations" -}}
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
{{- define "vmconfig.mlfoundry.labels" -}}
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
{{- define "vmconfig.mlfoundry.annotations" -}}
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
{{- define "vmconfig.sfyManifestService.labels" -}}
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
{{- define "vmconfig.sfyManifestService.annotations" -}}
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
{{- define "vmconfig.nats.labels" -}}
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
{{- define "vmconfig.nats.annotations" -}}
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
{{- define "vmconfig.tfyController.labels" -}}
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
{{- define "vmconfig.tfyController.annotations" -}}
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
{{- define "vmconfig.tfyK8sController.labels" -}}
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
{{- define "vmconfig.tfyK8sController.annotations" -}}
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
{{- define "vmconfig.tfyOtelCollector.labels" -}}
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
{{- define "vmconfig.tfyOtelCollector.annotations" -}}
{{- if .Values.controlPlaneMonitors.tfyOtelCollector.annotations }}
{{- toYaml .Values.controlPlaneMonitors.tfyOtelCollector.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Deltafusion Ingestor service scrape labels
*/}}
{{- define "vmconfig.deltafusionIngestor.labels" -}}
{{- if .Values.controlPlaneMonitors.deltafusionIngestor.labels }}
{{- toYaml .Values.controlPlaneMonitors.deltafusionIngestor.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deltafusion ingestor service scrape annotations
*/}}
{{- define "vmconfig.deltafusionIngestor.annotations" -}}
{{- if .Values.controlPlaneMonitors.deltafusionIngestor.annotations }}
{{- toYaml .Values.controlPlaneMonitors.deltafusionIngestor.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deltafusion query server service scrape labels
*/}}
{{- define "vmconfig.deltafusionQueryServer.labels" -}}
{{- if .Values.controlPlaneMonitors.deltafusionQueryServer.labels }}
{{- toYaml .Values.controlPlaneMonitors.deltafusionQueryServer.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deltafusion query server service scrape annotations
*/}}
{{- define "vmconfig.deltafusionIngestor.annotations" -}}
{{- if .Values.controlPlaneMonitors.deltafusionQueryServer.annotations }}
{{- toYaml .Values.controlPlaneMonitors.deltafusionQueryServer.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Control Plane Alert Rules Labels
*/}}
{{- define "vmconfig.controlPlaneAlertRules.labels" -}}
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
{{- define "vmconfig.controlPlaneAlertRules.annotations" -}}
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
{{- define "vmconfig.controlPlaneAlertManager.labels" -}}
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
{{- define "vmconfig.controlPlaneAlertManager.annotations" -}}
{{- if .Values.controlPlaneMonitors.alerts.alertManager.annotations }}
{{- toYaml .Values.controlPlaneMonitors.alerts.alertManager.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}
