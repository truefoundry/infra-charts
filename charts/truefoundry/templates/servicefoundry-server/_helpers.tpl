{{/*
Expand the name of the chart.
*/}}
{{- define "servicefoundry-server.name" -}}
{{- default "servicefoundry-server" .Values.servicefoundryServer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "servicefoundry-server.fullname" -}}
{{- if .Values.servicefoundryServer.fullnameOverride }}
{{- .Values.servicefoundryServer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "servicefoundry-server" .Values.servicefoundryServer.nameOverride }}
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
{{- define "servicefoundry-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "servicefoundry-server.labels" -}}
helm.sh/chart: {{ include "servicefoundry-server.chart" . }}
{{- range $name, $value := .Values.servicefoundryServer.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{ include "servicefoundry-server.selectorLabels" . }}
{{- if .Values.servicefoundryServer.imageTag }}
app.kubernetes.io/version: {{ .Values.servicefoundryServer.imageTag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "servicefoundry-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "servicefoundry-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "servicefoundry-server.serviceAccountName" -}}
{{- default (include "servicefoundry-server.fullname" .) "servicefoundry-server" }}

{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "servicefoundry-server.parseEnv" -}}
{{ tpl (.Values.servicefoundryServer.env | toYaml) . }}

{{- end }}

{{/*
  Create the env file
  */}}
{{- define "servicefoundry-server.env" }}
{{- range $key, $val := (include "servicefoundry-server.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.servicefoundryServer.envSecretName }}
      key: {{ index (regexSplit "/" $val -1) 1 | trimSuffix "}" }}
{{- else if eq (regexSplit "/" $val -1 | len) 3 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ index (regexSplit "/" $val -1) 1 }}
      key: {{ index (regexSplit "/" $val -1) 2 | trimSuffix "}" }}
{{- else }}
{{- fail "Invalid secret supplied" }}
{{- end }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.cicdTemplates .) }}
- name: CICD_TEMPLATES_DIRECTORY
  value: /opt/truefoundry/configs/cicd-templates
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.workbenchImages .) }}
- name: WORKBENCH_IMAGES_CONFIG_PATH
  value: /opt/truefoundry/configs/workbench-images/workbench-images.yaml
{{- end }}
{{- end }}

{{- define "servicefoundry-server.volumes" -}}
{{- $volumes := list -}}
{{- if .Values.servicefoundryServer.extraVolumes }}
  {{- range .Values.servicefoundryServer.extraVolumes }}
    {{- $volumes = append $volumes . }}
  {{- end }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.cicdTemplates .) }}
  {{- $volumes = append $volumes (dict "name" "configs-cicd-templates" "configMap" (dict "name" (tpl .Values.servicefoundryServer.configs.cicdTemplates .))) }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.workbenchImages .) }}
  {{- $volumes = append $volumes (dict "name" "configs-workbench-images" "configMap" (dict "name" (tpl .Values.servicefoundryServer.configs.workbenchImages .))) }}
{{- end }}

{{- $volumes | toYaml -}}
{{- end -}}


{{- define "servicefoundry-server.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- if .Values.servicefoundryServer.extraVolumeMounts }}
  {{- range .Values.servicefoundryServer.extraVolumeMounts }}
    {{- $volumeMounts = append $volumeMounts . }}
  {{- end }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.cicdTemplates .) }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-cicd-templates" "mountPath" "/opt/truefoundry/configs/cicd-templates") }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.workbenchImages .) }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-workbench-images" "mountPath" "/opt/truefoundry/configs/workbench-images") }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{/*
  Merge default nodeSelector with nodeSelector specified in servicefoundry-server nodeSelector
  */}}
{{- define "servicefoundry-server.nodeSelector" -}}
{{- $defaultNodeSelector := dict "kubernetes.io/arch" "amd64" }}
{{- $mergedNodeSelector := merge $defaultNodeSelector .Values.servicefoundryServer.nodeSelector }}
{{- toYaml $mergedNodeSelector }}
{{- end }}
