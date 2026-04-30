{{- define "tfy-metrics-dashboard.name" -}}
{{- default "tfy-metrics-dashboard" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-metrics-dashboard.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-metrics-dashboard" .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "tfy-metrics-dashboard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-metrics-dashboard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "tfy-metrics-dashboard.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "tfy-metrics-dashboard.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "tfy-metrics-dashboard.image" -}}
{{- $tag := .Values.image.tag | toString -}}
{{- if .Values.image.registry -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}

{{- define "tfy-metrics-dashboard.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-metrics-dashboard.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "tfy-metrics-dashboard.resources" -}}
{{- if .Values.resources -}}
{{- toYaml .Values.resources -}}
{{- else -}}
requests:
  cpu: 10m
  memory: 32Mi
limits:
  cpu: 100m
  memory: 128Mi
{{- end }}
{{- end }}
