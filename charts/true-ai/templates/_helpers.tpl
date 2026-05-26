{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "true-ai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "true-ai.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "true-ai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
 Base labels
  */}}
{{- define "true-ai.labels" -}}
helm.sh/chart: {{ include "true-ai.chart" . }}
{{ include "true-ai.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: truefoundry
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "true-ai.commonLabels" -}}
{{- $baseLabels := include "true-ai.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "true-ai.selectorLabels" -}}
app.kubernetes.io/name: {{ include "true-ai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Pod labels
  */}}
{{- define "true-ai.podLabels" -}}
{{- $selectorLabels := include "true-ai.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "true-ai.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "true-ai.podAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "true-ai.deploymentLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "true-ai.deploymentAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "true-ai.serviceLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "true-ai.serviceAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "true-ai.serviceAccountLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "true-ai.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "true-ai.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end }}
{{- end }}

{{/*
  Ingress Labels
*/}}
{{- define "true-ai.ingressLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $ingressLabels := mergeOverwrite $commonLabels .Values.ingress.labels }}
{{- toYaml $ingressLabels }}
{{- end }}

{{/*
  Ingress Annotations
*/}}
{{- define "true-ai.ingressAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $ingressAnnotations := mergeOverwrite $commonAnnotations .Values.ingress.annotations }}
{{- toYaml $ingressAnnotations }}
{{- end }}

{{/*
  VirtualService Labels
*/}}
{{- define "true-ai.virtualserviceLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $virtualServiceLabels := mergeOverwrite $commonLabels .Values.istio.virtualservice.labels }}
{{- toYaml $virtualServiceLabels }}
{{- end }}

{{/*
  VirtualService Annotations
*/}}
{{- define "true-ai.virtualserviceAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $virtualserviceAnnotations := mergeOverwrite $commonAnnotations .Values.istio.virtualservice.annotations }}
{{- toYaml $virtualserviceAnnotations }}
{{- end }}

{{/*
  HTTPRoute Labels
*/}}
{{- define "true-ai.httpRouteLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $httpRouteLabels := mergeOverwrite $commonLabels .Values.httpRoute.labels }}
{{- toYaml $httpRouteLabels }}
{{- end }}

{{/*
  HTTPRoute Annotations
*/}}
{{- define "true-ai.httpRouteAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $httpRouteAnnotations := mergeOverwrite $commonAnnotations .Values.httpRoute.annotations }}
{{- toYaml $httpRouteAnnotations }}
{{- end }}

{{/*
  PDB Annotations - merges commonAnnotations with pdb-specific annotations
*/}}
{{- define "true-ai.pdbAnnotations" -}}
{{- $commonAnnotations := include "true-ai.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.podDisruptionBudget.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end }}

{{/*
  PDB Labels - merges commonLabels with pdb-specific labels
*/}}
{{- define "true-ai.pdbLabels" -}}
{{- $commonLabels := include "true-ai.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.podDisruptionBudget.labels }}
{{- toYaml $pdbLabels }}
{{- end }}

{{/*
Affinity for true-ai deployment
*/}}
{{- define "true-ai.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{- toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for true-ai deployment
*/}}
{{- define "true-ai.tolerations" -}}
{{- if .Values.tolerations -}}
{{- toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{- toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for true-ai deployment
*/}}
{{- define "true-ai.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end }}

{{- define "true-ai.imagePullSecrets" -}}
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
  Custom CA validation
*/}}
{{- define "true-ai.customCA.validate" -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- end -}}

{{/*
  Whether to use direct mount (true) or initContainer merge (false)
*/}}
{{- define "true-ai.customCA.useDirectMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
  Custom CA ConfigMap name
*/}}
{{- define "true-ai.customCA.configMapName" -}}
{{- include "true-ai.customCA.validate" . -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- include "true-ai.fullname" . }}-custom-ca
{{- end -}}
{{- end -}}

{{/*
  Custom CA initContainer (only when not using direct mount)
*/}}
{{- define "true-ai.customCA.initContainer" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "true-ai.customCA.useDirectMount" .) "false" }}
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
  - Direct mount: just the ConfigMap
  - InitContainer merge: ConfigMap + emptyDir
*/}}
{{- define "true-ai.customCA.volumes" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "true-ai.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  configMap:
    name: {{ include "true-ai.customCA.configMapName" . }}
{{- else }}
- name: custom-ca
  configMap:
    name: {{ include "true-ai.customCA.configMapName" . }}
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
{{- define "true-ai.customCA.volumeMounts" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "true-ai.customCA.useDirectMount" .) "true" }}
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

{{- define "true-ai.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 64Mi
  ephemeral-storage: 64Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "true-ai.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 500m
  memory: 512Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "true-ai.defaultResources.large" }}
requests:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 1Gi
{{- end }}

{{- define "true-ai.ephemeralStorage.limit" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- $ephemeralLimit := "512Mi" }}
{{- if eq $tier "small" }}
  {{- $ephemeralLimit = "256Mi" }}
{{- else if eq $tier "large" }}
  {{- $ephemeralLimit = "1Gi" }}
{{- end }}
{{- if and .Values.resources .Values.resources.limits (index .Values.resources.limits "ephemeral-storage") }}
  {{- $ephemeralLimit = index .Values.resources.limits "ephemeral-storage" }}
{{- end }}
{{- $ephemeralLimit }}
{{- end }}

{{- define "true-ai.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "true-ai.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "true-ai.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "true-ai.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}

{{- define "true-ai.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
4
{{- end }}
{{- end }}

{{/*
  Parse env from template
*/}}
{{- define "true-ai.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Build the env list for the deployment.
  Supports inline values and ${k8s-secret/<key>} or ${k8s-secret/<secretName>/<key>} references
  resolved against `.Values.envSecretName` (or the explicit secretName).
*/}}
{{- define "true-ai.env" }}
{{- range $key, $val := (include "true-ai.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.envSecretName }}
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
{{- end }}
