{{/*
Render a single deltaFusionCompaction CronJob.
Expects a standard Helm context where .Values.deltaFusionCompaction is the
config for this job (base config, or base merged with an additionalJobs entry).
*/}}
{{- define "deltafusion-compaction.cronJob" -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "deltafusion-compaction.cronJobName" . }}
  namespace: {{ include "global.namespace" . }}
  labels:
    {{- include "deltafusion-compaction.cronJobLabels" . | nindent 4 }}
  annotations:
    {{- include "deltafusion-compaction.cronJobAnnotations" . | nindent 4 }}
spec:
  schedule: {{ .Values.deltaFusionCompaction.schedule | quote }}
  timeZone: {{ .Values.deltaFusionCompaction.timeZone | quote }}
  concurrencyPolicy: {{ .Values.deltaFusionCompaction.concurrencyPolicy }}
  startingDeadlineSeconds: {{ .Values.deltaFusionCompaction.startingDeadlineSeconds }}
  failedJobsHistoryLimit: {{ .Values.deltaFusionCompaction.failedJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ .Values.deltaFusionCompaction.successfulJobsHistoryLimit }}
  jobTemplate:
    spec:
      backoffLimit: {{ .Values.deltaFusionCompaction.backoffLimit }}
      activeDeadlineSeconds: {{ .Values.deltaFusionCompaction.activeDeadlineSeconds }}
      {{- if ge .Capabilities.KubeVersion.Minor "31" }}
      podFailurePolicy:
        {{- toYaml .Values.deltaFusionCompaction.podFailurePolicy | nindent 8 }}
      {{- end }}
      ttlSecondsAfterFinished: {{ .Values.deltaFusionCompaction.ttlSecondsAfterFinished }}
      template:
        metadata:
          annotations:
            {{- include "deltafusion-compaction.podAnnotations" . | nindent 12 }}
          labels:
            {{- include "deltafusion-compaction.podLabels" . | nindent 12 }}
        spec:
          restartPolicy: {{ .Values.deltaFusionCompaction.restartPolicy }}
          imagePullSecrets:
            {{- include "deltafusion-compaction.imagePullSecrets" . | nindent 12 }}
          serviceAccountName: {{ include "deltafusion-compaction.serviceAccountName" . }}
          {{- with (include "truefoundry.podSecurityContext" (dict "local" .Values.deltaFusionCompaction.podSecurityContext "global" .Values.global.podSecurityContext)) }}
          securityContext:
            {{- . | nindent 12 }}
          {{- end }}
          {{- if and .Values.global.customCA.enabled (eq (include "truefoundry.customCA.useDirectMount" .) "false") }}
          initContainers:
            {{- include "truefoundry.customCA.initContainer" . | nindent 12 }}
          {{- end }}
          containers:
            - name: "deltafusion-compaction"
              {{- with (include "truefoundry.containerSecurityContext" (dict "local" .Values.deltaFusionCompaction.securityContext "global" .Values.global.containerSecurityContext)) }}
              securityContext:
                {{- . | nindent 16 }}
              {{- end }}
              {{- $useOptimized := include "deltafusion-compaction.useOptimized" . | trim }}
              {{- if eq $useOptimized "true" }}
              image: "{{ .Values.deltaFusionCompaction.image.registry | default .Values.global.image.registry }}/{{ .Values.deltaFusionCompaction.image.repository }}:{{ .Values.deltaFusionCompaction.image.tag }}-optimized"
              {{- else }}
              image: "{{ .Values.deltaFusionCompaction.image.registry | default .Values.global.image.registry }}/{{ .Values.deltaFusionCompaction.image.repository }}:{{ .Values.deltaFusionCompaction.image.tag }}"
              {{- end }}
              imagePullPolicy: {{ .Values.deltaFusionCompaction.imagePullPolicy }}
              env:
                {{- include "deltafusion-compaction.env" . | trim | nindent 16 }}
              {{- if .Values.deltaFusionCompaction.command }}
              command: {{ .Values.deltaFusionCompaction.command }}
              {{- end }}
              {{- if .Values.deltaFusionCompaction.args }}
              args: {{ .Values.deltaFusionCompaction.args }}
              {{- end }}
              resources:
                {{- include "deltafusion-compaction.resources" . | nindent 16 }}
              volumeMounts:
                {{- include "deltafusion-compaction.volumeMounts" . | nindent 16 }}
          volumes:
            {{- include "deltafusion-compaction.volumes" . | nindent 12 }}
          {{- $mergedNodeSelector := mergeOverwrite (deepCopy .Values.global.nodeSelector) (deepCopy .Values.deltaFusionCompaction.nodeSelector) }}
          {{- if $mergedNodeSelector }}
          nodeSelector:
            {{- toYaml $mergedNodeSelector | nindent 12 }}
          {{- end }}
          {{- $mergedAffinity := include "deltafusion-compaction.affinity" . | fromYaml }}
          {{- if $mergedAffinity }}
          affinity:
            {{- toYaml $mergedAffinity | nindent 12 }}
          {{- end }}
          tolerations:
            {{- .Values.global.tolerations | toYaml | nindent 12 }}
            {{- if .Values.deltaFusionCompaction.tolerations }}
            {{- .Values.deltaFusionCompaction.tolerations | toYaml | nindent 12 }}
            {{- end }}
{{- end }}

{{/*
Render an additional compaction CronJob by deep-merging jobOverride onto
deltaFusionCompaction. Defaults nameOverride to df-compaction-<jobKey>. If the
assembled CronJob name would exceed 52 characters, the template fails and the
entry must set nameOverride or fullnameOverride. Usage: dict
"root" $ "jobKey" $jobKey "jobOverride" $jobOverride
*/}}
{{- define "deltafusion-compaction.additionalCronJob" -}}
{{- $root := .root -}}
{{- $jobKey := .jobKey -}}
{{- $jobOverride := deepCopy (.jobOverride | default dict) -}}
{{- $mergedCompaction := mergeOverwrite (deepCopy $root.Values.deltaFusionCompaction) $jobOverride -}}
{{- $_ := unset $mergedCompaction "additionalJobs" -}}
{{/* Do not inherit the base CronJob name; additional jobs must be uniquely named. */}}
{{- $_ := unset $mergedCompaction "nameOverride" -}}
{{- $_ := unset $mergedCompaction "fullnameOverride" -}}
{{- if $jobOverride.fullnameOverride -}}
{{- $_ := set $mergedCompaction "fullnameOverride" $jobOverride.fullnameOverride -}}
{{- else if $jobOverride.nameOverride -}}
{{- $_ := set $mergedCompaction "nameOverride" $jobOverride.nameOverride -}}
{{- else -}}
{{- $suffix := printf "df-compaction-%s" $jobKey -}}
{{- $_ := set $mergedCompaction "nameOverride" $suffix -}}
{{- if not (contains $suffix $root.Release.Name) -}}
{{- $name := printf "%s-%s" $root.Release.Name $suffix -}}
{{- if gt (len $name) 52 -}}
{{- fail (printf "CronJob name %q for additionalJobs entry %q exceeds the 52 character limit; set nameOverride or fullnameOverride on that entry" $name $jobKey) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $newValues := deepCopy $root.Values -}}
{{- $_ := set $newValues "deltaFusionCompaction" $mergedCompaction -}}
{{- $ctx := dict "Values" $newValues "Release" $root.Release "Chart" $root.Chart "Capabilities" $root.Capabilities "Template" $root.Template "Files" $root.Files -}}
{{- include "deltafusion-compaction.cronJob" $ctx -}}
{{- end -}}
