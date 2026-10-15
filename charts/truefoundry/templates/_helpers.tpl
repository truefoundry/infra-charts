{{/* vim: set filetype=mustache: */}}
{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

{{/*
  mTLS volume, injected into every enabled service's pod spec.
  Emits nothing unless global.mTLS.enabled, so appending its include after each
  deployment's existing volumes is a no-op when disabled. Mounts the external secret
  when global.mTLS.externalMtlsSecret is set, otherwise the bootstrap-created secret.
*/}}
{{- define "truefoundry.mtlsVolume" -}}
{{- if .Values.global.mTLS.enabled }}
- name: truefoundry-mtls
  secret:
    secretName: {{ .Values.global.mTLS.externalMtlsSecret | default .Values.global.mTLS.tlsSecretName }}
    optional: true
{{- end }}
{{- end -}}

{{/*
  mTLS volumeMount, paired with truefoundry.mtlsVolume. Fixed mount path.
*/}}
{{- define "truefoundry.mtlsVolumeMount" -}}
{{- if .Values.global.mTLS.enabled }}
- name: truefoundry-mtls
  mountPath: /etc/tls/truefoundry
  readOnly: true
{{- end }}
{{- end -}}

{{/*
  mTLS volume as a JSON {items: [...]} for helpers that build a $volumes list and toYaml it.
  Empty items when disabled. Concat into the list before the final toYaml, e.g.
    {{- $mtls := include "truefoundry.mtlsVolumeItems" . | fromJson -}}
    {{- $volumes = concat $volumes $mtls.items -}}
*/}}
{{- define "truefoundry.mtlsVolumeItems" -}}
{{- $items := list -}}
{{- if .Values.global.mTLS.enabled -}}
{{- $items = append $items (dict "name" "truefoundry-mtls" "secret" (dict "secretName" (.Values.global.mTLS.externalMtlsSecret | default .Values.global.mTLS.tlsSecretName) "optional" true)) -}}
{{- end -}}
{{- dict "items" $items | toJson -}}
{{- end -}}

{{/*
  mTLS volumeMount as a JSON {items: [...]}, paired with truefoundry.mtlsVolumeItems.
*/}}
{{- define "truefoundry.mtlsVolumeMountItems" -}}
{{- $items := list -}}
{{- if .Values.global.mTLS.enabled -}}
{{- $items = append $items (dict "name" "truefoundry-mtls" "mountPath" "/etc/tls/truefoundry" "readOnly" true) -}}
{{- end -}}
{{- dict "items" $items | toJson -}}
{{- end -}}

{{/*
  mTLS volume for build job / workflow pods. Uses global.mTLS as the source of truth.
  defaultMode 0444 because build containers may run as an arbitrary UID with no guaranteed
  fsGroup, so the key must be world-readable inside the pod.
*/}}
{{- define "truefoundry.mtlsVolumeForBuildJobs" -}}
{{- if .Values.global.mTLS.enabled }}
- name: truefoundry-mtls
  secret:
    secretName: {{ .Values.global.mTLS.externalMtlsSecret | default .Values.global.mTLS.tlsSecretName }}
    defaultMode: 0444
{{- end }}
{{- end -}}
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

{{/* Merged pod securityContext, local-over-global; "" when disabled. */}}
{{- define "truefoundry.podSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/* Merged container securityContext, local-over-global; "" when disabled. */}}
{{- define "truefoundry.containerSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/*
  Service account for components that need neither Kubernetes API access nor cloud identity.
  Falls back to global.serviceAccount.name when global.restrictedServiceAccount.enabled is false.
  */}}
{{- define "truefoundry.restrictedServiceAccountName" -}}
{{- if (.Values.global.restrictedServiceAccount | default dict).enabled -}}
{{- include "truefoundry.restrictedServiceAccountConfiguredName" . -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
  global.restrictedServiceAccount.name, whether or not the account is enabled. The only place its
  default is set in templates.
  */}}
{{- define "truefoundry.restrictedServiceAccountConfiguredName" -}}
{{- (.Values.global.restrictedServiceAccount | default dict).name | default "truefoundry-restricted" -}}
{{- end }}

{{/*
  "true" when Helm deploys the tfy-otel-collector subchart. As in Helm's dependency resolution, a
  boolean tfy-otel-collector.enabled (the condition) overrides the tags; otherwise any true tag
  enables it, all-false tags disable it, and no tags at all enable it.
  */}}
{{- define "truefoundry.otelCollectorEnabled" -}}
{{- $otel := index .Values "tfy-otel-collector" | default dict -}}
{{- if kindIs "bool" $otel.enabled -}}
{{- if $otel.enabled }}true{{ end -}}
{{- else -}}
{{- $tags := .Values.tags | default dict -}}
{{- $set := list -}}
{{- range $t := list "tracing" "llmGatewayRequestLogging" -}}
{{- if kindIs "bool" (index $tags $t) }}{{ $set = append $set (index $tags $t) }}{{ end -}}
{{- end -}}
{{- if or (has true $set) (empty $set) }}true{{ end -}}
{{- end -}}
{{- end }}

{{/*
  Fail when serviceAccount.annotations is set on a component that has no account of its own: the
  annotations (for example IRSA or workload identity) would be dropped without an error.
  */}}
{{- define "truefoundry.validateComponentServiceAccountAnnotations" -}}
{{- $components := list
  (dict "key" "tfyController" "own" (and .Values.tfyController.serviceAccount.create .Values.tfyController.serviceAccount.name) "account" (include "tfy-controller.serviceAccountName" .) "enabled" .Values.tfyController.enabled)
  (dict "key" "tfyK8sController" "own" (and .Values.tfyK8sController.serviceAccount.create .Values.tfyK8sController.serviceAccount.name) "account" (include "tfy-k8s-controller.serviceAccountName" .) "enabled" .Values.tfyK8sController.enabled)
  (dict "key" "sfyManifestService" "own" (and .Values.sfyManifestService.serviceAccount.create .Values.sfyManifestService.serviceAccount.name) "account" (include "sfy-manifest-service.serviceAccountName" .) "enabled" .Values.sfyManifestService.enabled)
  (dict "key" "tfyInfraManager" "own" (and .Values.tfyInfraManager.serviceAccount.create .Values.tfyInfraManager.serviceAccount.name) "account" (include "tfy-infra-manager.serviceAccountName" .) "enabled" .Values.tfyInfraManager.enabled)
  (dict "key" "tfyProxy" "own" .Values.tfyProxy.serviceAccount.create "account" (include "tfy-proxy.serviceAccountName" .) "enabled" .Values.tfyProxy.enabled) -}}
{{- $otel := index .Values "tfy-otel-collector" | default dict -}}
{{- $otelSA := $otel.serviceAccount | default dict -}}
{{- $components = append $components (dict "key" "tfy-otel-collector" "own" (and $otelSA.create $otelSA.name) "account" ($otelSA.name | default (include "truefoundry.restrictedServiceAccountName" .)) "enabled" (eq (include "truefoundry.otelCollectorEnabled" .) "true")) -}}
{{- range $c := $components -}}
{{- $sa := (index $.Values $c.key).serviceAccount | default dict -}}
{{- if and $c.enabled $sa.annotations (not $c.own) -}}
{{- fail (printf "%s.serviceAccount.annotations is set, but %s has no account of its own and runs on %q, so the annotations would not be applied. To give it its own account, set %s.serviceAccount.create: true and %s.serviceAccount.name. Otherwise remove the annotations." $c.key $c.key $c.account $c.key $c.key) -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
  Fail when the TrueForge sandbox server would run on a ServiceAccount that does not exist: a name that
  differs from global.restrictedServiceAccount.name, or the restricted account while it is disabled.
  */}}
{{- define "truefoundry.validateSandboxServiceAccount" -}}
{{- $tf := .Values.trueforge | default dict -}}
{{- $sa := dig "tfy-sandbox-server" "serviceAccount" dict $tf -}}
{{- if and $tf.enabled (dig "truefoundry" "devSandboxServerEnabled" false $tf) (not $sa.create) $sa.name -}}
{{- $restricted := .Values.global.restrictedServiceAccount | default dict -}}
{{- $restrictedName := include "truefoundry.restrictedServiceAccountConfiguredName" . -}}
{{- if and $restricted.enabled (ne $sa.name $restrictedName) -}}
{{- fail (printf "trueforge.tfy-sandbox-server.serviceAccount.name is %q but global.restrictedServiceAccount.name is %q, so the TrueForge sandbox server would run on an account that does not exist. Set it to %q, or to null to use global.serviceAccount.name." $sa.name $restrictedName $restrictedName) -}}
{{- else if and (not $restricted.enabled) (eq $sa.name $restrictedName) -}}
{{- fail (printf "trueforge.tfy-sandbox-server.serviceAccount.name is %q, but global.restrictedServiceAccount.enabled is false, so that account is not created. Set trueforge.tfy-sandbox-server.serviceAccount.name to null to use global.serviceAccount.name." $sa.name) -}}
{{- end -}}
{{- end -}}
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

{{/*
  Whether Sentry is enabled for the control plane.
  Forced to "false" when airgapped mode is enabled, otherwise "true".
*/}}
{{- define "truefoundry.sentryEnabled" -}}
{{- if and .Values.global.airgapped .Values.global.airgapped.enabled -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

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
Truefoundry HTTPRoute fullname
*/}}
{{- define "truefoundry.httproute.fullname" -}}
{{- if .Values.global.httpRoute.fullnameOverride -}}
{{- .Values.global.httpRoute.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "httproute" .Values.global.httpRoute.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  HTTPRoute labels
  */}}
{{- define "truefoundry.httproute.labels" -}}
{{- $base := include "truefoundry.labels" (dict "context" . "name" "truefoundry-httproute") | fromYaml -}}
{{- $httpRouteLabels := mergeOverwrite $base (deepCopy .Values.global.httpRoute.labels) -}}
{{- toYaml $httpRouteLabels -}}
{{- end -}}

{{/*
  HTTPRoute annotations
  */}}
{{- define "truefoundry.httproute.annotations" -}}
{{- $httpRouteAnnotations := mergeOverwrite (deepCopy .Values.global.annotations) .Values.global.httpRoute.annotations }}
{{- toYaml $httpRouteAnnotations }}
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
  {{- with (include "truefoundry.containerSecurityContext" (dict "local" .Values.global.customCA.securityContext "global" .Values.global.containerSecurityContext)) }}
  securityContext:
    {{- . | nindent 4 }}
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
    sizeLimit: {{ .Values.global.customCA.emptyDir.sslCerts.sizeLimit | default "10Mi" }}
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
    {{- $items = append $items (dict "name" "ssl-certs" "emptyDir" (dict "sizeLimit" (.Values.global.customCA.emptyDir.sslCerts.sizeLimit | default "10Mi"))) -}}
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

{{/*
Returns a tmp-dir emptyDir volume dict (as YAML) with sizeLimit matching the component's ephemeral-storage limit.
Usage with a resourceTier helper:
  include "truefoundry.tmpDirVolume" (dict "context" . "resourceTierHelper" "<component>.resourceTier" "defaultResourcesPrefix" "<component>.defaultResources" "resourcesValues" .Values.<component>.resources)
Usage without a resourceTier helper (pass tier value directly):
  include "truefoundry.tmpDirVolume" (dict "context" . "resourceTier" "medium" "defaultResourcesPrefix" "<component>.defaultResources" "resourcesValues" .Values.<component>.resources)
*/}}
{{- define "truefoundry.tmpDirVolume" -}}
{{- $ctx := .context -}}
{{- $tier := "" }}
{{- if .resourceTierHelper }}
  {{- $tier = include .resourceTierHelper $ctx | trim }}
{{- else }}
  {{- $tier = .resourceTier | default "medium" }}
{{- end }}
{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include (printf "%s.small" .defaultResourcesPrefix) $ctx }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include (printf "%s.medium" .defaultResourcesPrefix) $ctx }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include (printf "%s.large" .defaultResourcesPrefix) $ctx }}
{{- end }}
{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .resourcesValues | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}
{{- $limits := merge $overridesLimits $defaultsLimits }}
{{- $ephemeralLimit := index $limits "ephemeral-storage" }}
{{- dict "name" "tmp-dir" "emptyDir" (dict "sizeLimit" $ephemeralLimit) | toYaml -}}
{{- end -}}

