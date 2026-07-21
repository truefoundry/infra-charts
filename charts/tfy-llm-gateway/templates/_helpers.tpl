{{/*
Expand the name of the chart.
*/}}
{{/*
  Namespace
*/}}
{{- define "global.namespace" }}
{{- default .Release.Namespace .Values.global.namespaceOverride }}
{{- end }}


{{- define "tfy-llm-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
  Compute the tfy-sandbox-server subchart's Service name from the parent chart context.
  Mirrors the logic in tfy-sandbox-server.fullname but uses the subchart's scoped values.
*/}}
{{- define "tfy-llm-gateway.sandbox.fullname" -}}
{{- $sandboxValues := index .Values "tfy-sandbox-server" -}}
{{- if $sandboxValues.fullnameOverride -}}
{{- $sandboxValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "tfy-sandbox-server" $sandboxValues.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
  */}}
{{- define "tfy-llm-gateway.fullname" -}}
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
{{- define "tfy-llm-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
 Base labels
  */}}
{{- define "tfy-llm-gateway.labels" -}}
helm.sh/chart: {{ include "tfy-llm-gateway.chart" . }}
{{ include "tfy-llm-gateway.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
  Common labels - merges global.labels with component-specific labels
  Priority: ResourceLabels > CommonLabels > GlobalLabels
    */}}
{{- define "tfy-llm-gateway.commonLabels" -}}
{{- $baseLabels := include "tfy-llm-gateway.labels" . | fromYaml }}
{{- $mergedLabels := mergeOverwrite $baseLabels (deepCopy .Values.global.labels) .Values.commonLabels }}
{{- toYaml $mergedLabels }}
{{- end }}

{{/*
  Service Labels - merges commonLabels with service-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceLabels := mergeOverwrite (deepCopy .Values.global.serviceLabels) $commonLabels .Values.service.labels }}
{{- toYaml $serviceLabels }}
{{- end }}

{{/*
  Selector labels
  */}}
{{- define "tfy-llm-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-llm-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  Pod labels
  */}}
{{- define "tfy-llm-gateway.podLabels" -}}
{{- $selectorLabels := include "tfy-llm-gateway.selectorLabels" . | fromYaml }}
{{- $podLabels := mergeOverwrite (deepCopy .Values.global.podLabels) .Values.podLabels $selectorLabels }}
{{- toYaml $podLabels }}
{{- end }}


