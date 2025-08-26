{{/*
Expand the name of the chart.
*/}}
{{- define "tfy-nginx-proxy.name" -}}
{{- default "tfy-nginx-proxy" .Values.tfyNginxProxy.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-nginx-proxy.fullname" -}}
{{- if .Values.tfyNginxProxy.fullnameOverride }}
{{- .Values.tfyNginxProxy.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "tfy-nginx-proxy" .Values.tfyNginxProxy.nameOverride }}
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
{{- define "tfy-nginx-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Pod Labels
  */}}
{{- define "tfy-nginx-proxy.podLabels" -}}
{{ include "tfy-nginx-proxy.selectorLabels" . }}
{{- if .Values.tfyNginxProxy.image.tag }}
app.kubernetes.io/version: {{ .Values.tfyNginxProxy.image.tag | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $name, $value := .Values.tfyNginxProxy.commonLabels }}
{{ $name }}: {{ tpl $value $ | quote }}
{{- end }}
{{- end }}

{{/*
  Common labels
  */}}
{{- define "tfy-nginx-proxy.labels" -}}
helm.sh/chart: {{ include "tfy-nginx-proxy.chart" . }}
{{ include "tfy-nginx-proxy.podLabels" . }}
{{- if .Values.tfyNginxProxy.commonLabels }}
{{ toYaml .Values.tfyNginxProxy.commonLabels }}
{{- else if .Values.global.labels }}
{{ toYaml .Values.global.labels }}
{{- end }}
{{- end }}

{{/*
  Common annotations
  */}}
{{- define "tfy-nginx-proxy.annotations" -}}
{{- if .Values.tfyNginxProxy.annotations }}
{{ toYaml .Values.tfyNginxProxy.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-nginx-proxy.deploymentAnnotations" -}}
{{- $merged := merge (dict "argocd.argoproj.io/sync-wave" "3") (include "tfy-nginx-proxy.annotations" . | fromYaml) }}
{{- toYaml $merged }}
{{- end }}

{{/*
  Service Account Annotations
  */}}
{{- define "tfy-nginx-proxy.serviceAccountAnnotations" -}}
{{- if .Values.tfyNginxProxy.serviceAccount.annotations }}
{{ toYaml .Values.tfyNginxProxy.serviceAccount.annotations }}
{{- else if .Values.tfyNginxProxy.annotations }}
{{ toYaml .Values.tfyNginxProxy.annotations }}
{{- else if .Values.global.annotations }}
{{ toYaml .Values.global.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-nginx-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-nginx-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-nginx-proxy.serviceAccountName" -}}
{{- if .Values.tfyNginxProxy.serviceAccount.name -}}
{{- .Values.tfyNginxProxy.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end }}


{{/*
  Parse env from template
  */}}
{{- define "tfy-nginx-proxy.parseEnv" -}}
{{ tpl (.Values.tfyNginxProxy.env | toYaml) . }}

{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-nginx-proxy.env" }}
{{- range $key, $val := (include "tfy-nginx-proxy.parseEnv" .) | fromYaml }}
{{- if and $val (contains "${k8s-secret" ($val | toString)) }}
{{- if eq (regexSplit "/" $val -1 | len) 2 }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.tfyNginxProxy.envSecretName }}
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

{{- define "tfy-nginx-proxy.volumes" -}}
{{- /* Create a list containing the default nginx-config volume.
     Using 'items' allows the ConfigMap to have other keys without
     polluting the container's filesystem. */}}
{{- $defaultVolume := dict "name" (include "tfy-nginx-proxy.fullname" .) "configMap" (dict "name" (include "tfy-nginx-proxy.fullname" .) "items" (list (dict "key" "nginx.conf" "path" "nginx.conf"))) -}}
{{- /* Writable dirs for readOnlyRootFilesystem images */ -}}
{{- $cache := dict "name" "nginx-cache" "emptyDir" (dict) -}}
{{- $run   := dict "name" "nginx-run"   "emptyDir" (dict) -}}
{{- $logs  := dict "name" "nginx-logs"  "emptyDir" (dict) -}}
{{- $volumes := list $defaultVolume $cache $run $logs  -}}

{{- /* If extraVolumes are defined, concatenate them with the default list */}}
{{- if .Values.tfyNginxProxy.extraVolumes -}}
  {{- $volumes = concat $volumes .Values.tfyNginxProxy.extraVolumes -}}
{{- end -}}

{{- /* Convert the final, combined list of volumes to YAML */}}
{{- toYaml $volumes -}}
{{- end -}}


{{- define "tfy-nginx-proxy.volumeMounts" -}}
{{- /* Create a list containing the default volume mount for nginx.conf.
     Using 'subPath' mounts the specific file, not the whole directory.
     This prevents the original /etc/nginx directory from being overwritten. */}}
{{- $defaultVolumeMount := dict "name" (include "tfy-nginx-proxy.fullname" .) "mountPath" "/etc/nginx/nginx.conf" "subPath" "nginx.conf" "readOnly" true -}}
{{- /* Writable mounts */ -}}
{{- $mCache := dict "name" "nginx-cache" "mountPath" "/var/cache/nginx" -}}
{{- $mRun   := dict "name" "nginx-run"   "mountPath" "/var/run" -}}
{{- $mLogs  := dict "name" "nginx-logs"  "mountPath" "/var/log/nginx" -}}
{{- $volumeMounts := list $defaultVolumeMount $mCache $mRun $mLogs -}}

{{- /* If extraVolumeMounts are defined, concatenate them with the default list */}}
{{- if .Values.tfyNginxProxy.extraVolumeMounts -}}
  {{- $volumeMounts = concat $volumeMounts .Values.tfyNginxProxy.extraVolumeMounts -}}
{{- end -}}

{{- /* Convert the final, combined list of volume mounts to YAML */}}
{{- toYaml $volumeMounts -}}
{{- end -}}

{{- define "tfy-nginx-proxy.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.tfyNginxProxy.replicaCount -}}
{{ .Values.tfyNginxProxy.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
5
{{- end }}
{{- end }}

{{- define "tfy-nginx-proxy.defaultResources.small"}}
requests:
  cpu: 50m
  memory: 64Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "tfy-nginx-proxy.defaultResources.medium" }}
requests:
  cpu: 100m
  memory: 128Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 200m
  memory: 256Mi
  ephemeral-storage: 256Mi
{{- end }}
{{- define "tfy-nginx-proxy.defaultResources.large" }}
requests:
  cpu: 500m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 1000m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-nginx-proxy.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-nginx-proxy.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-nginx-proxy.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-nginx-proxy.defaultResources.large" . }}
{{- end }}

{{- $defaults := fromYaml $defaultsYaml | default dict }}
{{- $defaultsRequests := $defaults.requests | default dict }}
{{- $defaultsLimits := $defaults.limits | default dict }}
{{- $overrides := .Values.tfyNginxProxy.resources | default dict }}
{{- $overridesRequests := $overrides.requests | default dict }}
{{- $overridesLimits := $overrides.limits | default dict }}

{{- $requests := merge $overridesRequests $defaultsRequests }}
{{- $limits := merge $overridesLimits $defaultsLimits }}

{{- $merged := dict "requests" $requests "limits" $limits }}
{{ toYaml $merged }}
{{- end }}