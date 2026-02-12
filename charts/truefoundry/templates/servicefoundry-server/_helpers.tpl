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
  Common labels - uses global truefoundry.labels function
  */}}
{{- define "servicefoundry-server.labels" -}}
{{- include "truefoundry.labels" (dict "context" . "component" "servicefoundry-server" "name" "servicefoundry-server") }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "servicefoundry-server.commonLabels" -}}
{{- $baseLabels := include "servicefoundry-server.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.servicefoundryServer.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "servicefoundry-server.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.servicefoundryServer.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Pod Labels - merges global and component labels, excludes commonLabels to prevent version-related restarts
  */}}
{{- define "servicefoundry-server.podLabels" -}}
{{- $selectorLabels := include "truefoundry.selectorLabels" (dict "context" . "name" "servicefoundry-server") | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.servicefoundryServer.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "servicefoundry-server.podAnnotations" -}}
{{- $commonAnnotations := include "servicefoundry-server.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.servicefoundryServer.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "servicefoundry-server.serviceLabels" -}}
{{- $commonLabels := include "servicefoundry-server.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.servicefoundryServer.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "servicefoundry-server.serviceAnnotations" -}}
{{- $commonAnnotations := include "servicefoundry-server.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.servicefoundryServer.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service-account specific labels
  */}}
{{- define "servicefoundry-server.serviceAccountLabels" -}}
{{- $commonLabels := include "servicefoundry-server.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.servicefoundryServer.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service-account specific annotations
  */}}
{{- define "servicefoundry-server.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "servicefoundry-server.commonAnnotations" . | fromYaml }} 
{{- $serviceAccountAnnotations := mergeOverwrite $commonAnnotations .Values.servicefoundryServer.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "servicefoundry-server.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "servicefoundry-server.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.servicefoundryServer.serviceMonitor.annotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}


{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor specific labels
  */}}
{{- define "servicefoundry-server.serviceMonitorLabels" -}}
{{- $commonLabels := include "servicefoundry-server.commonLabels" . | fromYaml }}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.servicefoundryServer.serviceMonitor.labels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "servicefoundry-server.deploymentLabels" -}}
{{- $commonLabels := include "servicefoundry-server.commonLabels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.servicefoundryServer.deploymentLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "servicefoundry-server.deploymentAnnotations" -}}
{{- $syncWaveAnnotation := dict "argocd.argoproj.io/sync-wave" "2" }}
{{- $commonAnnotations := include "servicefoundry-server.commonAnnotations" . | fromYaml }}
{{- $mergedAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.servicefoundryServer.deploymentAnnotations $syncWaveAnnotation }}
{{- toYaml $mergedAnnotations }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "servicefoundry-server.serviceAccountName" -}}
{{- if .Values.servicefoundryServer.serviceAccount.name -}}
{{- .Values.servicefoundryServer.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
Here we are trying to get the full name of buildkitd service and statefulset
*/}}
{{- define "tfy-buildkitd.buildkitdServiceName"  }}
{{- if index .Values "tfy-buildkitd-service" "fullnameOverride" }}
{{- index .Values "tfy-buildkitd-service" "fullnameOverride"}}
{{- else }}
{{- $name := "tfy-buildkitd-service" }}
{{- if index .Values "tfy-buildkitd-service" "nameOverride"}}
{{- $name := index .Values "tfy-buildkitd-service" "nameOverride" }}
{{- end}}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Set GLOBAL_BUILDERS_BUILDKIT_URLS env variable if tfy-buildkitd-service is enabled
*/}}
{{- define "tfy-buildkitd.globalBuilderBuildkitUrlsEnv" }}
{{- if index .Values "tfy-buildkitd-service" "enabled" }}
{{ $urls := "" }}
{{ $replicas := index .Values "tfy-buildkitd-service" "replicaCount" | int}}
{{ $namespace := .Release.Namespace }}
{{ $portNumber := index .Values "tfy-buildkitd-service" "service" "port" | int }}
{{ $buildkitdServiceName := (include "tfy-buildkitd.buildkitdServiceName" .) }}
{{- range $i := until $replicas}}
  {{- $url := printf "%s-%d.%s.%s.svc.cluster.local:%d" $buildkitdServiceName $i $buildkitdServiceName $namespace $portNumber }}
  {{- $urls = printf "%s,%s" $urls $url }}
{{- end }}
GLOBAL_BUILDERS_BUILDKIT_URLS: {{ $urls | trimPrefix ","  }}
{{- end }}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "servicefoundry-server.parseEnv" -}}
{{- include "tfy-buildkitd.globalBuilderBuildkitUrlsEnv" . }}
{{- include "truefoundry.storage-credentials" . }}
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
{{- if (tpl .Values.servicefoundryServer.configs.imageMutationPolicy .) }}
- name: IMAGE_MUTATION_POLICY_CONFIG_PATH
  value: /opt/truefoundry/configs/image-mutation-policy/image-mutation-policy.yaml
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.k8sManifestValidationPolicy .) }}
- name: K8S_MANIFEST_VALIDATION_POLICY_CONFIG_PATH
  value: /opt/truefoundry/configs/k8s-manifest-validation-policy/k8s-manifest-validation-policy.yaml
{{- end }}
{{- if .Values.tfyBuild.jobTemplate.enabled }}
- name: BUILD_JOB_TEMPLATE_PATH
  value: /opt/truefoundry/configs/build-job-template/build-job-template.yaml
{{- end }}
- name: SERVICE_ACCOUNT_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.serviceAccountName
{{- end }}

