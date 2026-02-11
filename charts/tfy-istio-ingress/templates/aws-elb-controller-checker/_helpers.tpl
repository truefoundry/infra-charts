{{/*
  aws-elb-controller-checker annotations
*/}}
{{- define "aws-elb-controller-checker.annotations" -}}
helm.sh/hook: pre-install,pre-upgrade
{{- with .Values.awsElbControllerChecker.annotations }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
  aws-elb-controller-checker labels
*/}}
{{- define "aws-elb-controller-checker.labels" -}}
app.kubernetes.io/name: {{ include "aws-elb-controller-checker.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- with .Values.awsElbControllerChecker.labels }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
  aws-elb-controller-checker job labels
*/}}
{{- define "aws-elb-controller-checker.jobLabels" -}}
app.kubernetes.io/name: {{ include "aws-elb-controller-checker.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- with .Values.awsElbControllerChecker.jobLabels }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
  aws-elb-controller-checker job annotations
*/}}
{{- define "aws-elb-controller-checker.jobAnnotations" -}}
helm.sh/hook: pre-install,pre-upgrade
{{- with .Values.awsElbControllerChecker.jobAnnotations }}
{{ toYaml . }}
{{- end -}}
{{- end -}}