{{/*
  Effective networkPolicy.mode: "legacy" or "perComponent". Empty (default) means legacy. Fails on
  any other value.
*/}}
{{- define "truefoundry.networkPolicyMode" -}}
{{- $mode := .Values.networkPolicy.mode | default "" -}}
{{- if eq $mode "" -}}
{{- $mode = "legacy" -}}
{{- else if not (has $mode (list "legacy" "perComponent")) -}}
{{- fail (printf "networkPolicy.mode must be empty, \"legacy\" or \"perComponent\", got %q" $mode) -}}
{{- end -}}
{{- $mode -}}
{{- end -}}

{{/*
  NetworkPolicy name for networkPolicy.mode: legacy, truncated to 63 characters as earlier chart versions did.
*/}}
{{- define "truefoundry.legacyNetworkPolicyName" -}}
{{- printf "%s-np-%s" (include "truefoundry.fullname" .context) .suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
NetworkPolicy resource name (max 63 chars).
Usage: include "truefoundry.networkPolicyName" (dict "context" . "suffix" "ing-tfy-proxy")
*/}}
{{- define "truefoundry.networkPolicyName" -}}
{{- $ctx := .context -}}
{{- $suffix := .suffix -}}
{{- $full := printf "%s-np-%s" (include "truefoundry.fullname" $ctx) $suffix -}}
{{- if le (len $full) 63 -}}
{{- $full -}}
{{- else -}}
{{- /* Plain truncation can collide (ing-<name> vs ing-<name>-<suffix>); keep a readable prefix plus a hash of the full name. */ -}}
{{- printf "%s-%s" ($full | trunc 54 | trimSuffix "-") ($full | sha256sum | trunc 8) -}}
{{- end -}}
{{- end -}}

