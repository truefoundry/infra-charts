{{/*
Expand the name of the chart.
*/}}
{{- define "truefoundry-monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | lower | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "truefoundry-monitoring.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride | lower }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | lower |trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | lower | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "truefoundry-monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | lower | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "truefoundry-monitoring.labels" -}}
helm.sh/chart: {{ include "truefoundry-monitoring.chart" . }}
{{ include "truefoundry-monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "truefoundry-monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "truefoundry-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Control plane namespace
*/}}
{{- define "truefoundry-monitoring.controlPlaneNamespace" -}}
{{- default "truefoundry" .Values.global.controlPlaneNamespace }}
{{- end }}

{{/*
Grafana datasource sidecar labels (common labels + discovery label).
*/}}
{{- define "truefoundry-monitoring.grafana.datasourceLabels" -}}
{{ include "truefoundry-monitoring.labels" . }}
{{ .Values.grafana.sidecar.datasources.label }}: {{ .Values.grafana.sidecar.datasources.labelValue | quote }}
{{- end -}}

{{/*
Grafana dashboard sidecar labels (common labels + discovery label).
*/}}
{{- define "truefoundry-monitoring.grafana.dashboardLabels" -}}
{{ include "truefoundry-monitoring.labels" . }}
{{ .Values.grafana.sidecar.dashboards.label }}: {{ .Values.grafana.sidecar.dashboards.labelValue | quote }}
{{- end -}}

{{/*
Replicate prometheus.server.fullname from the prometheus subchart.
See: prometheus/templates/_helpers.tpl
*/}}
{{- define "truefoundry-monitoring.prometheus.serverFullname" -}}
{{- if .Values.prometheus.server.fullnameOverride -}}
{{- .Values.prometheus.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "prometheus" .Values.prometheus.nameOverride -}}
{{- $serverName := default "server" .Values.prometheus.server.name -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name $serverName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name $serverName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Prometheus in-cluster service name (<release>-server by default).
*/}}
{{- define "truefoundry-monitoring.prometheus.serviceName" -}}
{{- include "truefoundry-monitoring.prometheus.serverFullname" . -}}
{{- end -}}

{{/*
VictoriaLogs server service name.
The victoria-logs-single chart (nested inside tfy-logs) uses the standard Helm
fullname (<release>-victoria-logs-single) with a "-server" suffix for its service.
*/}}
{{- define "truefoundry-monitoring.logs.serviceName" -}}
{{- printf "%s-victoria-logs-single-server" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
===========================================================================
  headlamp helpers
===========================================================================
*/}}

{{/*
  Replicate headlamp's serviceAccountName logic so our ClusterRoleBinding
  always references the exact SA the subchart creates.
*/}}
{{- define "truefoundry-monitoring.headlamp.serviceAccountName" -}}
{{- if .Values.headlamp.serviceAccount.name -}}
  {{- .Values.headlamp.serviceAccount.name -}}
{{- else if .Values.headlamp.fullnameOverride -}}
  {{- .Values.headlamp.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $chartName := .Values.headlamp.nameOverride | default "headlamp" -}}
  {{- if contains $chartName .Release.Name -}}
    {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" .Release.Name $chartName | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
===========================================================================
  nats-ui helpers
===========================================================================
*/}}

{{- define "truefoundry-monitoring.nats-ui.name" -}}
{{- default "tfy-nats-ui" .Values.tfyNatsUi.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.fullname" -}}
{{- if .Values.tfyNatsUi.fullnameOverride }}
{{- .Values.tfyNatsUi.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-nats-ui" .Values.tfyNatsUi.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "truefoundry-monitoring.nats-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-nats-ui
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.labels" -}}
helm.sh/chart: {{ include "truefoundry-monitoring.nats-ui.chart" . }}
{{ include "truefoundry-monitoring.nats-ui.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.image" -}}
{{- $repo := required "tfyNatsUi.image.repository is required when tfyNatsUi.enabled is true" .Values.tfyNatsUi.image.repository }}
{{- $tag := .Values.tfyNatsUi.image.tag | default "latest" }}
{{- if .Values.tfyNatsUi.image.registry }}
{{- printf "%s/%s:%s" .Values.tfyNatsUi.image.registry $repo $tag }}
{{- else }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.parseEnv" -}}
{{- tpl ((.Values.tfyNatsUi.env | default dict) | toYaml) . }}
{{- end }}

{{- define "truefoundry-monitoring.imagePullSecrets" -}}
{{- $componentSecrets := index . 0 -}}
{{- $ctx := index . 1 -}}
{{- if $componentSecrets -}}
{{- toYaml $componentSecrets }}
{{- else if $ctx.Values.global.imagePullSecrets -}}
{{- toYaml $ctx.Values.global.imagePullSecrets }}
{{- else if $ctx.Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.serviceAccountName" -}}
{{- if .Values.tfyNatsUi.serviceAccount.create -}}
{{- default (include "truefoundry-monitoring.nats-ui.fullname" .) .Values.tfyNatsUi.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.tfyNatsUi.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "truefoundry-monitoring.nats-ui.env" -}}
{{- range $key, $val := (include "truefoundry-monitoring.nats-ui.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ required "tfyNatsUi.envSecretName is required when using ${k8s-secret/<key>} in env" $.Values.tfyNatsUi.envSecretName }}
      key: {{ index (regexSplit "/" $val -1) 1 | trimSuffix "}" }}
{{- else if eq (regexSplit "/" $val -1 | len) 3 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ index (regexSplit "/" $val -1) 1 }}
      key: {{ index (regexSplit "/" $val -1) 2 | trimSuffix "}" }}
{{- else }}
{{- fail "Invalid k8s-secret reference in tfyNatsUi.env" }}
{{- end }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
===========================================================================
  tfy-metrics-dashboard helpers
===========================================================================
*/}}

{{- define "truefoundry-monitoring.metrics-dashboard.name" -}}
{{- default "tfy-metrics-dashboard" .Values.tfyMetricsDashboard.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.fullname" -}}
{{- if .Values.tfyMetricsDashboard.fullnameOverride }}
{{- .Values.tfyMetricsDashboard.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-metrics-dashboard" .Values.tfyMetricsDashboard.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "truefoundry-monitoring.metrics-dashboard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-metrics-dashboard
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "truefoundry-monitoring.metrics-dashboard.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.image" -}}
{{- $tag := .Values.tfyMetricsDashboard.image.tag | toString -}}
{{- if .Values.tfyMetricsDashboard.image.registry -}}
{{- printf "%s/%s:%s" .Values.tfyMetricsDashboard.image.registry .Values.tfyMetricsDashboard.image.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.tfyMetricsDashboard.image.repository $tag -}}
{{- end -}}
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.serviceAccountName" -}}
{{- if .Values.tfyMetricsDashboard.serviceAccount.create -}}
{{- default (include "truefoundry-monitoring.metrics-dashboard.fullname" .) .Values.tfyMetricsDashboard.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.tfyMetricsDashboard.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "truefoundry-monitoring.metrics-dashboard.resources" -}}
{{- if .Values.tfyMetricsDashboard.resources -}}
{{- toYaml .Values.tfyMetricsDashboard.resources -}}
{{- else -}}
requests:
  cpu: 10m
  memory: 32Mi
limits:
  cpu: 100m
  memory: 128Mi
{{- end }}
{{- end }}

