{{- define "tfy-sandbox-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-sandbox-server.fullname" -}}
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

{{- define "tfy-sandbox-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tfy-sandbox-server.labels" -}}
helm.sh/chart: {{ include "tfy-sandbox-server.chart" . }}
{{ include "tfy-sandbox-server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
{{- end -}}

{{- define "tfy-sandbox-server.commonLabels" -}}
{{- $baseLabels := include "tfy-sandbox-server.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.commonAnnotations" -}}
{{- $commonAnnotations := default dict .Values.commonAnnotations }}
{{- toYaml $commonAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.deploymentLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.podLabels" -}}
{{- $selectorLabels := include "tfy-sandbox-server.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.podLabels) $selectorLabels }}
{{- toYaml $podLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.serviceLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.pdbLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.pdb.labels }}
{{- toYaml $pdbLabels }}
{{- end -}}

{{- define "tfy-sandbox-server.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.pdb.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end -}}

{{- define "tfy-sandbox-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-sandbox-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-sandbox-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-sandbox-server.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "tfy-sandbox-server.image" -}}
{{- printf "%s:%s" .Values.image.repository ((default .Chart.AppVersion .Values.image.tag) | toString) -}}
{{- end -}}
