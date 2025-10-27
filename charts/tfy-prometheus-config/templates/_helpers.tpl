{{/*
Alert Manager Labels
*/}}
{{- define "alertManagers.labels" -}}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Alert Manager Annotations
*/}}
{{- define "alertManagers.annotations" -}}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
Labels for envoy stats scrape configs
*/}}
{{- define "envoyStats.labels" -}}
{{- if .Values.scrapeConfigs.envoy.labels }}
{{- toYaml .Values.scrapeConfigs.envoy.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Annotations for envoy stats scrape configs
*/}}
{{- define "envoyStats.annotations" -}}
{{- if .Values.scrapeConfigs.envoy.annotations }}
{{- toYaml .Values.scrapeConfigs.envoy.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Labels for kubernetes pods scrape configs
*/}}
{{- define "k8sPods.labels" -}}
{{- if .Values.scrapeConfigs.kubernetesPods.labels }}
{{- toYaml .Values.scrapeConfigs.kubernetesPods.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Annotations for kubernetes pods scrape configs
*/}}
{{- define "k8sPods.annotations" -}}
{{- if .Values.scrapeConfigs.kubernetesPods.annotations }}
{{- toYaml .Values.scrapeConfigs.kubernetesPods.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Argo workflows service monitor labels
*/}}
{{- define "argo-workflows.labels" -}}
{{- if .Values.serviceMonitors.workflows.labels }}
{{- toYaml .Values.serviceMonitors.workflows.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}


{{/*
Argo workflows service monitor annotations
*/}}
{{- define "argo-workflows.annotations" -}}
{{- if .Values.serviceMonitors.workflows.annotations }}
{{- toYaml .Values.serviceMonitors.workflows.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Elasti service monitor labels
*/}}
{{- define "elasti.labels" -}}
{{- if .Values.serviceMonitors.elasti.labels }}
{{- toYaml .Values.serviceMonitors.elasti.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Elasti service monitor annotations
*/}}
{{- define "elasti.annotations" -}}
{{- if .Values.serviceMonitors.elasti.annotations }}
{{- toYaml .Values.serviceMonitors.elasti.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Keda service monitor labels
*/}}
{{- define "keda.labels" -}}
{{- if .Values.serviceMonitors.keda.labels }}
{{- toYaml .Values.serviceMonitors.keda.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Keda service monitor annotations
*/}}
{{- define "keda.annotations" -}}
{{- if .Values.serviceMonitors.keda.annotations }}
{{- toYaml .Values.serviceMonitors.keda.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Kubecost service monitor labels
*/}}
{{- define "kubecost.labels" -}}
{{- if .Values.serviceMonitors.kubecost.labels }}
{{- toYaml .Values.serviceMonitors.kubecost.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Kubecost service monitor annotations
*/}}
{{- define "kubecost.annotations" -}}
{{- if .Values.serviceMonitors.kubecost.annotations }}
{{- toYaml .Values.serviceMonitors.kubecost.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Prometheus service monitor labels
*/}}
{{- define "prometheus.labels" -}}
{{- if .Values.serviceMonitors.prometheus.labels }}
{{- toYaml .Values.serviceMonitors.prometheus.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Prometheus service monitor annotations
*/}}
{{- define "prometheus.annotations" -}}
{{- if .Values.serviceMonitors.prometheus.annotations }}
{{- toYaml .Values.serviceMonitors.prometheus.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Prometheus operator service monitor labels
*/}}
{{- define "prometheusOperator.labels" -}}
{{- if .Values.serviceMonitors.prometheusOperator.labels }}
{{- toYaml .Values.serviceMonitors.prometheusOperator.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Prometheus operator service monitor annotations
*/}}
{{- define "prometheusOperator.annotations" -}}
{{- if .Values.serviceMonitors.prometheusOperator.annotations }}
{{- toYaml .Values.serviceMonitors.prometheusOperator.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Container rules labels
*/}}
{{- define "containerRule.labels" -}}
{{- if .Values.prometheusRules.containerRules.labels }}
{{- toYaml .Values.prometheusRules.containerRules.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Container rules annotations
*/}}
{{- define "containerRule.annotations" -}}
{{- if .Values.prometheusRules.containerRules.annotations }}
{{- toYaml .Values.prometheusRules.containerRules.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}


{{/*
  Container rules labels
*/}}
{{- define "envoyPortRules.labels" -}}
{{- if .Values.prometheusRules.envoyPortRules.labels }}
{{- toYaml .Values.prometheusRules.envoyPortRules.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
Container rules annotations
*/}}
{{- define "envoyPortRules.annotations" -}}
{{- if .Values.prometheusRules.envoyPortRules.annotations }}
{{- toYaml .Values.prometheusRules.envoyPortRules.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Kubecost rules labels
*/}}
{{- define "kubecostRules.labels" -}}
{{- if .Values.prometheusRules.kubecostRules.labels }}
{{- toYaml .Values.prometheusRules.kubecostRules.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Kubecost rules annotations
  */}}
{{- define "kubecostRules.annotations" -}}
{{- if .Values.prometheusRules.kubecostRules.annotations }}
{{- toYaml .Values.prometheusRules.kubecostRules.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Alert manager service monitor labels
*/}}
{{- define "alert-manager.labels" -}}
{{- if .Values.serviceMonitors.alertManager.labels }}
{{- toYaml .Values.serviceMonitors.alertManager.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Kubelet service monitor labels
*/}}
{{- define "kubelet.labels" -}}
{{- if .Values.serviceMonitors.kubelet.labels }}
{{- toYaml .Values.serviceMonitors.kubelet.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Node exporter service monitor labels
*/}}
{{- define "nodeExporter.labels" -}}
{{- if .Values.serviceMonitors.nodeExporter.labels }}
{{- toYaml .Values.serviceMonitors.nodeExporter.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Kube state metrics service monitor labels
*/}}
{{- define "kubeStateMetrics.labels" -}}
{{- if .Values.serviceMonitors.kubeStateMetrics.labels }}
{{- toYaml .Values.serviceMonitors.kubeStateMetrics.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Karpenter service monitor labels
*/}}
{{- define "karpenter.labels" -}}
{{- if .Values.serviceMonitors.karpenter.labels }}
{{- toYaml .Values.serviceMonitors.karpenter.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  GPU service monitor labels
*/}}
{{- define "gpu.labels" -}}
{{- if .Values.serviceMonitors.gpu.labels }}
{{- toYaml .Values.serviceMonitors.gpu.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  GPU service monitor annotations
*/}}
{{- define "gpu.annotations" -}}
{{- if .Values.serviceMonitors.gpu.annotations }}
{{- toYaml .Values.serviceMonitors.gpu.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Karpenter service monitor annotations
*/}}
{{- define "karpenter.annotations" -}}
{{- if .Values.serviceMonitors.karpenter.annotations }}
{{- toYaml .Values.serviceMonitors.karpenter.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Kube state metrics service monitor annotations
*/}}
{{- define "kubeStateMetrics.annotations" -}}
{{- if .Values.serviceMonitors.kubeStateMetrics.annotations }}
{{- toYaml .Values.serviceMonitors.kubeStateMetrics.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Node exporter service monitor annotations
*/}}
{{- define "nodeExporter.annotations" -}}
{{- if .Values.serviceMonitors.nodeExporter.annotations }}
{{- toYaml .Values.serviceMonitors.nodeExporter.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Kubelet service monitor annotations
*/}}
{{- define "kubelet.annotations" -}}
{{- if .Values.serviceMonitors.kubelet.annotations }}
{{- toYaml .Values.serviceMonitors.kubelet.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Alert manager service monitor annotations
*/}}
{{- define "alert-manager.annotations" -}}
{{- if .Values.serviceMonitors.alertManager.annotations }}
{{- toYaml .Values.serviceMonitors.alertManager.annotations }}
{{- else if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  LLM Gateway service monitor labels
*/}}
{{- define "llmGateway.labels" -}}
{{- if .Values.controlPlaneMonitors.llmGateway.labels }}
{{- toYaml .Values.controlPlaneMonitors.llmGateway.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  LLM Gateway service monitor annotations
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
  Servicefoundry server service monitor labels
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
  Servicefoundry server service monitor labels
*/}}
{{- define "servicefoundry.labels" -}}
{{- if .Values.controlPlaneMonitors.servicefoundryServer.labels }}
{{- toYaml .Values.controlPlaneMonitors.servicefoundryServer.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  MLFoundry server service monitor labels
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
  MLFoundry server service monitor labels
*/}}
{{- define "mlfoundry.labels" -}}
{{- if .Values.controlPlaneMonitors.mlfoundryServer.labels }}
{{- toYaml .Values.controlPlaneMonitors.mlfoundryServer.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Sfy-manifests service monitor labels
*/}}
{{- define "sfyManifestService.labels" -}}
{{- if .Values.controlPlaneMonitors.sfyManifestService.labels }}
{{- toYaml .Values.controlPlaneMonitors.sfyManifestService.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Sfy-manifests service monitor annotations
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
  NATS service monitor labels
*/}}
{{- define "nats.labels" -}}
{{- if .Values.controlPlaneMonitors.nats.labels }}
{{- toYaml .Values.controlPlaneMonitors.nats.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  NATS service monitor annotations
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

{{- /*
  SSH service monitor labels
*/ -}}
{{- define "sshServer.labels" -}}
{{- if .Values.serviceMonitors.sshServer.labels }}
{{- toYaml .Values.serviceMonitors.sshServer.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  TFY Controller service monitor labels
 */}}
{{- define "tfyController.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyController.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyController.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  TFY Controller service monitor annotations
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
  TFY K8S Controller service monitor labels
 */}}
{{- define "tfyK8sController.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyK8sController.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyK8sController.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  TFY K8S Controller service monitor annotations
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
  TYF Otel Collector service monitor labels
*/}}
{{- define "tfyOtelCollector.labels" -}}
{{- if .Values.controlPlaneMonitors.tfyOtelCollector.labels }}
{{- toYaml .Values.controlPlaneMonitors.tfyOtelCollector.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Otel Collector service monitor annotations
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
  Altinity ClickHouse Operator service monitor labels
*/}}
{{- define "clickhouseOperator.labels" -}}
{{- if .Values.controlPlaneMonitors.clickHouseOperator.labels }}
{{- toYaml .Values.controlPlaneMonitors.clickHouseOperator.labels }}
{{- else if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{{- toYaml (dict "release" "prometheus") }}
{{- end }}
{{- end }}

{{/*
  Altinity ClickHouse Operator service monitor annotations
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
{{- toYaml (dict "release" "prometheus") }}
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
{{- toYaml (dict "release" "prometheus") }}
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