{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

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

{{/*
  Base labels
*/}}
{{- define "tfy-sandbox-server.labels" -}}
helm.sh/chart: {{ include "tfy-sandbox-server.chart" . }}
{{ include "tfy-sandbox-server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
{{- end -}}

{{- define "tfy-sandbox-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-sandbox-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
  Common labels - merges global.labels with component-specific labels
*/}}
{{- define "tfy-sandbox-server.commonLabels" -}}
{{- $baseLabels := include "tfy-sandbox-server.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end -}}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
*/}}
{{- define "tfy-sandbox-server.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
  Deployment Labels
*/}}
{{- define "tfy-sandbox-server.deploymentLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end -}}

{{/*
  Deployment Annotations
*/}}
{{- define "tfy-sandbox-server.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end -}}

{{/*
  Pod Labels
*/}}
{{- define "tfy-sandbox-server.podLabels" -}}
{{- $selectorLabels := include "tfy-sandbox-server.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end -}}

{{/*
  Pod Annotations
*/}}
{{- define "tfy-sandbox-server.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end -}}

{{/*
  Service Labels
*/}}
{{- define "tfy-sandbox-server.serviceLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end -}}

{{/*
  Service Annotations
*/}}
{{- define "tfy-sandbox-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end -}}

{{/*
  Service Account Labels
*/}}
{{- define "tfy-sandbox-server.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end -}}

{{/*
  Service Account Annotations
*/}}
{{- define "tfy-sandbox-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end -}}

{{/*
  PDB Labels
*/}}
{{- define "tfy-sandbox-server.pdbLabels" -}}
{{- $commonLabels := include "tfy-sandbox-server.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.pdb.labels }}
{{- toYaml $pdbLabels }}
{{- end -}}

{{/*
  PDB Annotations
*/}}
{{- define "tfy-sandbox-server.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-sandbox-server.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.pdb.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end -}}

{{/*
  Service Account Name
*/}}
{{- define "tfy-sandbox-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-sandbox-server.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.serviceAccount.name | default .Values.global.serviceAccount.name | default "default" -}}
{{- end -}}
{{- end -}}

{{/*
  Image
*/}}
{{- define "tfy-sandbox-server.image" -}}
{{- printf "%s/%s:%s" (.Values.image.registry | default .Values.global.image.registry) .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
  imagePullSecrets
*/}}
{{- define "tfy-sandbox-server.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end -}}

{{/*
  Affinity
*/}}
{{- define "tfy-sandbox-server.affinity" -}}
{{- if .Values.affinity -}}
{{ toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end -}}

{{/*
  Tolerations
*/}}
{{- define "tfy-sandbox-server.tolerations" -}}
{{- if .Values.tolerations -}}
{{ toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end -}}

{{/*
  Node Selector
*/}}
{{- define "tfy-sandbox-server.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end -}}

{{/*
  Custom CA validation
*/}}
{{- define "tfy-sandbox-server.customCA.validate" -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- end -}}

{{/*
  Whether to use direct mount (true) or initContainer merge (false)
*/}}
{{- define "tfy-sandbox-server.customCA.useDirectMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
  Custom CA ConfigMap name
*/}}
{{- define "tfy-sandbox-server.customCA.configMapName" -}}
{{- include "tfy-sandbox-server.customCA.validate" . -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- include "tfy-sandbox-server.fullname" . }}-custom-ca
{{- end -}}
{{- end -}}

{{/*
  Custom CA initContainer (only when not using direct mount)
*/}}
{{- define "tfy-sandbox-server.customCA.initContainer" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-sandbox-server.customCA.useDirectMount" .) "false" }}
- name: configure-custom-ca
  image: "{{ .Values.global.customCA.image.registry | default .Values.global.image.registry }}/{{ .Values.global.customCA.image.repository }}:{{ .Values.global.customCA.image.tag }}"
  {{- if .Values.global.customCA.securityContext.enabled }}
  {{- with .Values.global.customCA.securityContext }}
  securityContext:
    {{- toYaml (omit . "enabled") | nindent 4 }}
  {{- end }}
  {{- end }}
  command: ["sh", "-c"]
  args:
    - |
      set -e
      cat /etc/ssl/certs/ca-certificates.crt /custom-ca/ca-certificates.crt > /ssl-certs/ca-certificates.crt
  {{- with .Values.global.customCA.env }}
  env:
    {{- range $key, $val := . }}
    - name: {{ $key }}
      value: {{ $val | quote }}
    {{- end }}
  {{- end }}
  volumeMounts:
    - name: custom-ca
      mountPath: /custom-ca
      readOnly: true
    - name: ssl-certs
      mountPath: /ssl-certs
{{- end }}
{{- end }}
{{- end -}}

{{/*
  Custom CA volumes
*/}}
{{- define "tfy-sandbox-server.customCA.volumes" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-sandbox-server.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-sandbox-server.customCA.configMapName" . }}
{{- else }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-sandbox-server.customCA.configMapName" . }}
- name: ssl-certs
  emptyDir:
    sizeLimit: {{ .Values.global.customCA.emptyDir.sslCerts.sizeLimit | default "10Mi" }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
  Custom CA volume mounts for app containers
*/}}
{{- define "tfy-sandbox-server.customCA.volumeMounts" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-sandbox-server.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  mountPath: /etc/ssl/certs
  readOnly: true
{{- else }}
- name: ssl-certs
  mountPath: /etc/ssl/certs
  readOnly: true
{{- end }}
{{- end }}
{{- end -}}
