{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified tfy-agent name
*/}}
{{- define "tfy-agent.fullname" -}}
{{- include "chart.fullname" . }}
{{- end }}

{{/*
Create a default fully qualified tfy-agent-proxy name
*/}}
{{- define "tfy-agent-proxy.fullname" -}}
{{- include "chart.fullname" . | trunc 57 | trimSuffix "-" }}-proxy
{{- end }}

{{/*
Create a default fully qualified sds-server name
*/}}
{{- define "sds-server.fullname" -}}
{{- include "chart.fullname" . | trunc 52 | trimSuffix "-" }}-sds-server
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.nameAndVersion" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Base labels - for use in commonLabels (deployment/service metadata)
Includes chart metadata, part-of, and global.labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.nameAndVersion" .context }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: tfy-agent
{{- if .context.Chart.AppVersion }}
app.kubernetes.io/version: {{ .context.Chart.AppVersion | quote }}
{{- end }}
{{- with .context.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Common labels
For use on tfyAgent deployments/resources (includes chart version)
Priority: component.commonLabels > global.labels > base labels
*/}}
{{- define "tfy-agent.commonLabels" -}}
{{- $baseLabels := include "chart.labels" (dict "context" .) | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyAgent.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - merges global.annotations with component-specific annotations
Priority: global.annotations < component.commonAnnotations
*/}}
{{- define "tfy-agent.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyAgent.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges global, pod-specific labels, and selector labels
Priority: global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "tfy-agent.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyAgent.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, and pod-specific annotations
Priority: global.podAnnotations < commonAnnotations < component.podAnnotations (highest)
*/}}
{{- define "tfy-agent.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyAgent.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges global, commonLabels with deployment-specific labels
Priority: global.deploymentLabels (lowest) < commonLabels (includes base labels) < component.deploymentLabels (highest)
*/}}
{{- define "tfy-agent.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyAgent.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges global, commonAnnotations with deployment-specific annotations
Priority: global.deploymentAnnotations (lowest) < commonAnnotations < component.deploymentAnnotations (highest)
*/}}
{{- define "tfy-agent.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyAgent.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Service Labels - merges global, commonLabels with service-specific labels
Priority: global.serviceLabels (lowest) < commonLabels (includes base labels, highest)
*/}}
{{- define "tfy-agent.serviceLabels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
Service Annotations - merges global, commonAnnotations with service-specific annotations
Priority: global.serviceAnnotations (lowest) < commonAnnotations (highest)
*/}}
{{- define "tfy-agent.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}


{{/*
Selector labels for tfyAgent
*/}}
{{- define "tfy-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-agent.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
For use on tfyAgentProxy deployments/resources (includes chart version)
Priority: component.commonLabels > global.labels > base labels
*/}}
{{- define "tfy-agent-proxy.commonLabels" -}}
{{- $baseLabels := include "chart.labels" (dict "context" .) | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.labels) $baseLabels .Values.tfyAgentProxy.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - merges global.annotations with component-specific annotations
Priority: global.annotations < component.commonAnnotations
*/}}
{{- define "tfy-agent-proxy.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.tfyAgentProxy.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges global, pod-specific labels, and selector labels
Priority: global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "tfy-agent-proxy.podLabels" -}}
{{- $selectorLabels := include "tfy-agent-proxy.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyAgentProxy.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, and pod-specific annotations
Priority: global.podAnnotations < commonAnnotations < component.podAnnotations (highest)
*/}}
{{- define "tfy-agent-proxy.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyAgentProxy.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges global, commonLabels with deployment-specific labels
Priority: global.deploymentLabels (lowest) < commonLabels (includes base labels) < component.deploymentLabels (highest)
*/}}
{{- define "tfy-agent-proxy.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyAgentProxy.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges global, commonAnnotations with deployment-specific annotations
Priority: global.deploymentAnnotations (lowest) < commonAnnotations < component.deploymentAnnotations (highest)
*/}}
{{- define "tfy-agent-proxy.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyAgentProxy.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Selector labels for tfyAgentProxy
*/}}
{{- define "tfy-agent-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-agent-proxy.fullname" . }}
{{- end }}


{{/*
Common labels
For use on sdsServer deployments/resources (includes chart version)
Priority: component.commonLabels > global.labels > base labels
*/}}
{{- define "sds-server.commonLabels" -}}
{{- $baseLabels := include "chart.labels" (dict "context" .) | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.sdsServer.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - merges global.annotations with component-specific annotations
Priority: global.annotations < component.commonAnnotations
*/}}
{{- define "sds-server.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.sdsServer.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges global, pod-specific labels, and selector labels
Priority: global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "sds-server.podLabels" -}}
{{- $selectorLabels := include "sds-server.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.sdsServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, and pod-specific annotations
Priority: global.podAnnotations < commonAnnotations < component.podAnnotations (highest)
*/}}
{{- define "sds-server.podAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.sdsServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges global, commonLabels with deployment-specific labels
Priority: global.deploymentLabels (lowest) < commonLabels (includes base labels) < component.deploymentLabels (highest)
*/}}
{{- define "sds-server.deploymentLabels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.sdsServer.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges global, commonAnnotations with deployment-specific annotations
Priority: global.deploymentAnnotations (lowest) < commonAnnotations < component.deploymentAnnotations (highest)
*/}}
{{- define "sds-server.deploymentAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.sdsServer.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Service Labels - merges global, commonLabels with service-specific labels
Priority: global.serviceLabels (lowest) < commonLabels (includes base labels, highest)
*/}}
{{- define "sds-server.serviceLabels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
Service Annotations - merges global, commonAnnotations with service-specific annotations
Priority: global.serviceAnnotations (lowest) < commonAnnotations (highest)
*/}}
{{- define "sds-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
Selector labels for sdsServer
*/}}
{{- define "sds-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sds-server.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create the name of the service account to use for tfy-agent
*/}}
{{- define "tfy-agent.serviceAccountName" -}}
{{- if .Values.tfyAgent.serviceAccount.create }}
{{- default (include "tfy-agent.fullname" .) .Values.tfyAgent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tfyAgent.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for tfy-agent-proxy
*/}}
{{- define "tfy-agent-proxy.serviceAccountName" -}}
{{- if .Values.tfyAgentProxy.serviceAccount.create }}
{{- default (include "tfy-agent-proxy.fullname" .) .Values.tfyAgentProxy.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tfyAgentProxy.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for sds-server
*/}}
{{- define "sds-server.serviceAccountName" -}}
{{- if .Values.sdsServer.serviceAccount.create }}
{{- default (include "sds-server.fullname" .) .Values.sdsServer.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.sdsServer.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret which will contain cluster token
*/}}
{{- define "tfy-agent.secretName" -}}
{{- if .Values.config.clusterTokenSecret }}
{{- .Values.config.clusterTokenSecret }}
{{- else }}
{{- include "tfy-agent.fullname" . | trunc 57 | trimSuffix "-" }}-token
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent
Priority: global.serviceAccount.labels < commonLabels < component.serviceAccount.labels
*/}}
{{- define "tfy-agent.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyAgent.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent
Merge order: commonAnnotations < serviceAccount.annotations (highest)
*/}}
{{- define "tfy-agent.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.tfyAgent.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent-proxy
Priority: global.serviceAccount.labels < commonLabels < component.serviceAccount.labels
*/}}
{{- define "tfy-agent-proxy.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyAgentProxy.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent-proxy
Merge order: commonAnnotations < serviceAccount.annotations (highest)
*/}}
{{- define "tfy-agent-proxy.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.tfyAgentProxy.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for sds-server
Priority: global.serviceAccount.labels < commonLabels < component.serviceAccount.labels
*/}}
{{- define "sds-server.serviceAccount.labels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.sdsServer.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for sds-server
Merge order: commonAnnotations < serviceAccount.annotations (highest)
*/}}
{{- define "sds-server.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.sdsServer.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}