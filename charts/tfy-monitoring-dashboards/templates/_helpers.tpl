{{/*
===========================================================================
  tfy-nats-ui helpers
===========================================================================
*/}}

{{- define "tfy-monitoring-dashboards.nats-ui.name" -}}
{{- default "tfy-nats-ui" .Values.tfyNatsUi.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.fullname" -}}
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

{{- define "tfy-monitoring-dashboards.nats-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-monitoring-dashboards.nats-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-nats-ui
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.labels" -}}
helm.sh/chart: {{ include "tfy-monitoring-dashboards.nats-ui.chart" . }}
{{ include "tfy-monitoring-dashboards.nats-ui.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.image" -}}
{{- $repo := required "tfyNatsUi.image.repository is required when tfyNatsUi.enabled is true" .Values.tfyNatsUi.image.repository }}
{{- $tag := .Values.tfyNatsUi.image.tag | default "latest" }}
{{- if .Values.tfyNatsUi.image.registry }}
{{- printf "%s/%s:%s" .Values.tfyNatsUi.image.registry $repo $tag }}
{{- else }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.parseEnv" -}}
{{- tpl ((.Values.tfyNatsUi.env | default dict) | toYaml) . }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.imagePullSecrets" -}}
{{- if .Values.tfyNatsUi.imagePullSecrets -}}
{{- toYaml .Values.tfyNatsUi.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.serviceAccountName" -}}
{{- if .Values.tfyNatsUi.serviceAccount.create -}}
{{- default (include "tfy-monitoring-dashboards.nats-ui.fullname" .) .Values.tfyNatsUi.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.tfyNatsUi.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "tfy-monitoring-dashboards.nats-ui.env" -}}
{{- range $key, $val := (include "tfy-monitoring-dashboards.nats-ui.parseEnv" .) | fromYaml }}
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

{{- define "tfy-monitoring-dashboards.metrics-dashboard.name" -}}
{{- default "tfy-metrics-dashboard" .Values.tfyMetricsDashboard.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tfy-monitoring-dashboards.metrics-dashboard.fullname" -}}
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

{{- define "tfy-monitoring-dashboards.metrics-dashboard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-monitoring-dashboards.metrics-dashboard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-metrics-dashboard
{{- end }}

{{- define "tfy-monitoring-dashboards.metrics-dashboard.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "tfy-monitoring-dashboards.metrics-dashboard.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "tfy-monitoring-dashboards.metrics-dashboard.image" -}}
{{- $tag := .Values.tfyMetricsDashboard.image.tag | toString -}}
{{- if .Values.tfyMetricsDashboard.image.registry -}}
{{- printf "%s/%s:%s" .Values.tfyMetricsDashboard.image.registry .Values.tfyMetricsDashboard.image.repository $tag -}}
{{- else -}}
{{- printf "%s/%s:%s" "ghcr.io" .Values.tfyMetricsDashboard.image.repository $tag -}}
{{- end -}}
{{- end }}

{{- define "tfy-monitoring-dashboards.metrics-dashboard.serviceAccountName" -}}
{{- if .Values.tfyMetricsDashboard.serviceAccount.create -}}
{{- default (include "tfy-monitoring-dashboards.metrics-dashboard.fullname" .) .Values.tfyMetricsDashboard.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.tfyMetricsDashboard.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "tfy-monitoring-dashboards.metrics-dashboard.resources" -}}
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
