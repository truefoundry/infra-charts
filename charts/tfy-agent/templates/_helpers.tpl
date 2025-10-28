{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tfy-agent.fullname" -}}
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
Create a default fully qualified tfy-agent-proxy name
*/}}
{{- define "tfy-agent-proxy.fullname" -}}
{{- include "tfy-agent.fullname" . | trunc 57 | trimSuffix "-" }}-proxy
{{- end }}

{{/*
Create a default fully qualified sds-server name
*/}}
{{- define "sds-server.fullname" -}}
{{- include "tfy-agent.fullname" . | trunc 52 | trimSuffix "-" }}-sds-server
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels - Global function used for all components
Takes: dict with "context" and "name" parameters
Includes chart version and other metadata (for deployments/resources, NOT pods)
*/}}
{{- define "tfy-agent.labels" -}}
helm.sh/chart: {{ include "tfy-agent.chart" .context }}
{{ include "tfy-agent.selectorLabels" (dict "context" .context "name" .name) }}
{{- if .context.Chart.AppVersion }}
app.kubernetes.io/version: {{ .context.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
{{- end }}

{{/*
Common labels - merges base labels with global.labels and commonLabels
For use on tfyAgent deployments/resources (includes chart version)
Priority: global.labels < component.commonLabels < base labels (highest)
*/}}
{{- define "tfy-agent.commonLabels" -}}
{{- $baseLabels := include "tfy-agent.labels" (dict "context" . "name" "tfy-agent") | fromYaml }}
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
Pod Labels - merges global, legacy, pod-specific labels, and selector labels
Priority: legacy labels (lowest) < global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "tfy-agent.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" "tfy-agent") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.tfyAgent.labels) (deepCopy .Values.global.podLabels) .Values.tfyAgent.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, legacy, and pod-specific annotations
Priority: global.podAnnotations (lowest) < commonAnnotations < legacy < component.podAnnotations (highest)
*/}}
{{- define "tfy-agent.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyAgent.annotations .Values.tfyAgent.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
Priority: commonLabels (includes base labels) < component.deploymentLabels
*/}}
{{- define "tfy-agent.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.tfyAgent.deploymentLabels }}
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
Selector labels - Global function for all components
Takes: dict with "context" and "name" parameters
*/}}
{{- define "tfy-agent.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end }}

{{/*
Common labels - merges base labels with global.labels and commonLabels
For use on tfyAgentProxy deployments/resources (includes chart version)
Priority: global.labels < component.commonLabels < base labels (highest)
*/}}
{{- define "tfy-agent-proxy.commonLabels" -}}
{{- $baseLabels := include "tfy-agent.labels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.tfyAgentProxy.commonLabels }}
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
Pod Labels - merges global, legacy, pod-specific labels, and selector labels
Priority: legacy labels (lowest) < global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "tfy-agent-proxy.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.tfyAgentProxy.labels) (deepCopy .Values.global.podLabels) .Values.tfyAgentProxy.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, legacy, and pod-specific annotations
Priority: global.podAnnotations (lowest) < commonAnnotations < legacy < component.podAnnotations (highest)
*/}}
{{- define "tfy-agent-proxy.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyAgentProxy.annotations .Values.tfyAgentProxy.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
Priority: commonLabels (includes base labels) < component.deploymentLabels
*/}}
{{- define "tfy-agent-proxy.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.tfyAgentProxy.deploymentLabels }}
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
Selector labels for tfyAgentProxy - uses global function
*/}}
{{- define "tfy-agent-proxy.selectorLabels" -}}
{{- include "tfy-agent.selectorLabels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) }}
{{- end }}


{{/*
Common labels - merges base labels with global.labels and commonLabels
For use on sdsServer deployments/resources (includes chart version)
Priority: global.labels < component.commonLabels < base labels (highest)
*/}}
{{- define "sds-server.commonLabels" -}}
{{- $baseLabels := include "tfy-agent.labels" (dict "context" . "name" "sds-server") | fromYaml }}
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
Pod Labels - merges global, legacy, pod-specific labels, and selector labels
Priority: legacy labels (lowest) < global.podLabels < component.podLabels < selectorLabels (highest)
*/}}
{{- define "sds-server.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" "sds-server") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.sdsServer.labels) (deepCopy .Values.global.podLabels) .Values.sdsServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges global, commonAnnotations, legacy, and pod-specific annotations
Priority: global.podAnnotations (lowest) < commonAnnotations < legacy < component.podAnnotations (highest)
*/}}
{{- define "sds-server.podAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.sdsServer.annotations .Values.sdsServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
Priority: commonLabels (includes base labels) < component.deploymentLabels
*/}}
{{- define "sds-server.deploymentLabels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.sdsServer.deploymentLabels }}
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
Selector labels for sdsServer - uses global function
*/}}
{{- define "sds-server.selectorLabels" -}}
{{- include "tfy-agent.selectorLabels" (dict "context" . "name" "sds-server") }}
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
Labels for resource quotas
*/}}
{{- define "resource-quotas.labels" -}}
helm.sh/chart: {{ include "tfy-agent.chart" .context }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
{{- end }}

{{/*
Common labels for resource quotas - merges base labels with commonLabels and legacy labels
Merge order: legacy labels (lowest) < commonLabels < base labels (highest priority)
*/}}
{{- define "resource-quotas.commonLabels" -}}
{{- $baseLabels := include "resource-quotas.labels" (dict "context" .) | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.resourceQuota.labels) .Values.resourceQuota.commonLabels $baseLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Annotations for resource quotas - merges commonAnnotations with legacy annotations
Merge order: commonAnnotations (lowest) < legacy annotations (highest priority)
*/}}
{{- define "resource-quotas.commonAnnotations" -}}
{{- $annotations := mergeOverwrite (deepCopy .Values.resourceQuota.commonAnnotations) .Values.resourceQuota.annotations }}
{{- with $annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent
Priority: global.serviceAccount.labels (lowest) < commonLabels (includes base labels, highest)
*/}}
{{- define "tfy-agent.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent
Merge order: commonAnnotations (lowest) < legacy annotations < serviceAccount.annotations (highest)
*/}}
{{- define "tfy-agent.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.tfyAgent.annotations .Values.tfyAgent.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent-proxy
Priority: global.serviceAccount.labels (lowest) < commonLabels (includes base labels, highest)
*/}}
{{- define "tfy-agent-proxy.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent-proxy
Merge order: commonAnnotations (lowest) < legacy annotations < serviceAccount.annotations (highest)
*/}}
{{- define "tfy-agent-proxy.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.tfyAgentProxy.annotations .Values.tfyAgentProxy.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for sds-server
Priority: global.serviceAccount.labels (lowest) < commonLabels (includes base labels, highest)
*/}}
{{- define "sds-server.serviceAccount.labels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
ServiceAccount annotations for sds-server
Merge order: commonAnnotations (lowest) < legacy annotations < serviceAccount.annotations (highest)
*/}}
{{- define "sds-server.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy $commonAnnotations) .Values.sdsServer.annotations .Values.sdsServer.serviceAccount.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}