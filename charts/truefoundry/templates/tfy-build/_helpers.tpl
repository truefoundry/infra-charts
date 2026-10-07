{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-build.name" -}}
{{- default .Chart.Name .Values.tfyBuild.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-build.fullname" -}}
{{- if .Values.tfyBuild.fullnameOverride }}
{{- .Values.tfyBuild.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-build" .Values.tfyBuild.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
  Create chart name and version as used by the chart label.
  */}}
{{- define "tfy-build.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "tfy-build.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "name" "tfy-build") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-build.commonLabels" -}}
{{- $baseLabels := include "tfy-build.labels" . | fromYaml }}
{{- $componentLabels := default dict .Values.tfyBuild.commonLabels }}
{{- $commonLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) $componentLabels }}
{{- toYaml $commonLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-build.commonAnnotations" -}}
{{- $componentAnnotations := default dict .Values.tfyBuild.commonAnnotations }}
{{- $commonAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) $componentAnnotations }}
{{- toYaml $commonAnnotations }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "tfy-build.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "tfy-build") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.tfyBuild.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-build.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-build.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.tfyBuild.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-build.deploymentLabels" -}}
{{- $commonLabels := include "tfy-build.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.tfyBuild.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment Annotations - merges commonAnnotations with deployment-specific annotations
  */}}
{{- define "tfy-build.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-build.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.tfyBuild.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-build.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-build.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.tfyBuild.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-build.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-build.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.tfyBuild.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-build.serviceAccountName" -}}
{{- if .Values.tfyBuild.serviceAccount.name -}}
{{- .Values.tfyBuild.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
  Merge default nodeSelector with nodeSelector specified in tfy-build.nodeSelector
  Priority: default > component > global (defaults cannot be overwritten)
*/}}
{{- define "tfy-build.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $temp := mergeOverwrite (deepCopy .Values.global.nodeSelector) (deepCopy .Values.tfyBuild.truefoundryWorkflows.nodeSelector) }}
{{- $mergedNodeSelector := mergeOverwrite (deepCopy $temp) (deepCopy $defaultNodeSelector) }}
{{- toYaml $mergedNodeSelector }}
{{- end }}

{{/*
  Merge default nodeSelector with nodeSelector specified in tfy-buildkitd.nodeSelector
  Priority: default > component > global (defaults cannot be overwritten)
*/}}
{{- define "tfy-buildkitd.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $temp := mergeOverwrite (deepCopy .Values.global.nodeSelector) (deepCopy .Values.tfyBuild.truefoundryWorkflows.buildkitd.nodeSelector) }}
{{- $mergedNodeSelector := mergeOverwrite (deepCopy $temp) (deepCopy $defaultNodeSelector) }}
{{- toYaml $mergedNodeSelector }}
{{- end }}

{{/*
  Image pull secrets for tfy-build - allows component-specific override
*/}}
{{- define "tfy-build.imagePullSecrets" -}}
{{- if .Values.tfyBuild.imagePullSecrets -}}
{{- toYaml .Values.tfyBuild.imagePullSecrets -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}