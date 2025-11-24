{{/* vim: set filetype=mustache: */}}
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
{{- include "truefoundry.labels" (dict "context" . "name" "truefoundry-virtualservice") }}
{{- end }}

{{/*
  Truefoundry virtualService annotations
  */}}
{{- define "truefoundry.virtualservice.annotations" -}}
{{- include "global.annotations" . -}}
{{- with .Values.global.virtualservice.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}


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