{{/*
Render one NetworkPolicy ingress rule from a values entry.
Usage: include "truefoundry.networkPolicyIngressRule" (dict "rule" . "instance" $instance)

- ports: list of TCP ports (optional)
- from: list of same-release app.kubernetes.io/name values (optional)
- fromNamespaces: list of {namespace, podSelector?} cross-namespace sources (optional)

If neither `from` nor `fromNamespaces` is set, the rule allows all sources (any pod /
namespace / IP). If either key is present, only the listed sources are allowed.
When either key is present but both lists are empty (after dropping fromNamespaces
entries without `namespace`), the define returns empty so the caller can skip the rule.
*/}}
{{- define "truefoundry.networkPolicyIngressRule" -}}
{{- $rule := .rule -}}
{{- $instance := .instance -}}
{{- $ports := $rule.ports | default list -}}
{{- $fromPods := $rule.from | default list -}}
{{- $fromNS := list -}}
{{- range ($rule.fromNamespaces | default list) }}
{{- if .namespace }}
{{- $fromNS = append $fromNS . }}
{{- end }}
{{- end -}}
{{- $restrict := or (hasKey $rule "from") (hasKey $rule "fromNamespaces") -}}
{{- if and $restrict (not $fromPods) (not $fromNS) }}
{{- else }}
{{- if $ports }}
ports:
{{- range $ports }}
  - port: {{ int . }}
    protocol: TCP
{{- end }}
{{- end }}
{{- if $restrict }}
from:
{{- range $fromPods }}
  - podSelector:
      matchLabels:
        app.kubernetes.io/instance: {{ $instance | quote }}
        app.kubernetes.io/name: {{ . | quote }}
{{- end }}
{{- range $fromNS }}
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: {{ .namespace | quote }}
{{- with .podSelector }}
    podSelector:
      matchLabels:
        {{- toYaml . | nindent 8 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "networkPolicy.labels" -}}
{{- $standardLabels := include "truefoundry.labels" (dict "context" . "name" "network-policy") | fromYaml }}
{{- $baseLabels := mergeOverwrite $standardLabels (deepCopy .Values.global.labels) .Values.networkPolicy.labels }}
{{ toYaml $baseLabels }}
{{- end -}}

