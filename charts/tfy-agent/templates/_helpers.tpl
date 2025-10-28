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
Common labels for tfyAgent - uses global tfy-agent.labels function
*/}}
{{- define "tfyAgent.labels" -}}
{{- include "tfy-agent.labels" (dict "context" . "name" "tfy-agent") }}
{{- end }}

{{/*
Common labels - merges base labels with commonLabels
For use on tfyAgent deployments/resources (includes chart version)
*/}}
{{- define "tfy-agent.commonLabels" -}}
{{- $baseLabels := include "tfyAgent.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels .Values.tfyAgent.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - component-specific annotations
*/}}
{{- define "tfy-agent.commonAnnotations" -}}
{{- with .Values.tfyAgent.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges commonLabels with pod-specific labels and legacy labels
*/}}
{{- define "tfy-agent.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" "tfy-agent") | fromYaml }}
{{- $podLabels := mergeOverwrite $selectorLabels .Values.tfyAgent.podLabels .Values.tfyAgent.labels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges commonAnnotations with pod-specific annotations and legacy annotations
*/}}
{{- define "tfy-agent.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgent.podAnnotations .Values.tfyAgent.annotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
*/}}
{{- define "tfy-agent.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.tfyAgent.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges commonAnnotations with deployment-specific annotations
*/}}
{{- define "tfy-agent.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgent.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Service Labels - merges commonLabels with service-specific labels
*/}}
{{- define "tfy-agent.serviceLabels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
Service Annotations - merges commonAnnotations with service-specific annotations
*/}}
{{- define "tfy-agent.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- toYaml $commonAnnotations }}
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
Common labels for tfyAgentProxy - uses global tfy-agent.labels function
*/}}
{{- define "tfyAgentProxy.labels" -}}
{{- include "tfy-agent.labels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) }}
{{- end }}

{{/*
Common labels - merges base labels with commonLabels
For use on tfyAgentProxy deployments/resources (includes chart version)
*/}}
{{- define "tfy-agent-proxy.commonLabels" -}}
{{- $baseLabels := include "tfyAgentProxy.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels .Values.tfyAgentProxy.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - component-specific annotations
*/}}
{{- define "tfy-agent-proxy.commonAnnotations" -}}
{{- with .Values.tfyAgentProxy.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges commonLabels with pod-specific labels and legacy labels
*/}}
{{- define "tfy-agent-proxy.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) | fromYaml }}
{{- $podLabels := mergeOverwrite $selectorLabels .Values.tfyAgentProxy.podLabels .Values.tfyAgentProxy.labels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges commonAnnotations with pod-specific annotations and legacy annotations
*/}}
{{- define "tfy-agent-proxy.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgentProxy.podAnnotations .Values.tfyAgentProxy.annotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
*/}}
{{- define "tfy-agent-proxy.deploymentLabels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.tfyAgentProxy.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges commonAnnotations with deployment-specific annotations
*/}}
{{- define "tfy-agent-proxy.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgentProxy.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Selector labels for tfyAgentProxy - uses global function
*/}}
{{- define "tfy-agent-proxy.selectorLabels" -}}
{{- include "tfy-agent.selectorLabels" (dict "context" . "name" (include "tfy-agent-proxy.fullname" .)) }}
{{- end }}


{{/*
Common labels for sdsServer - uses global tfy-agent.labels function
*/}}
{{- define "sdsServer.labels" -}}
{{- include "tfy-agent.labels" (dict "context" . "name" "sds-server") }}
{{- end }}

{{/*
Common labels - merges base labels with commonLabels
For use on sdsServer deployments/resources (includes chart version)
*/}}
{{- define "sds-server.commonLabels" -}}
{{- $baseLabels := include "sdsServer.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels .Values.sdsServer.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Common annotations - component-specific annotations
*/}}
{{- define "sds-server.commonAnnotations" -}}
{{- with .Values.sdsServer.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Pod Labels - merges commonLabels with pod-specific labels and legacy labels
*/}}
{{- define "sds-server.podLabels" -}}
{{- $selectorLabels := include "tfy-agent.selectorLabels" (dict "context" . "name" "sds-server") | fromYaml }}
{{- $podLabels := mergeOverwrite $selectorLabels .Values.sdsServer.podLabels .Values.sdsServer.labels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
Pod Annotations - merges commonAnnotations with pod-specific annotations and legacy annotations
*/}}
{{- define "sds-server.podAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite $commonAnnotations .Values.sdsServer.podAnnotations .Values.sdsServer.annotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
Deployment Labels - merges commonLabels with deployment-specific labels
*/}}
{{- define "sds-server.deploymentLabels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $commonLabels .Values.sdsServer.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Deployment Annotations - merges commonAnnotations with deployment-specific annotations
*/}}
{{- define "sds-server.deploymentAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite $commonAnnotations .Values.sdsServer.deploymentAnnotations }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
Service Labels - merges commonLabels with service-specific labels
*/}}
{{- define "sds-server.serviceLabels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
Service Annotations - merges commonAnnotations with service-specific annotations
*/}}
{{- define "sds-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- toYaml $commonAnnotations }}
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
*/}}
{{- define "resource-quotas.commonLabels" -}}
{{- $baseLabels := include "resource-quotas.labels" (dict "context" .) | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels .Values.resourceQuota.commonLabels .Values.resourceQuota.labels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
Annotations for resource quotas - merges commonAnnotations with legacy annotations
*/}}
{{- define "resource-quotas.commonAnnotations" -}}
{{- $annotations := mergeOverwrite .Values.resourceQuota.commonAnnotations .Values.resourceQuota.annotations }}
{{- with $annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent
*/}}
{{- define "tfy-agent.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent
*/}}
{{- define "tfy-agent.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgent.serviceAccount.annotations .Values.tfyAgent.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for tfy-agent-proxy
*/}}
{{- define "tfy-agent-proxy.serviceAccount.labels" -}}
{{- $commonLabels := include "tfy-agent-proxy.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
ServiceAccount annotations for tfy-agent-proxy
*/}}
{{- define "tfy-agent-proxy.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "tfy-agent-proxy.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite $commonAnnotations .Values.tfyAgentProxy.serviceAccount.annotations .Values.tfyAgentProxy.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Labels for sds-server
*/}}
{{- define "sds-server.serviceAccount.labels" -}}
{{- $commonLabels := include "sds-server.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
ServiceAccount annotations for sds-server
*/}}
{{- define "sds-server.serviceAccount.annotations" -}}
{{- $commonAnnotations := include "sds-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite $commonAnnotations .Values.sdsServer.serviceAccount.annotations .Values.sdsServer.annotations }}
{{- with $serviceAccountAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}