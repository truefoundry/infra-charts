{{/*
Expand the name of the chart.
*/}}
{{- define "natsDeprecated.name" -}}
{{- default "nats" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "natsDeprecated.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "natsDeprecated.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "nats" .Values.nameOverride -}}
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
{{- define "natsDeprecated.chart" -}}
{{- printf "%s-%s" "nats" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "natsDeprecated.labels" -}}
helm.sh/chart: {{ include "natsDeprecated.chart" . }}
{{- range $name, $value := .Values.commonLabels }}
{{ $name }}: {{ tpl $value $ }}
{{- end }}
{{ include "natsDeprecated.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "natsDeprecated.selectorLabels" -}}
{{- if .Values.nats.selectorLabels }}
{{ tpl (toYaml .Values.nats.selectorLabels) . }}
{{- else -}}
app.kubernetes.io/name: {{ include "natsDeprecated.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end }}


{{/*
Return the proper NATS image name
*/}}
{{- define "natsDeprecated.clusterAdvertise" -}}
{{- if $.Values.useFQDN }}
{{- printf "$(POD_NAME).%s.$(POD_NAMESPACE).svc.%s" (include "natsDeprecated.fullname" . ) $.Values.k8sClusterDomain }}
{{- else }}
{{- printf "$(POD_NAME).%s.$(POD_NAMESPACE)" (include "natsDeprecated.fullname" . ) }}
{{- end }}
{{- end }}

{{/*
Return the NATS cluster auth.
*/}}
{{- define "natsDeprecated.clusterAuth" -}}
{{- if $.Values.cluster.authorization }}
{{- printf "%s:%s@" (urlquery $.Values.cluster.authorization.user) (urlquery $.Values.cluster.authorization.password) -}}
{{- else }}
{{- end }}
{{- end }}

{{/*
Return the NATS cluster routes.
*/}}
{{- define "natsDeprecated.clusterRoutes" -}}
{{- $name := (include "natsDeprecated.fullname" . ) -}}
{{- $namespace := (include "natsDeprecated.namespace" . ) -}}
{{- $clusterAuth := (include "natsDeprecated.clusterAuth" . ) -}}
{{- range $i, $e := until (.Values.cluster.replicas | int) -}}
{{- if $.Values.useFQDN }}
{{- printf "nats://%s%s-%d.%s.%s.svc.%s:6222," $clusterAuth $name $i $name $namespace $.Values.k8sClusterDomain -}}
{{- else }}
{{- printf "nats://%s%s-%d.%s.%s:6222," $clusterAuth $name $i $name $namespace -}}
{{- end }}
{{- end -}}
{{- end }}

{{- define "natsDeprecated.extraRoutes" -}}
{{- range $i, $url := .Values.cluster.extraRoutes -}}
{{- printf "%s," $url -}}
{{- end -}}
{{- end }}

{{- define "natsDeprecated.tlsConfig" -}}
tls {
{{- if .cert }}
    cert_file: {{ .secretPath }}/{{ .secret.name }}/{{ .cert }}
{{- end }}
{{- if .key }}
    key_file:  {{ .secretPath }}/{{ .secret.name }}/{{ .key }}
{{- end }}
{{- if .ca }}
    ca_file: {{ .secretPath }}/{{ .secret.name }}/{{ .ca }}
{{- end }}
{{- if .insecure }}
    insecure: {{ .insecure }}
{{- end }}
{{- if .verify }}
    verify: {{ .verify }}
{{- end }}
{{- if .verifyAndMap }}
    verify_and_map: {{ .verifyAndMap }}
{{- end }}
{{- if .verifyCertAndCheckKnownUrls }}
    verify_cert_and_check_known_urls: {{ .verifyCertAndCheckKnownUrls }}
{{- end }}
{{- if .curvePreferences }}
    curve_preferences: {{ .curvePreferences }}
{{- end }}
{{- if .timeout }}
    timeout: {{ .timeout }}
{{- end }}
{{- if .cipherSuites }}
    cipher_suites: {{ toRawJson .cipherSuites }}
{{- end }}
}
{{- end }}

{{- define "natsDeprecated.tlsReloaderArgs" -}}
{{ $secretName := .secret.name }}
{{ $secretPath := .secretPath }}
{{- with .ca }}
- -config
- {{ $secretPath }}/{{ $secretName }}/{{ . }}
{{- end }}
{{- with .cert }}
- -config
- {{ $secretPath }}/{{ $secretName }}/{{ . }}
{{- end }}
{{- with .key }}
- -config
- {{ $secretPath }}/{{ $secretName }}/{{ . }}
{{- end }}
{{- end }}

{{- define "natsDeprecated.tlsVolumeMounts" -}}
{{- with .Values.nats.tls }}
#######################
#                     #
#  TLS Volumes Mounts #
#                     #
#######################
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-clients-volume
  mountPath: /etc/nats-certs/clients/{{ $secretName }}
{{- end }}
{{- with .Values.mqtt.tls }}
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-mqtt-volume
  mountPath: /etc/nats-certs/mqtt/{{ $secretName }}
{{- end }}
{{- with .Values.cluster.tls }}
{{- if not .custom }}
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-cluster-volume
  mountPath: /etc/nats-certs/cluster/{{ $secretName }}
{{- end }}
{{- end }}
{{- with .Values.leafnodes.tls }}
{{- if not .custom }}
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-leafnodes-volume
  mountPath: /etc/nats-certs/leafnodes/{{ $secretName }}
{{- end }}
{{- end }}
{{- with .Values.gateway.tls }}
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-gateways-volume
  mountPath: /etc/nats-certs/gateways/{{ $secretName }}
{{- end }}
{{- with .Values.websocket.tls }}
{{ $secretName := tpl .secret.name $ }}
- name: {{ $secretName }}-ws-volume
  mountPath: /etc/nats-certs/ws/{{ $secretName }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "tplvalues.render" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (toYaml .value) .context }}
  {{- end }}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "natsDeprecated.serviceAccountName" -}}
{{- if .Values.nats.serviceAccount.create }}
{{- default (include "natsDeprecated.fullname" .) .Values.nats.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.nats.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fix image keys for chart versions <= 0.18.3
*/}}
{{- define "natsDeprecated.fixImage" -}}
{{- if kindIs "string" .image }}
{{- $_ := set . "image" (dict "repository" (split ":" .image)._0 "tag" ((split ":" .image)._1 | default "latest") "pullPolicy" "IfNotPresent") }}
{{- end }}
{{- if kindIs "string" .pullPolicy }}
{{- $_ := set .image "pullPolicy" .pullPolicy }}
{{- $_ := unset . "pullPolicy" }}
{{- end }}
{{- end }}

{{/*
Print the image
*/}}
{{- define "natsDeprecated.image" -}}
{{- $image := printf "%s:%s" .repository .tag }}
{{- if .registry }}
{{- $image = printf "%s/%s" .registry $image }}
{{- end }}
{{- $image -}}
{{- end }}
