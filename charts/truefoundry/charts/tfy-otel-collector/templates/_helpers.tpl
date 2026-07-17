{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}

{{- define "tfy-otel-collector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-otel-collector.fullname" -}}
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
{{- define "tfy-otel-collector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Base labels
  */}}
{{- define "tfy-otel-collector.labels" -}}
helm.sh/chart: {{ include "tfy-otel-collector.chart" . }}
{{ include "tfy-otel-collector.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-otel-collector.commonLabels" -}}
{{- $baseLabels := include "tfy-otel-collector.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-otel-collector.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-otel-collector.serviceLabels" -}}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-otel-collector.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-otel-collector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-otel-collector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-otel-collector.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-otel-collector.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "tfy-otel-collector.serviceMonitorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.serviceMonitor.additionalLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "tfy-otel-collector.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.serviceMonitor.additionalAnnotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{/*
  PDB Annotations - merges commonAnnotations with pdb-specific annotations
*/}}
{{- define "tfy-otel-collector.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.podDisruptionBudget.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end }}

{{/*
  PDB Labels - merges commonLabels with pdb-specific labels
*/}}
{{- define "tfy-otel-collector.pdbLabels" -}}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.podDisruptionBudget.labels }}
{{- toYaml $pdbLabels }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-otel-collector.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end }}
{{- end }}

{{/*
  Parse env from template
  */}}
{{- define "tfy-otel-collector.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-otel-collector.env" }}
{{- range $key, $val := (include "tfy-otel-collector.parseEnv" .) | fromYaml }}
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

{{/*
  Deployment annotations
  */}}
{{- define "tfy-otel-collector.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-otel-collector.deploymentLabels" -}}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-otel-collector.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}


{{/*
  Pod labels
  */}}
{{- define "tfy-otel-collector.podLabels" -}}
{{- $selectorLabels := include "tfy-otel-collector.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  HPA Labels - merges commonLabels with hpa-specific labels
  */}}
{{- define "tfy-otel-collector.hpaLabels" -}}
{{- $commonLabels := include "tfy-otel-collector.commonLabels" . | fromYaml }}
{{- $hpaLabels := mergeOverwrite $commonLabels .Values.autoscaling.labels }}
{{- toYaml $hpaLabels }}
{{- end }}

{{/*
  HPA annotations
  */}}
{{- define "tfy-otel-collector.hpaAnnotations" -}}
{{- $commonAnnotations := include "tfy-otel-collector.commonAnnotations" . | fromYaml }}
{{- $hpaAnnotations := mergeOverwrite $commonAnnotations .Values.autoscaling.annotations }}
{{- toYaml $hpaAnnotations }}
{{- end }}


{{/*
Deployment Volumes
*/}}
{{- define "tfy-otel-collector.volumes" -}}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- $ephemeralLimit := "1024Mi" }}
{{- if eq $tier "small" }}
  {{- $ephemeralLimit = "512Mi" }}
{{- else if eq $tier "large" }}
  {{- $ephemeralLimit = "2048Mi" }}
{{- end }}
{{- if and .Values.resources .Values.resources.limits (index .Values.resources.limits "ephemeral-storage") }}
  {{- $ephemeralLimit = index .Values.resources.limits "ephemeral-storage" }}
{{- end }}
- name: config-volume
  configMap:
    name: {{ include "tfy-otel-collector.fullname" . }}-cm
- name: tmp-dir
  emptyDir:
    sizeLimit: {{ $ephemeralLimit }}
{{- with .Values.extraVolumes }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- include "tfy-otel-collector.customCA.volumes" . }}
{{- end }}

{{/*
Deployment VolumeMounts
*/}}
{{- define "tfy-otel-collector.volumeMounts" -}}
- name: config-volume
  mountPath: /data/config.yaml
  readOnly: true
  subPath: config.yaml
- name: tmp-dir
  mountPath: /tmp
{{- with .Values.extraVolumeMounts }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- include "tfy-otel-collector.customCA.volumeMounts" . }}
{{- end }}

{{- define "tfy-otel-collector.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-otel-collector.defaultResources.large" . }}
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

{{- define "tfy-otel-collector.defaultResources.small" }}
requests:
  cpu: 50m
  memory: 128Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 100m
  memory: 256Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-otel-collector.defaultResources.medium" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 512Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 1024Mi
{{- end }}

{{- define "tfy-otel-collector.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 1024Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 2048Mi
{{- end }}

{{- define "tfy-otel-collector.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "tfy-otel-collector.hpaMinReplicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.autoscaling.minReplicas -}}
{{ .Values.autoscaling.minReplicas }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define  "tfy-otel-collector.hpaMaxReplicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.autoscaling.maxReplicas -}}
{{ .Values.autoscaling.maxReplicas }}
{{- else if eq $tier "small" -}}
3
{{- else if eq $tier "medium" -}}
5
{{- else if eq $tier "large" -}}
7
{{- end }}
{{- end }}

{{/*
Affinity rules for Otel-collector
*/}}
{{- define "tfy-otel-collector.affinity" -}}
{{- if .Values.affinity -}}
{{ toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for Otel-collector
*/}}
{{- define "tfy-otel-collector.tolerations" -}}
{{- if .Values.tolerations -}}
{{ toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{ toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for tfy-otel-collector deployment
*/}}
{{- define "tfy-otel-collector.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end }}

{{- define "tfy-otel-collector.imagePullSecrets" -}}
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
{{- define "tfy-otel-collector.customCA.validate" -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- end -}}

{{/*
  Whether to use direct mount (true) or initContainer merge (false)
*/}}
{{- define "tfy-otel-collector.customCA.useDirectMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
  Custom CA ConfigMap name
*/}}
{{- define "tfy-otel-collector.customCA.configMapName" -}}
{{- include "tfy-otel-collector.customCA.validate" . -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- include "tfy-otel-collector.fullname" . }}-custom-ca
{{- end -}}
{{- end -}}

{{/* Merged pod securityContext, local-over-global; "" when disabled. */}}
{{- define "tfy-otel-collector.podSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/* Merged container securityContext, local-over-global; "" when disabled. */}}
{{- define "tfy-otel-collector.containerSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/*
  Custom CA initContainer (only when not using direct mount)
*/}}
{{- define "tfy-otel-collector.customCA.initContainer" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-otel-collector.customCA.useDirectMount" .) "false" }}
- name: configure-custom-ca
  image: "{{ .Values.global.customCA.image.registry | default .Values.global.image.registry }}/{{ .Values.global.customCA.image.repository }}:{{ .Values.global.customCA.image.tag }}"
  {{- with (include "tfy-otel-collector.containerSecurityContext" (dict "local" .Values.global.customCA.securityContext "global" .Values.global.containerSecurityContext)) }}
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
{{- define "tfy-otel-collector.customCA.volumes" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-otel-collector.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-otel-collector.customCA.configMapName" . }}
{{- else }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-otel-collector.customCA.configMapName" . }}
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
{{- define "tfy-otel-collector.customCA.volumeMounts" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-otel-collector.customCA.useDirectMount" .) "true" }}
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