{{- define "networkPolicy.annotations" -}}
{{- with (include "networkPolicy.annotationsDict" . | fromJson) }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
global.annotations merged with networkPolicy.annotations, as JSON (always an object, "{}" when
both are empty or null) so callers can merge more keys without a YAML round-trip.
*/}}
{{- define "networkPolicy.annotationsDict" -}}
{{- mergeOverwrite (deepCopy (.Values.global.annotations | default dict)) (deepCopy (.Values.networkPolicy.annotations | default dict)) | toJson -}}
{{- end -}}

{{/*
Name the bundled Redis subchart gives its objects, mirroring common.names.fullname
from the Bitnami chart so the master Service name stays in sync with it.
*/}}
{{- define "truefoundry.redis.fullname" -}}
{{- if .Values.redis.fullnameOverride -}}
{{- .Values.redis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- $releaseName := regexReplaceAll "(-?[^a-z\\d\\-])+-?" (lower .Release.Name) "-" -}}
{{- if contains $name $releaseName -}}
{{- $releaseName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Shared control-plane Redis host.

`redis` (bundled) and `externalRedis` are mutually exclusive. TrueForge is the
only consumer today; the bundled LLM gateway can be pointed at the same instance
later so a CP+GP install does not run two Redises forever.

External Redis is active only when `externalRedis.enabled` is true. Host,
Sentinel, and externalSecret (the user sets trueforge.env; this chart creates
no Redis Secret) are the modes under it.
*/}}
{{- define "truefoundry.redis.useExternal" -}}
{{- if .Values.externalRedis.enabled -}}
true
{{- end -}}
{{- end -}}

