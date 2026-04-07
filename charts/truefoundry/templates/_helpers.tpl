{{/* vim: set filetype=mustache: */}}
{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

{{/*
  Global Labels
*/}}
{{- define "global.labels" }}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Global Annotations
*/}}
{{- define "global.annotations" }}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "global.serviceAccountAnnotations" -}}
{{- if .Values.global.serviceAccount.annotations }}
{{ toYaml .Values.global.serviceAccount.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{- define "global.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets -}}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end }}
{{/*
Expand the name of the chart.
*/}}
{{- define "truefoundry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "truefoundry.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "truefoundry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Argo CD app version
*/}}
{{- define "truefoundry.defaultTag" -}}
{{- .Chart.AppVersion }}
{{- end -}}

{{/*
Return valid version label
*/}}
{{- define "truefoundry.versionLabelValue" -}}
{{ regexReplaceAll "[^-A-Za-z0-9_.]" (include "truefoundry.defaultTag" .) "-" | trunc 63 | trimAll "-" | trimAll "_" | trimAll "." | quote }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "truefoundry.labels" -}}
helm.sh/chart: {{ include "truefoundry.chart" .context }}
{{ include "truefoundry.selectorLabels" (dict "context" .context "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: truefoundry
app.kubernetes.io/version: {{ include "truefoundry.versionLabelValue" .context }}
{{- with .context.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "truefoundry.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end }}  

{{/*
Global Ingress fullname
*/}}
{{- define "truefoundry.ingress.fullname" -}}
{{- if .Values.global.ingress.fullnameOverride -}}
{{- .Values.global.ingress.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "ingress" .Values.global.ingress.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  Ingress labels - uses global truefoundry.labels function
  */}}
{{- define "truefoundry.ingress.labels" -}}
{{- $base := include "truefoundry.labels" (dict "context" . "name" "truefoundry-ingress") | fromYaml -}}
{{- $ingressLabels := mergeOverwrite $base (deepCopy .Values.global.ingress.labels) -}}
{{- toYaml $ingressLabels -}}
{{- end -}}

{{/*
  Ingress annotations
  */}}
{{- define "truefoundry.ingress.annotations" -}}
{{- $ingressAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.global.ingress.annotations }}
{{- toYaml $ingressAnnotations }}
{{- end }}

{{/*
  Workflow Ingress Labels
*/}}
{{- define "truefoundry.ingress.workflow.labels" -}}
{{- $base := include "truefoundry.labels" (dict "context" . "name" "truefoundry-workflow-ingress") | fromYaml -}}
{{- $workflowIngressLabels := mergeOverwrite $base (deepCopy .Values.global.ingress.workflow.labels) -}}
{{- toYaml $workflowIngressLabels -}}
{{- end -}}

{{/*
  Workflow Ingress Annotations
  */}}
{{- define "truefoundry.ingress.workflow.annotations" -}}
{{- $workflowIngressAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.global.ingress.workflow.annotations }}
{{- toYaml $workflowIngressAnnotations }}
{{- end }}

{{/*
Truefoundry virtual service fullname
*/}}
{{- define "truefoundry.virtualservice.fullname" -}}
{{- if .Values.global.virtualservice.fullnameOverride -}}
{{- .Values.global.virtualservice.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "virtualservice" .Values.global.virtualservice.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  VirtualService labels
  */}}
{{- define "truefoundry.virtualservice.labels" -}}
{{- $base := include "truefoundry.labels" (dict "context" . "name" "truefoundry-virtualservice") | fromYaml -}}
{{- $virtualServiceLabels := mergeOverwrite $base (deepCopy .Values.global.virtualservice.labels) -}}
{{- toYaml $virtualServiceLabels -}}
{{- end -}}

{{/*
  Truefoundry virtualService annotations
  */}}
{{- define "truefoundry.virtualservice.annotations" -}}
{{- $virtualServiceAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.global.virtualservice.annotations }}
{{- toYaml $virtualServiceAnnotations }}
{{- end }}


{{/*
  Custom CA validation
*/}}
{{- define "truefoundry.customCA.validate" -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- end -}}

{{/*
  Whether to use direct mount (true) or initContainer merge (false)
*/}}
{{- define "truefoundry.customCA.useDirectMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
  Custom CA ConfigMap name
*/}}
{{- define "truefoundry.customCA.configMapName" -}}
{{- include "truefoundry.customCA.validate" . -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- include "truefoundry.fullname" . }}-custom-ca
{{- end -}}
{{- end -}}

{{/*
  Custom CA initContainer (only when not using direct mount)
*/}}
{{- define "truefoundry.customCA.initContainer" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "truefoundry.customCA.useDirectMount" .) "false" }}
- name: configure-custom-ca
  image: "{{ .Values.global.customCA.image.registry | default .Values.global.image.registry }}/{{ .Values.global.customCA.image.repository }}:{{ .Values.global.customCA.image.tag }}"
  command: ["sh", "-c"]
  args:
    - |
      set -e
      apk add --no-cache ca-certificates
      cp /custom-ca/ca-certificates.crt /usr/local/share/ca-certificates/custom-ca.crt
      update-ca-certificates
      cp /etc/ssl/certs/ca-certificates.crt /ssl-certs/ca-certificates.crt
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
  - Direct mount: just the ConfigMap
  - InitContainer merge: ConfigMap + emptyDir
*/}}
{{- define "truefoundry.customCA.volumes" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "truefoundry.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  configMap:
    name: {{ include "truefoundry.customCA.configMapName" . }}
{{- else }}
- name: custom-ca
  configMap:
    name: {{ include "truefoundry.customCA.configMapName" . }}
- name: ssl-certs
  emptyDir:
    medium: Memory
{{- end }}
{{- end }}
{{- end -}}

{{/*
  Custom CA volume mounts for app containers
  - Direct mount: ConfigMap mounted at /etc/ssl/certs
  - InitContainer merge: emptyDir mounted at /etc/ssl/certs
*/}}
{{- define "truefoundry.customCA.volumeMounts" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "truefoundry.customCA.useDirectMount" .) "true" }}
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

{{/*
  Custom CA volume items as JSON-wrapped list for use in list-building helpers.
  Usage:
    {{- $caData := include "truefoundry.customCA.volumeItems" . | fromJson -}}
    {{- $volumes = concat $volumes $caData.items -}}
*/}}
{{- define "truefoundry.customCA.volumeItems" -}}
{{- $items := list -}}
{{- if .Values.global.customCA.enabled -}}
  {{- $items = append $items (dict "name" "custom-ca" "configMap" (dict "name" (include "truefoundry.customCA.configMapName" .))) -}}
  {{- if eq (include "truefoundry.customCA.useDirectMount" .) "false" -}}
    {{- $items = append $items (dict "name" "ssl-certs" "emptyDir" (dict "medium" "Memory")) -}}
  {{- end -}}
{{- end -}}
{{- dict "items" $items | toJson -}}
{{- end -}}

{{/*
  Custom CA volumeMount items as JSON-wrapped list for use in list-building helpers.
  Usage:
    {{- $caData := include "truefoundry.customCA.volumeMountItems" . | fromJson -}}
    {{- $volumeMounts = concat $volumeMounts $caData.items -}}
*/}}
{{- define "truefoundry.customCA.volumeMountItems" -}}
{{- $items := list -}}
{{- if .Values.global.customCA.enabled -}}
  {{- if eq (include "truefoundry.customCA.useDirectMount" .) "true" -}}
    {{- $items = append $items (dict "name" "custom-ca" "mountPath" "/etc/ssl/certs" "readOnly" true) -}}
  {{- else -}}
    {{- $items = append $items (dict "name" "ssl-certs" "mountPath" "/etc/ssl/certs" "readOnly" true) -}}
  {{- end -}}
{{- end -}}
{{- dict "items" $items | toJson -}}
{{- end -}}

{{/*
  Custom CA environment variables for Node.js containers
*/}}
{{- define "truefoundry.customCA.env" -}}
{{- if .Values.global.customCA.enabled }}
- name: NODE_EXTRA_CA_CERTS
  value: /etc/ssl/certs/ca-certificates.crt
{{- end }}
{{- end -}}

{{- define "truefoundry.storage-credentials" }}
{{- if .Values.global.config.defaultCloudProvider }}
CLOUD_PROVIDER: {{ .Values.global.config.defaultCloudProvider }}
DEFAULT_CLOUD_PROVIDER: {{ .Values.global.config.defaultCloudProvider }}
{{- end }}
{{- if eq .Values.global.config.defaultCloudProvider "aws" }}
{{- if .Values.global.config.storageConfiguration.awsS3BucketName }}
S3_BUCKET_NAME: {{ .Values.global.config.storageConfiguration.awsS3BucketName }}
BLOB_STORAGE_PATH: s3://{{ .Values.global.config.storageConfiguration.awsS3BucketName }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsRegion }}
AWS_REGION: {{ .Values.global.config.storageConfiguration.awsRegion }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsAccessKeyId }}
AWS_ACCESS_KEY_ID: {{ .Values.global.config.storageConfiguration.awsAccessKeyId }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsSecretAccessKey }}
AWS_SECRET_ACCESS_KEY: {{ .Values.global.config.storageConfiguration.awsSecretAccessKey }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsEndpointURL }}
AWS_ENDPOINT_URL: {{ .Values.global.config.storageConfiguration.awsEndpointURL }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsAllowHttp }}
AWS_ALLOW_HTTP: {{ .Values.global.config.storageConfiguration.awsAllowHttp }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.awsAssumeRoleArn }}
AWS_ROLE_ARN: {{ .Values.global.config.storageConfiguration.awsAssumeRoleArn }}
AWS_ASSUME_ROLE_ARN: {{ .Values.global.config.storageConfiguration.awsAssumeRoleArn }}
{{- end }}
{{- end }}
{{- if eq .Values.global.config.defaultCloudProvider "gcp" }}
{{- if .Values.global.config.storageConfiguration.googleCloudStorageBucketName }}
GS_BUCKET_NAME: {{ .Values.global.config.storageConfiguration.googleCloudStorageBucketName }}
BLOB_STORAGE_PATH: gs://{{ .Values.global.config.storageConfiguration.googleCloudStorageBucketName }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.googleCloudProjectId }}
GCP_PROJECT_ID: {{ .Values.global.config.storageConfiguration.googleCloudProjectId }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.googleCloudServiceAccountKeyFileContent }}
# Here single quotes are very important to keep the value as json string
GCP_SERVICE_ACCOUNT_KEY_FILE_CONTENT: '{{ .Values.global.config.storageConfiguration.googleCloudServiceAccountKeyFileContent }}'
GOOGLE_SERVICE_ACCOUNT_KEY: '{{ .Values.global.config.storageConfiguration.googleCloudServiceAccountKeyFileContent }}'
{{- end }}
{{- end }}
{{- if eq .Values.global.config.defaultCloudProvider "azure" }}
{{- if .Values.global.config.storageConfiguration.azureBlobUri }}
AZURE_BLOB_URI: {{ .Values.global.config.storageConfiguration.azureBlobUri }}
BLOB_STORAGE_PATH: {{ .Values.global.config.storageConfiguration.azureBlobUri }}
{{- end }}
{{- if .Values.global.config.storageConfiguration.azureBlobConnectionString }}
AZURE_BLOB_CONNECTION_STRING: {{ .Values.global.config.storageConfiguration.azureBlobConnectionString }}
AZURE_STORAGE_CONNECTION_STRING: {{ .Values.global.config.storageConfiguration.azureBlobConnectionString }}
{{- end }}
{{- end }}
{{- end }}
