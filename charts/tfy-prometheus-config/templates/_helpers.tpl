{{/*}}
prometheus selector labels
*/}}
{{- define "global.selectorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- if .Values.global.selectorLabels }}
{{- toYaml .Values.global.selectorLabels }}
{{- else }}
{{- toYaml $prometheusLabel }}
{{- end }}
{{- end }}
*/}}

{{- define "serviceMonitors.selectorLabels" -}}
{{- if .Values.serviceMonitors.selectorLabels }}
{{- toYaml .Values.serviceMonitors.selectorLabels }}
{{- else }}
{{- $globalSelectorLabel := include "global.selectorLabels" . | fromYaml }}
{{- toYaml $globalSelectorLabel }}
{{- end }}
{{- end }}

{{- define "serviceMonitors.labels"}}
{{- $mergedLabels := mergeOverwrite .Values.global.labels .Values.serviceMonitors.labels }}
{{- toYaml $mergedLabels }}
{{- end }}

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
  Argo Workflows service monitor labels
*/}}
{{- define "argo-workflows.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $argoWorkflowsLabels := mergeOverwrite $base (.Values.serviceMonitors.workflows.labels | default (dict)) }}
{{- toYaml $argoWorkflowsLabels }}
{{- end }}


{{/*
  Argo Workflows service monitor selector labels
*/}}
{{- define "argo-workflows.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $argoWorkflowsLabels := include "argo-workflows.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $argoWorkflowsLabels }}
{{- toYaml $serviceMonitorLabels }}
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
  KEDA service monitor labels
*/}}
{{- define "keda.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kedaLabels := mergeOverwrite $base (.Values.serviceMonitors.keda.labels | default (dict)) }}
{{- toYaml $kedaLabels }}
{{- end }}


{{/*
  KEDA service monitor selector labels
*/}}
{{- define "keda.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $kedaLabels := include "keda.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $kedaLabels }}
{{- toYaml $serviceMonitorLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kubecostLabels := mergeOverwrite $base (.Values.serviceMonitors.kubecost.labels | default (dict)) }}
{{- toYaml $kubecostLabels }}
{{- end }}


{{/*
  Kubecost service monitor selector labels
*/}}
{{- define "kubecost.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $kubecostLabels := include "kubecost.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $kubecostLabels }}
{{- toYaml $serviceMonitorLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $prometheusLabels := mergeOverwrite $base (.Values.serviceMonitors.prometheus.labels | default (dict)) }}
{{- toYaml $prometheusLabels }}
{{- end }}


{{/*
  Prometheus service monitor selector labels
*/}}
{{- define "prometheus.serviceMonitorLabels" -}}
{{- $prometheusSelector := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $prometheusLabels := include "prometheus.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusSelector $prometheusLabels }}
{{- toYaml $serviceMonitorLabels }}
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
  Prometheus Operator service monitor labels
*/}}
{{- define "prometheusOperator.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $prometheusOperatorLabels := mergeOverwrite $base (.Values.serviceMonitors.prometheusOperator.labels | default (dict)) }}
{{- toYaml $prometheusOperatorLabels }}
{{- end }}


{{/*
  Prometheus Operator service monitor selector labels
*/}}
{{- define "prometheusOperator.serviceMonitorLabels" -}}
{{- $prometheusSelector := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $prometheusOperatorLabels := include "prometheusOperator.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusSelector $prometheusOperatorLabels }}
{{- toYaml $serviceMonitorLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $alertManagerLabels := mergeOverwrite $base .Values.serviceMonitors.alertManager.labels }}
{{- toYaml $alertManagerLabels }}
{{- end }}

{{/*
Alert manager service monitor selector labels
*/}}
{{- define "alert-manager.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $alertManagerLabels := include "alert-manager.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $alertManagerLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  Kubelet service monitor labels
*/}}
{{- define "kubelet.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kubeletLabels := mergeOverwrite $base .Values.serviceMonitors.kubelet.labels }}
{{- toYaml $kubeletLabels }}
{{- end }}

{{/*
  Kubelet service monitor selector labels
 */}}
{{- define "kubelet.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $kubeletLabels := include "kubelet.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $kubeletLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  Node exporter service monitor labels
*/}}
{{- define "nodeExporter.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $nodeExporterLabels := mergeOverwrite $base (.Values.serviceMonitors.nodeExporter.labels | default (dict)) }}
{{- toYaml $nodeExporterLabels }}
{{- end }}


{{/*
  Node exporter service monitor selector labels
*/}}
{{- define "nodeExporter.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $nodeExporterLabels := include "nodeExporter.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $nodeExporterLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}


{{/*
  Kube state metrics service monitor labels
*/}}
{{- define "kubeStateMetrics.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kubeStateMetricsLabels := mergeOverwrite $base (.Values.serviceMonitors.kubeStateMetrics.labels | default (dict)) }}
{{- toYaml $kubeStateMetricsLabels }}
{{- end }}


{{/*
  Kube state metrics service monitor selector labels
*/}}
{{- define "kubeStateMetrics.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $kubeStateMetricsLabels := include "kubeStateMetrics.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $kubeStateMetricsLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  Karpenter service monitor labels
*/}}
{{- define "karpenter.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $karpenterLabels := mergeOverwrite $base (.Values.serviceMonitors.karpenter.labels | default (dict)) }}
{{- toYaml $karpenterLabels }}
{{- end }}


{{/*
  Karpenter service monitor selector labels
*/}}
{{- define "karpenter.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $karpenterLabels := include "karpenter.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $karpenterLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  GPU service monitor labels
*/}}
{{- define "gpu.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $gpuLabels := mergeOverwrite $base (.Values.serviceMonitors.gpu.labels | default (dict)) }}
{{- toYaml $gpuLabels }}
{{- end }}


{{/*
  GPU service monitor selector labels
*/}}
{{- define "gpu.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $gpuLabels := include "gpu.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $gpuLabels }}
{{- toYaml $serviceMonitorLabels }}
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

{{/*
  SSH service monitor labels
*/}}
{{- define "sshServer.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $sshLabels := mergeOverwrite $base (.Values.serviceMonitors.sshServer.labels | default (dict)) }}
{{- toYaml $sshLabels }}
{{- end }}


{{/*
  SSH service monitor selector labels
*/}}
{{- define "sshServer.serviceMonitorLabels" -}}
{{- $prometheusLabel := include "serviceMonitors.selectorLabels" . | fromYaml }}
{{- $sshLabels := include "sshServer.labels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $prometheusLabel $sshLabels }}
{{- toYaml $serviceMonitorLabels }}
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