{{- define "servicefoundry-server.volumes" -}}
{{- $volumes := list -}}
{{- $volumes = append $volumes (dict "name" "truefoundry-tmpdir" "emptyDir" (dict)) -}}
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
{{- if (tpl .Values.servicefoundryServer.configs.imageMutationPolicy .) }}
  {{- $volumes = append $volumes (dict "name" "configs-image-mutation-policy" "configMap" (dict "name" (tpl .Values.servicefoundryServer.configs.imageMutationPolicy .))) }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.k8sManifestValidationPolicy .) }}
  {{- $volumes = append $volumes (dict "name" "configs-k8s-manifest-validation-policy" "configMap" (dict "name" (tpl .Values.servicefoundryServer.configs.k8sManifestValidationPolicy .))) }}
{{- end }}
{{- if .Values.tfyBuild.jobTemplate.enabled }}
  {{- $configMapName := "" }}
  {{- if .Values.servicefoundryServer.configs.buildJobTemplate }}
    {{- $configMapName = tpl .Values.servicefoundryServer.configs.buildJobTemplate . }}
  {{- else }}
    {{- $configMapName = printf "%s-job-template-cm" (include "tfy-build.fullname" .) }}
  {{- end }}
  {{- $volumes = append $volumes (dict "name" "configs-build-job-template" "configMap" (dict "name" $configMapName)) }}
{{- end }}

{{- $volumes | toYaml -}}
{{- end -}}


{{- define "servicefoundry-server.volumeMounts" -}}
{{- $volumeMounts := list -}}
{{- $volumeMounts = append $volumeMounts (dict "name" "truefoundry-tmpdir" "mountPath" "/tmp") -}}
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
{{- if (tpl .Values.servicefoundryServer.configs.imageMutationPolicy .) }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-image-mutation-policy" "mountPath" "/opt/truefoundry/configs/image-mutation-policy") }}
{{- end }}
{{- if (tpl .Values.servicefoundryServer.configs.k8sManifestValidationPolicy .) }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-k8s-manifest-validation-policy" "mountPath" "/opt/truefoundry/configs/k8s-manifest-validation-policy") }}
{{- end }}
{{- if .Values.tfyBuild.jobTemplate.enabled }}
  {{- $volumeMounts = append $volumeMounts (dict "name" "configs-build-job-template" "mountPath" "/opt/truefoundry/configs/build-job-template") }}
{{- end }}
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{/*
Resource Tier
*/}}
{{- define "servicefoundry-server.resourceTier" }}
{{- $tier := .Values.servicefoundryServer.resourceTierOverride | default (.Values.global.resourceTier | default "medium") }}
{{- $tier }}
{{- end }}

{{- define "servicefoundry-server.replicas" }}
{{- $tier := include "servicefoundry-server.resourceTier" . }}
{{- if .Values.servicefoundryServer.replicaCount -}}
{{ .Values.servicefoundryServer.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "servicefoundry-server.defaultResources.small" }}
requests:
  cpu: 100m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "servicefoundry-server.defaultResources.medium" }}
requests:
  cpu: 500m
  memory: 1024Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "servicefoundry-server.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 1024Mi
{{- end }}

{{- define "servicefoundry-server.resources" }}
{{- $tier := include "servicefoundry-server.resourceTier" . }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "servicefoundry-server.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "servicefoundry-server.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "servicefoundry-server.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.servicefoundryServer.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}


{{- define "servicefoundry-server.imagePullSecrets" -}}
{{- if .Values.servicefoundryServer.imagePullSecrets -}}
{{- toYaml .Values.servicefoundryServer.imagePullSecrets | nindent 2 -}}
{{- else -}}
{{- include "global.imagePullSecrets" . -}}
{{- end }}
{{- end }}