{{- define "tfy-otel-buffer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Fixed default so the gateway's default endpoint does not depend on the release name.
  The parent chart mirrors this in tfy-llm-gateway.otelBuffer.fullname; keep the two in sync.
*/}}
{{- define "tfy-otel-buffer.fullname" -}}
{{- default "tfy-otel-buffer" .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Same namespace as the gateway, which also follows global.namespaceOverride. */}}
{{- define "tfy-otel-buffer.namespace" -}}
{{- default .Release.Namespace .Values.global.namespaceOverride -}}
{{- end -}}

{{- define "tfy-otel-buffer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tfy-otel-buffer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "tfy-otel-buffer.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "tfy-otel-buffer.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "tfy-otel-buffer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "tfy-otel-buffer.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "tfy-otel-buffer.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets -}}
{{- toYaml .Values.imagePullSecrets }}
{{- else if .Values.global.imagePullSecrets -}}
{{- toYaml .Values.global.imagePullSecrets }}
{{- else if .Values.global.truefoundryImagePullConfigJSON -}}
- name: truefoundry-image-pull-secret
{{- else -}}
[]
{{- end }}
{{- end -}}

{{- define "tfy-otel-buffer.image" -}}
{{- printf "%s/%s:%s" (.Values.image.registry | default .Values.global.image.registry) .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{- define "tfy-otel-buffer.customCA.configMapName" -}}
{{- if .Values.global.customCA.existingConfigMap.name -}}
{{- .Values.global.customCA.existingConfigMap.name -}}
{{- else -}}
{{- printf "%s-custom-ca" (include "tfy-otel-buffer.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* The custom CA ConfigMap replaces /etc/ssl/certs directly instead of being merged by an initContainer. */}}
{{- define "tfy-otel-buffer.customCA.directMount" -}}
{{- if and .Values.global.customCA.existingConfigMap.name .Values.global.customCA.existingConfigMap.overrideCAList -}}
true
{{- end -}}
{{- end -}}

{{/*
  Serve mTLS on the OTLP ports. Forced on by global.mTLS.enabled: the gateway then rewrites
  in-cluster http:// endpoints to https:// and dials them with its mesh client certificate.
  The parent chart mirrors this in tfy-llm-gateway.otelBuffer.mtls; keep the two in sync.
*/}}
{{- define "tfy-otel-buffer.mtls" -}}
{{- if or .Values.mtls.enabled ((.Values.global).mTLS).enabled }}true{{ else }}false{{ end -}}
{{- end -}}

{{- define "tfy-otel-buffer.mtlsSecretName" -}}
{{- .Values.global.mTLS.externalMtlsSecret | default .Values.global.mTLS.tlsSecretName | default "truefoundry-internal-tls" -}}
{{- end -}}

{{/*
  Kubernetes quantity to bytes: plain digits, binary Ki/Mi/Gi/Ti, or decimal k/K/M/G/T.
  Returns "" when the format is not recognised (caller should fail).
*/}}
{{- define "tfy-otel-buffer.quantityToBytes" -}}
{{- $q := toString . -}}
{{- $bin := dict "Ki" 1024 "Mi" 1048576 "Gi" 1073741824 "Ti" 1099511627776 -}}
{{- $dec := dict "k" 1000 "K" 1000 "M" 1000000 "G" 1000000000 "T" 1000000000000 -}}
{{- if regexMatch "^[0-9]+$" $q -}}
{{- $q -}}
{{- else if regexMatch "^[0-9]+(Ki|Mi|Gi|Ti)$" $q -}}
{{- $unit := regexFind "(Ki|Mi|Gi|Ti)$" $q -}}
{{- mul (int64 (trimSuffix $unit $q)) (get $bin $unit) -}}
{{- else if regexMatch "^[0-9]+[kKMGT]$" $q -}}
{{- $unit := regexFind "[kKMGT]$" $q -}}
{{- mul (int64 (trimSuffix $unit $q)) (get $dec $unit) -}}
{{- end -}}
{{- end -}}

{{/* Sum of disk buffer max_size in a sink buffer config (a single stage or a list of stages). */}}
{{- define "tfy-otel-buffer.diskBufferBytes" -}}
{{- $total := 0 -}}
{{- $stages := . -}}
{{- if kindIs "map" . -}}
{{- $stages = list . -}}
{{- end -}}
{{- if kindIs "slice" $stages -}}
{{- range $stages -}}
{{- if and (kindIs "map" .) (eq (toString (get . "type")) "disk") -}}
{{- $total = add $total (int64 (get . "max_size" | default 0)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $total -}}
{{- end -}}

{{- define "tfy-otel-buffer.validate" -}}
{{- if not .Values.global.controlPlaneURL -}}
{{- fail "global.controlPlaneURL is required: traces are forwarded to <global.controlPlaneURL>/api/otel/v1/traces" -}}
{{- end -}}
{{- if and .Values.global.customCA.enabled (not .Values.global.customCA.certificate) (not .Values.global.customCA.existingConfigMap.name) -}}
{{- fail "global.customCA.enabled is true but neither global.customCA.certificate nor global.customCA.existingConfigMap.name is set. Provide one of them." -}}
{{- end -}}
{{- $reserved := list "tfy_otel_traces" "prom_exporter" "otel_in" "internal_metrics" -}}
{{- $additionalDisk := 0 -}}
{{- range $id, $sink := .Values.additionalSinks -}}
{{- if has $id $reserved -}}
{{- fail (printf "additionalSinks.%s uses a reserved ID (%s); use a different sink ID" $id (join ", " $reserved)) -}}
{{- end -}}
{{- if not (and (kindIs "map" $sink) (get $sink "type")) -}}
{{- fail (printf "additionalSinks.%s must be a sink config with a type (see https://vector.dev/docs/reference/configuration/sinks/)" $id) -}}
{{- end -}}
{{- $buffer := ternary (get $sink "buffer") $.Values.additionalSinkDefaults.buffer (hasKey $sink "buffer") -}}
{{- $additionalDisk = add $additionalDisk (include "tfy-otel-buffer.diskBufferBytes" $buffer | int64) -}}
{{- end -}}
{{- if .Values.persistence.enabled -}}
{{- $volume := include "tfy-otel-buffer.quantityToBytes" .Values.persistence.size -}}
{{- if not $volume -}}
{{- fail (printf "persistence.size %q is not a recognised Kubernetes quantity (plain bytes, or a Ki/Mi/Gi/Ti / k/K/M/G/T suffix)" (toString .Values.persistence.size)) -}}
{{- end -}}
{{- $reservedBytes := add (int64 .Values.buffer.maxSizeBytes) (int64 .Values.buffer.headroomBytes) -}}
{{- if gt (int64 $reservedBytes) (int64 $volume) -}}
{{- fail (printf "persistence.size (%v = %s bytes) is smaller than buffer.maxSizeBytes + buffer.headroomBytes (%d bytes). Grow the volume." .Values.persistence.size $volume (int64 $reservedBytes)) -}}
{{- end -}}
{{- $additionalBudget := sub (int64 $volume) (int64 $reservedBytes) -}}
{{- if gt (int64 $additionalDisk) (int64 $additionalBudget) -}}
{{- fail (printf "additionalSinks disk buffers add up to %d bytes, more than the %d bytes available to them (persistence.size %v minus buffer.maxSizeBytes and buffer.headroomBytes). Lower their buffer max_size or grow persistence.size." (int64 $additionalDisk) (int64 $additionalBudget) .Values.persistence.size) -}}
{{- end -}}
{{- end -}}
{{- end -}}
