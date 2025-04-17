{{/*
Clickhouse labels
*/}}
{{- define "clickhouse.labels" -}}
{{- if .Values.clickhouse.labels }}
{{ toYaml .Values.clickhouse.labels }}
{{- end }}
{{- end }}

{{/*
Clickhouse annotations
*/}}
{{- define "clickhouse.annotations" -}}
argocd.argoproj.io/sync-options: Prune=false,Delete=false
{{- if .Values.clickhouse.annotations }}
{{- toYaml .Values.clickhouse.annotations }}
{{- end }}
{{- end }}

{{/* 
Clickhouse resoures
*/}}
{{- define "clickhouse.resources" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}

{{- $defaultsYaml := "" }}
{{- if eq $tier "small" }}
  {{- $defaultsYaml = include "clickhouse.defaultResources.small" . }}
{{- else if eq $tier "medium" }}
  {{- $defaultsYaml = include "clickhouse.defaultResources.medium" . }}
{{- else if eq $tier "large" }}
  {{- $defaultsYaml = include "clickhouse.defaultResources.large" . }}
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

{{- define "clickhouse.defaultResources.small" }}
requests:
  cpu: 1000m
  memory: 4096Mi
  ephemeral-storage: 5Gi
limits:
  cpu: 2000m
  memory: 8192Mi
  ephemeral-storage: 10Gi
{{- end }}

{{- define "clickhouse.defaultResources.medium" }}
requests:
  cpu: 3500m
  memory: 15360Mi
  ephemeral-storage: 5Gi
limits:
  cpu: 7000m
  memory: 30720Mi
  ephemeral-storage: 10Gi
{{- end }}

{{- define "clickhouse.defaultResources.large" }}
requests:
  cpu: 3500m
  memory: 15360Mi
  ephemeral-storage: 5Gi
limits:
  cpu: 7000m
  memory: 30720Mi
  ephemeral-storage: 10Gi
{{- end }}

{{- define "clickhouse.replicas" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.clickhouse.replicasCount }}
{{ .Values.clickhouse.replicasCount }}
{{- else if eq $tier "small" -}}
1
{{- else if eq $tier "medium" -}}
2
{{- else if eq $tier "large" -}}
3
{{- end }}
{{- end }}

{{- define "clickhouse.storageSize" }}
{{- $tier := .Values.global.resourceTier | default "medium" }}
{{- if .Values.clickhouse.storage.size }}
{{ .Values.clickhouse.storage.size }}
{{- else if eq $tier "small" -}}
100Gi
{{- else if eq $tier "medium" -}}
100Gi
{{- else if eq $tier "large" -}}
100Gi
{{- end }}
{{- end }}