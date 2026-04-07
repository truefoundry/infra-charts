{{- define "tfy-cloudflared.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-cloudflared.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "tfy-cloudflared.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-cloudflared.labels" -}}
helm.sh/chart: {{ include "tfy-cloudflared.chart" . }}
{{ include "tfy-cloudflared.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
{{- end -}}

{{- define "tfy-cloudflared.commonLabels" -}}
{{- $baseLabels := include "tfy-cloudflared.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end -}}

{{- define "tfy-cloudflared.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{- define "tfy-cloudflared.deploymentLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end -}}

{{- define "tfy-cloudflared.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.podLabels" -}}
{{- $selectorLabels := include "tfy-cloudflared.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end -}}

{{- define "tfy-cloudflared.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.serviceLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end -}}

{{- define "tfy-cloudflared.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end -}}

{{- define "tfy-cloudflared.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.serviceMonitorLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels .Values.serviceMonitor.additionalLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end -}}

{{- define "tfy-cloudflared.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.serviceMonitor.additionalAnnotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.pdbLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.pdb.labels }}
{{- toYaml $pdbLabels }}
{{- end -}}

{{- define "tfy-cloudflared.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.pdb.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.secretLabels" -}}
{{- $commonLabels := include "tfy-cloudflared.commonLabels" . | fromYaml }}
{{- toYaml $commonLabels }}
{{- end -}}

{{- define "tfy-cloudflared.secretAnnotations" -}}
{{- $commonAnnotations := include "tfy-cloudflared.commonAnnotations" . | fromYaml }}
{{- toYaml $commonAnnotations }}
{{- end -}}

{{- define "tfy-cloudflared.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-cloudflared.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-cloudflared.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-cloudflared.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "tfy-cloudflared.image" -}}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) -}}
{{- end -}}

{{/* Tunnel token secret name */}}
{{- define "tfy-cloudflared.tunnelSecretName" -}}
{{- if .Values.tunnel.existingSecret -}}
{{- .Values.tunnel.existingSecret -}}
{{- else -}}
{{- printf "%s-tunnel" (include "tfy-cloudflared.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Tunnel token secret key */}}
{{- define "tfy-cloudflared.tunnelSecretKey" -}}
{{- .Values.tunnel.existingSecretKey | default "token" -}}
{{- end -}}