{{- define "truefoundry.redis.externalSecret" -}}
{{- if eq (toString (.Values.externalRedis.externalSecret | default false)) "true" -}}
true
{{- end -}}
{{- end -}}

{{/*
"true" when value is ${k8s-secret/<secret>/<key>} with a non-empty secret and key.
The key must not contain "/".
*/}}
{{- define "truefoundry.redis.threePartRef" -}}
{{- $value := .value -}}
{{- if and (kindIs "string" $value) (hasPrefix "${k8s-secret/" $value) -}}
{{- $parts := regexSplit "/" (trimSuffix "}" $value) -1 -}}
{{- if eq (len $parts) 3 -}}
{{- if and (index $parts 1) (index $parts 2) -}}
true
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "truefoundry.redis.host" -}}
{{- if and .Values.redis.enabled (eq (include "truefoundry.redis.useExternal" .) "true") -}}
{{- fail "redis.enabled and externalRedis.enabled are mutually exclusive" -}}
{{- end -}}
{{- if eq (include "truefoundry.redis.useExternal" .) "true" -}}
{{- .Values.externalRedis.host -}}
{{- else if .Values.redis.enabled -}}
{{- printf "%s-master.%s.svc.cluster.local" (include "truefoundry.redis.fullname" .) (include "global.namespace" .) -}}
{{- end -}}
{{- end -}}

{{/*
Whether a control-plane Redis is configured at all: bundled, external by
host/sentinel, or externalSecret. Renders "true" or "".
*/}}
{{- define "truefoundry.redis.available" -}}
{{- if or .Values.redis.enabled (eq (include "truefoundry.redis.useExternal" .) "true") (eq (include "truefoundry.redis.externalSecret" .) "true") -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether the tfy-llm-gateway subchart is rendered: its `tfy-llm-gateway.enabled` condition when
set, else the `llmGateway` tag (Helm's precedence for dependency conditions over tags).
Renders "true" or "".
*/}}
{{- define "truefoundry.llmGateway.enabled" -}}
{{- $gw := index .Values "tfy-llm-gateway" | default dict -}}
{{- if hasKey $gw "enabled" -}}
{{- if $gw.enabled }}true{{ end -}}
{{- else if (.Values.tags | default dict).llmGateway -}}
true
{{- end -}}
{{- end -}}

{{/*
Name the upstream Vector chart gives its objects (mirrors vector.fullname).
Usage: include "truefoundry.vectorFullname" (dict "values" $vectorValues "release" .Release.Name)
*/}}
{{- define "truefoundry.vectorFullname" -}}
{{- $v := .values | default dict -}}
{{- if $v.fullnameOverride -}}
{{- $v.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "vector" $v.nameOverride -}}
{{- if contains $name .release -}}
{{- .release | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .release $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Fail when the gateway's Vector aggregator (tfy-llm-gateway.vector, StatefulSet) and the
truefoundryMonitoring log collector (truefoundryMonitoring.logs.victoria-logs-single.vector,
DaemonSet) get the same name. Both render a ServiceAccount <name> and a Service <name>-headless
in the release namespace, so one silently replaces the other: the log collector can lose its
API token (the gateway's account has automountToken: false), or the aggregator its headless Service.
*/}}
{{- define "truefoundry.validateVectorNames" -}}
{{- $gw := index .Values "tfy-llm-gateway" | default dict -}}
{{- $mon := .Values.truefoundryMonitoring | default dict -}}
{{- $logs := $mon.logs | default dict -}}
{{- $monVector := dig "victoria-logs-single" "vector" dict $logs -}}
{{- $gwOn := and (include "truefoundry.llmGateway.enabled" .) (dig "vector" "enabled" false $gw) -}}
{{- $monOn := and $mon.enabled (ne (toString $logs.enabled) "false") (ne (toString $monVector.enabled) "false") -}}
{{- if and $gwOn $monOn -}}
{{- $gwName := include "truefoundry.vectorFullname" (dict "values" ($gw.vector | default dict) "release" .Release.Name) -}}
{{- $monName := include "truefoundry.vectorFullname" (dict "values" $monVector "release" .Release.Name) -}}
{{- if eq $gwName $monName -}}
{{- fail (printf "tfy-llm-gateway.vector and the truefoundryMonitoring log collector both render as %q in namespace %q, so their ServiceAccount and Service collide. Rename one: set truefoundryMonitoring.logs.victoria-logs-single.vector.fullnameOverride (no data loss), or tfy-llm-gateway.vector.fullnameOverride (starts with empty buffer volumes; see README \"Vector name collision\")." $gwName (include "global.namespace" .)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