{{/*
  Ingress labels
  */}}
{{- define "tfy-llm-gateway.ingressLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $ingressLabels := mergeOverwrite $commonLabels .Values.ingress.labels }}
{{- toYaml $ingressLabels }}
{{- end }}

{{/*
  Common annotations - merges global.annotations with component-specific annotations
  */}}
{{- define "tfy-llm-gateway.commonAnnotations" -}}
{{- with (mergeOverwrite (deepCopy .Values.global.annotations) .Values.commonAnnotations) }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
  Create the name of the service account to use
  */}}
{{- define "tfy-llm-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.global.serviceAccount.name -}}
{{- end }}
{{- end }}

{{/*
  VirtualService Labels
*/}}
{{- define "tfy-llm-gateway.virtualserviceLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $virtualServiceLabels := mergeOverwrite $commonLabels .Values.istio.virtualservice.labels }}
{{- toYaml $virtualServiceLabels }}
{{- end }}

{{/*
  VirtualService annotations
  */}}
{{- define "tfy-llm-gateway.virtualserviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite $commonAnnotations .Values.istio.virtualservice.annotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  HTTPRoute Labels
*/}}
{{- define "tfy-llm-gateway.httpRouteLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $httpRouteLabels := mergeOverwrite $commonLabels .Values.httpRoute.labels }}
{{- toYaml $httpRouteLabels }}
{{- end }}

{{/*
  HTTPRoute annotations
  */}}
{{- define "tfy-llm-gateway.httpRouteAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $httpRouteAnnotations := mergeOverwrite $commonAnnotations .Values.httpRoute.annotations }}
{{- toYaml $httpRouteAnnotations }}
{{- end }}

{{/*
  Deployment Labels - merges commonLabels with deployment-specific labels
  */}}
{{- define "tfy-llm-gateway.deploymentLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $deploymentLabels := mergeOverwrite (deepCopy .Values.global.deploymentLabels) $commonLabels .Values.deploymentLabels }}
{{- toYaml $deploymentLabels }}
{{- end }}

{{/*
  Deployment annotations
  */}}
{{- define "tfy-llm-gateway.deploymentAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $deploymentAnnotations := mergeOverwrite (deepCopy .Values.global.deploymentAnnotations) $commonAnnotations .Values.deploymentAnnotations }}
{{- toYaml $deploymentAnnotations }}
{{- end }}

{{/*
  Service Account Labels - merges commonLabels with service account-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceAccountLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceAccountLabels := mergeOverwrite (deepCopy .Values.global.serviceAccount.labels) $commonLabels .Values.serviceAccount.labels }}
{{- toYaml $serviceAccountLabels }}
{{- end }}

{{/*
  Service Account Annotations - merges commonAnnotations with service account-specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceAccountAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceAccountAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAccount.annotations) $commonAnnotations .Values.serviceAccount.annotations }}
{{- toYaml $serviceAccountAnnotations }}
{{- end }}

{{/*
  ServiceMonitor Labels - merges commonLabels with servicemonitor-specific labels
  */}}
{{- define "tfy-llm-gateway.serviceMonitorLabels" -}}
{{- $prometheusLabel := dict "release" "prometheus" }}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $serviceMonitorLabels := mergeOverwrite $commonLabels $prometheusLabel .Values.serviceMonitor.additionalLabels }}
{{- toYaml $serviceMonitorLabels }}
{{- end }}

{{/*
  ServiceMonitor Annotations - merges commonAnnotations with servicemonitor specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceMonitorAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceMonitorAnnotations := mergeOverwrite $commonAnnotations .Values.serviceMonitor.additionalAnnotations }}
{{- toYaml $serviceMonitorAnnotations }}
{{- end }}

{{/*
  Whether the TLS proxy (Caddy in tfy-proxy) is enabled
*/}}
{{- define "tfy-llm-gateway.proxy.tls.enabled" -}}
{{- if .Values.proxy.tls.enabled }}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
  ConfigMap name for the proxy Caddyfile
*/}}
{{- define "tfy-llm-gateway.proxy.configMapName" -}}
{{- if .Values.proxy.configMapName -}}
{{- .Values.proxy.configMapName -}}
{{- else -}}
{{- printf "%s-caddyfile" (include "tfy-llm-gateway.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
  Fail fast if TLS proxy is misconfigured
*/}}
{{- define "tfy-llm-gateway.proxy.validate" -}}
{{- if .Values.proxy.tls.enabled }}
{{- if not .Values.proxy.tls.secretName }}
{{- fail "proxy.tls.enabled is true but proxy.tls.secretName is empty. Set proxy.tls.secretName to a Secret containing tls.crt and tls.key." }}
{{- end }}
{{- if eq (int .Values.proxy.containerPort) (int .Values.service.port) }}
{{- fail "proxy.containerPort must differ from service.port (gateway listens on service.port; the proxy cannot use the same port)." }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
  Volume mounts for the proxy container:
  - caddyfile  (ConfigMap, read-only) -> /etc/caddy/Caddyfile (subPath)
  - tls-cert   (Secret,    read-only) -> /etc/caddy/tls
  - caddy-data (emptyDir)             -> /data
  - caddy-config (emptyDir)           -> /config
*/}}
{{- define "tfy-llm-gateway.proxy.volumeMounts" -}}
{{- if .Values.proxy.tls.enabled -}}
- name: caddyfile
  mountPath: /etc/caddy/Caddyfile
  subPath: Caddyfile
  readOnly: true
- name: tls-cert
  mountPath: /etc/caddy/tls
  readOnly: true
- name: caddy-data
  mountPath: /data
- name: caddy-config
  mountPath: /config
{{- end }}
{{- end -}}

{{/*
  Pod-level volumes backing the proxy mounts:
  - caddyfile    sourced from the Caddyfile ConfigMap
  - tls-cert     sourced from the user-supplied TLS Secret (tls.crt / tls.key)
  - caddy-data   ephemeral state directory
  - caddy-config ephemeral autosave directory
*/}}
{{- define "tfy-llm-gateway.proxy.volumes" -}}
{{- if .Values.proxy.tls.enabled -}}
- name: caddyfile
  configMap:
    name: {{ include "tfy-llm-gateway.proxy.configMapName" . }}
- name: tls-cert
  secret:
    secretName: {{ .Values.proxy.tls.secretName }}
    items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
- name: caddy-data
  emptyDir: {}
- name: caddy-config
  emptyDir: {}
{{- end }}
{{- end -}}

{{/*
  Parse env from template
  */}}
{{- define "tfy-llm-gateway.parseEnv" -}}
{{ tpl (.Values.env | toYaml) . }}
{{- end }}

{{/*
  Create the env file
  */}}
{{- define "tfy-llm-gateway.env" }}
{{- range $key, $val := (include "tfy-llm-gateway.parseEnv" .) | fromYaml }}
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
{{- if and .Values.redis.enabled (not .Values.env.REDIS_HOST) }}
- name: REDIS_HOST
  value: {{ printf "%s-redis-master.%s.svc.cluster.local" .Release.Name (include "global.namespace" .) | quote }}
{{- end }}
{{- if and .Values.sandbox.devMode.enabled (not .Values.env.TFY_SANDBOX_SERVER_URL) }}
- name: TFY_SANDBOX_SERVER_URL
  value: {{ printf "http://%s.%s.svc.cluster.local:8080" (include "tfy-llm-gateway.sandbox.fullname" .) (include "global.namespace" .) | quote }}
{{- end }}
{{- if and .Values.sandbox.devMode.enabled (not .Values.env.TFY_SANDBOX_NATS_BRIDGE_URL) }}
- name: TFY_SANDBOX_NATS_BRIDGE_URL
  value: {{ printf "ws://%s.%s.svc.cluster.local:4444" (include "tfy-llm-gateway.sandbox.fullname" .) (include "global.namespace" .) | quote }}
{{- end }}
{{- if and .Values.global.multitenant.enabled (not (hasKey .Values.env "MULTITENANT")) }}
- name: MULTITENANT
  value: "true"
{{- end }}
{{- end }}

{{/*
Ingress Annotations
*/}}
{{- define "tfy-llm-gateway.ingressAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $ingressAnnotations := mergeOverwrite $commonAnnotations .Values.ingress.annotations }}
{{- toYaml $ingressAnnotations }}
{{- end }}

{{/*
  Service Annotations - merges commonAnnotations with service-specific annotations
  */}}
{{- define "tfy-llm-gateway.serviceAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $serviceAnnotations := mergeOverwrite (deepCopy .Values.global.serviceAnnotations) $commonAnnotations .Values.service.annotations }}
{{- toYaml $serviceAnnotations }}
{{- end }}

{{/*
  Pod Annotations - merges commonAnnotations with pod-specific annotations
  */}}
{{- define "tfy-llm-gateway.podAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $podAnnotations := mergeOverwrite (deepCopy .Values.global.podAnnotations) $commonAnnotations .Values.podAnnotations }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
  PDB Annotations - merges commonAnnotations with pdb-specific annotations
*/}}
{{- define "tfy-llm-gateway.pdbAnnotations" -}}
{{- $commonAnnotations := include "tfy-llm-gateway.commonAnnotations" . | fromYaml }}
{{- $pdbAnnotations := mergeOverwrite $commonAnnotations .Values.podDisruptionBudget.annotations }}
{{- toYaml $pdbAnnotations }}
{{- end }}

{{/*
  PDB Labels - merges commonLabels with pdb-specific labels
*/}}
{{- define "tfy-llm-gateway.pdbLabels" -}}
{{- $commonLabels := include "tfy-llm-gateway.commonLabels" . | fromYaml }}
{{- $pdbLabels := mergeOverwrite $commonLabels .Values.podDisruptionBudget.labels }}
{{- toYaml $pdbLabels }}
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.small" }}
requests:
  cpu: 200m
  memory: 512Mi
  ephemeral-storage: 128Mi
limits:
  cpu: 400m
  memory: 1024Mi
  ephemeral-storage: 256Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.medium" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-llm-gateway.defaultResources.large" }}
requests:
  cpu: 1000m
  memory: 2048Mi
  ephemeral-storage: 256Mi
limits:
  cpu: 2000m
  memory: 4096Mi
  ephemeral-storage: 512Mi
{{- end }}

{{- define "tfy-llm-gateway.ephemeralStorage.limit" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- $ephemeralLimit := "512Mi" }}
{{- if eq $tier "small" }}
  {{- $ephemeralLimit = "256Mi" }}
{{- end }}
{{- if and .Values.resources .Values.resources.limits (index .Values.resources.limits "ephemeral-storage") }}
  {{- $ephemeralLimit = index .Values.resources.limits "ephemeral-storage" }}
{{- end }}
{{- $ephemeralLimit }}
{{- end }}

{{- define "tfy-llm-gateway.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "tfy-llm-gateway.defaultResources.large" . }}
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

{{- define "tfy-llm-gateway.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.replicaCount -}}
{{ .Values.replicaCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
3
{{- else if eq $tier "large" -}}
10
{{- end }}
{{- end }}

{{/*
Affinity for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity }}
{{- else if .Values.global.affinity -}}
{{- toYaml .Values.global.affinity }}
{{- else -}}
{}
{{- end }}
{{- end }}

{{/*
Tolerations for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.tolerations" -}}
{{- if .Values.tolerations -}}
{{- toYaml .Values.tolerations }}
{{- else if .Values.global.tolerations -}}
{{- toYaml .Values.global.tolerations }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{/*
Node Selector for tfy-llm-gateway deployment
*/}}
{{- define "tfy-llm-gateway.nodeSelector" -}}
{{- $nodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) .Values.nodeSelector }}
{{- toYaml $nodeSelector }}
{{- end }}

{{- define "tfy-llm-gateway.imagePullSecrets" -}}
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
{{- define "tfy-llm-gateway.customCA.validate" -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- end -}}

{{/*
  Whether to use direct mount (true) or initContainer merge (false)
*/}}
{{- define "tfy-llm-gateway.customCA.useDirectMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
  Custom CA ConfigMap name
*/}}
{{- define "tfy-llm-gateway.customCA.configMapName" -}}
{{- include "tfy-llm-gateway.customCA.validate" . -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- include "tfy-llm-gateway.fullname" . }}-custom-ca
{{- end -}}
{{- end -}}

{{/* Merged pod securityContext, local-over-global; "" when disabled. */}}
{{- define "tfy-llm-gateway.podSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/* Merged container securityContext, local-over-global; "" when disabled. */}}
{{- define "tfy-llm-gateway.containerSecurityContext" -}}
{{- $l := .local | default dict -}}{{- $g := .global | default dict -}}
{{- if ternary $l.enabled $g.enabled (hasKey $l "enabled") -}}
{{- toYaml (mergeOverwrite (deepCopy (omit $g "enabled")) (omit $l "enabled")) -}}
{{- end -}}
{{- end -}}

{{/*
  Custom CA initContainer (only when not using direct mount)
*/}}
{{- define "tfy-llm-gateway.customCA.initContainer" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-llm-gateway.customCA.useDirectMount" .) "false" }}
- name: configure-custom-ca
  image: "{{ .Values.global.customCA.image.registry | default .Values.global.image.registry }}/{{ .Values.global.customCA.image.repository }}:{{ .Values.global.customCA.image.tag }}"
  {{- with (include "tfy-llm-gateway.containerSecurityContext" (dict "local" .Values.global.customCA.securityContext "global" .Values.global.containerSecurityContext)) }}
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
{{- define "tfy-llm-gateway.customCA.volumes" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-llm-gateway.customCA.useDirectMount" .) "true" }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-llm-gateway.customCA.configMapName" . }}
{{- else }}
- name: custom-ca
  configMap:
    name: {{ include "tfy-llm-gateway.customCA.configMapName" . }}
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
{{- define "tfy-llm-gateway.customCA.volumeMounts" -}}
{{- if .Values.global.customCA.enabled }}
{{- if eq (include "tfy-llm-gateway.customCA.useDirectMount" .) "true" }}
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
