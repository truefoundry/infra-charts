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
  Pod Labels
  */}}
{{- define "servicefoundry-server.podLabels" -}}
{{ include "servicefoundry-server.selectorLabels" . }}
{{- if .Values.servicefoundryServer.image.tag }}
app.kubernetes.io/version: {{ .Values.servicefoundryServer.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.servicefoundryServer.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "servicefoundry-server.labels" -}}
{{- include "servicefoundry-server.podLabels" . }}
helm.sh/chart: {{ include "servicefoundry-server.chart" . }}
{{- if .Values.servicefoundryServer.commonLabels }}
{{ toYaml .Values.servicefoundryServer.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "servicefoundry-server.annotations" -}}
{{- if .Values.servicefoundryServer.annotations }}
{{ toYaml .Values.servicefoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "servicefoundry-server.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "1") (include "servicefoundry-server.annotations" . | fromYaml) }}
{{- toYaml $merged }}
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
  Service Account Annotations
  */}}
{{- define "servicefoundry-server.serviceAccountAnnotations" -}}
{{- if .Values.servicefoundryServer.serviceAccount.annotations }}
{{ toYaml .Values.servicefoundryServer.serviceAccount.annotations }}
{{- else if .Values.servicefoundryServer.annotations }}
{{ toYaml .Values.servicefoundryServer.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
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
{{- $volumeMounts | toYaml -}}
{{- end -}}

{{- define "servicefoundry-server.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
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
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "servicefoundry-server.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "servicefoundry-server.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

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
