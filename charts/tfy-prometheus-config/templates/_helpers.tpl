{{/*}}
Global Labels
*/}}
{{- define "global.labels" -}}
{{- $prometheusLabel := dict "release" "prometheus" -}}
{{- $globals := deepCopy (.Values.global.labels) -}}
{{- mergeOverwrite $prometheusLabel $globals | toYaml -}}
{{- end }}

{{/*
Service Monitor Labels
*/}}
{{- define "serviceMonitors.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.serviceMonitors.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}

{{/*
Pod Monitor Labels
*/}}
{{- define "podMonitors.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.podMonitors.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}

{{/*
Alert Manager Labels
*/}}
{{- define "alertManagers.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.alertManagers.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}

{{/*
TFY Agent Labels
*/}}
{{- define "tfy-agent.labels" -}}
{{- $base := (include "alertManagers.labels" . | fromYaml) -}}
{{- $local := .Values.alertManagers.tfyAgent.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}


{{/*
Alert Manager Annotations
*/}}
{{- define "tfy-agent.annotations" -}}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
Scrape Config Labels}}
*/}}
{{- define "scrapeConfigs.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.scrapeConfigs.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}

{{/*
Labels for envoy stats scrape configs
*/}}
{{- define "envoyStats.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.scrapeConfigs.envoy.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
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
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.scrapeConfigs.kubernetesPods.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
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
{{- $argoWorkflowsLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.workflows.labels) }}
{{- toYaml $argoWorkflowsLabels }}
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
{{- $kedaLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.keda.labels) }}
{{- toYaml $kedaLabels }}
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
{{- $kubecostLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.kubecost.labels) }}
{{- toYaml $kubecostLabels }}
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
{{- $prometheusLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.prometheus.labels) }}
{{- toYaml $prometheusLabels }}
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
{{- $prometheusOperatorLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.prometheusOperator.labels) }}
{{- toYaml $prometheusOperatorLabels }}
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
Prometheus Rules Labels
*/}}
{{- define "prometheusRules.labels" -}}
{{- $base := (include "global.labels" . | fromYaml) -}}
{{- $local := .Values.prometheusRules.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
{{- end -}}

{{/*
{{- end }}

{{/*
  Container rules labels
*/}}
{{- define "containerRule.labels" -}}
{{- $base := (include "prometheusRules.labels" . | fromYaml) -}}
{{- $containerRuleLabels := .Values.prometheusRules.containerRules.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $containerRuleLabels -}}
{{- toYaml $mergedLabels -}}
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
{{- $base := (include "prometheusRules.labels" . | fromYaml) -}}
{{- $envoyPortRuleLabels := .Values.prometheusRules.envoyPortRules.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $envoyPortRuleLabels -}}
{{- toYaml $mergedLabels -}}
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
{{- $base := (include "prometheusRules.labels" . | fromYaml) -}}
{{- $kubecostRuleLabels := .Values.prometheusRules.kubecostRules.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $kubecostRuleLabels -}}
{{- toYaml $mergedLabels -}}
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
  Kubelet service monitor labels
*/}}
{{- define "kubelet.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kubeletLabels := mergeOverwrite (deepCopy $base) .Values.serviceMonitors.kubelet.labels }}
{{- toYaml $kubeletLabels }}
{{- end }}

{{/*
  Node exporter service monitor labels
*/}}
{{- define "nodeExporter.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $nodeExporterLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.nodeExporter.labels) }}
{{- toYaml $nodeExporterLabels }}
{{- end }}


{{/*
  Kube state metrics service monitor labels
*/}}
{{- define "kubeStateMetrics.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $kubeStateMetricsLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.kubeStateMetrics.labels) }}
{{- toYaml $kubeStateMetricsLabels }}
{{- end }}

{{/*
  Karpenter service monitor labels
*/}}
{{- define "karpenter.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $karpenterLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.karpenter.labels) }}
{{- toYaml $karpenterLabels }}
{{- end }}


{{/*
  GPU service monitor labels
*/}}
{{- define "gpu.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $gpuLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.gpu.labels) }}
{{- toYaml $gpuLabels }}
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
  Alert manager service monitor labels
*/}}
{{- define "alert-manager.labels" -}}
{{- $base := (include "serviceMonitors.labels" . | fromYaml) -}}
{{- $local := .Values.serviceMonitors.alertManager.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $mlfoundryLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.mlfoundryServer.labels) }}
{{- toYaml $mlfoundryLabels }}
{{- end }}

{{/*
  Sfy-manifests service monitor labels
*/}}
{{- define "sfyManifestService.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $sfyManifestLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.sfyManifestService.labels) }}
{{- toYaml $sfyManifestLabels }}
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
{{- $base := include "podMonitors.labels" . | fromYaml }}
{{- $natsLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.nats.labels) }}
{{- toYaml $natsLabels }}
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
{{- $sshLabels := mergeOverwrite (deepCopy $base) (.Values.serviceMonitors.sshServer.labels) }}
{{- toYaml $sshLabels }}
{{- end }}

{{/*
  TFY Controller service monitor labels
 */}}
{{- define "tfyController.labels" -}}
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $tfyControllerLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.tfyController.labels) }}
{{- toYaml $tfyControllerLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $tfyK8sControllerLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.tfyK8sController.labels) }}
{{- toYaml $tfyK8sControllerLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $tfyOtelCollectorLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.tfyOtelCollector.labels) }}
{{- toYaml $tfyOtelCollectorLabels }}
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
{{- $base := include "serviceMonitors.labels" . | fromYaml }}
{{- $clickhouseOperatorLabels := mergeOverwrite (deepCopy $base) (.Values.controlPlaneMonitors.clickHouseOperator.labels) }}
{{- toYaml $clickhouseOperatorLabels }}
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
{{- $base := (include "prometheusRules.labels" . | fromYaml) -}}
{{- $local := .Values.controlPlaneMonitors.alerts.alertRules.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
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
{{- $base := (include "alertManagers.labels" . | fromYaml) -}}
{{- $local := .Values.controlPlaneMonitors.alerts.alertManager.labels -}}
{{- $mergedLabels := mergeOverwrite (deepCopy $base) $local -}}
{{- toYaml $mergedLabels -}}
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