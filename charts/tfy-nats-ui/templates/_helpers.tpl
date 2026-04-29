{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-nats-ui.name" -}}
{{- default "tfy-nats-ui" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tfy-nats-ui.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-nats-ui" .Values.nameOverride }}
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
{{- define "tfy-nats-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tfy-nats-ui.labels" -}}
helm.sh/chart: {{ include "tfy-nats-ui.chart" . }}
{{ include "tfy-nats-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tfy-nats-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-nats-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: tfy-nats-ui
{{- end }}

{{/*
Container image reference.
*/}}
{{- define "tfy-nats-ui.image" -}}
{{- $repo := required "image.repository is required when enabled is true" .Values.image.repository }}
{{- $tag := .Values.image.tag | default "latest" }}
{{- if .Values.image.registry }}
{{- printf "%s/%s:%s" .Values.image.registry $repo $tag }}
{{- else }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
{{- end }}

{{/*
  Parse env after Helm tpl (same pattern as servicefoundryServer.env in the truefoundry chart).
*/}}
{{- define "tfy-nats-ui.parseEnv" -}}
{{- tpl ((.Values.env | default dict) | toYaml) . }}
{{- end }}

{{- define "tfy-nats-ui.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
  Service account name for the workload (same pattern as tfy-cloudflared).
*/}}
{{- define "tfy-nats-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-nats-ui.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
  Build container env list from env with ${k8s-secret/...} expansion.
  Two-part form: ${k8s-secret/<key>} uses envSecretName as the Secret name.
  Three-part form: ${k8s-secret/<secretName>/<key>}
*/}}
{{- define "tfy-nats-ui.env" -}}
{{- range $key, $val := (include "tfy-nats-ui.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ required "envSecretName is required when using ${k8s-secret/<key>} in env" $.Values.envSecretName }}
      key: {{ index (regexSplit "/" $val -1) 1 | trimSuffix "}" }}
{{- else if eq (regexSplit "/" $val -1 | len) 3 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ index (regexSplit "/" $val -1) 1 }}
      key: {{ index (regexSplit "/" $val -1) 2 | trimSuffix "}" }}
{{- else }}
{{- fail "Invalid k8s-secret reference in env (use ${k8s-secret/<key>} with envSecretName, or ${k8s-secret/<secret>/<key>})" }}
{{- end }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}
