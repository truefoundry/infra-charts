{{/*
  aws-elb-controller-checker labels
*/}}
{{- define "aws-elb-controller-checker.labels" -}}
app.kubernetes.io/name: {{ include "aws-elb-controller-checker.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/hook: "pre-install,pre-upgrade"
{{- with .Values.awsElbControllerChecker.labels }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
  aws-elb-controller-checker annotations
*/}}
{{- define "aws-elb-controller-checker.annotations" -}}
{{- if .Values.awsElbControllerChecker.annotations }}
{{ toYaml .Values.awsElbControllerChecker.annotations }}
{{- else }}
{}
{{- end -}}
{{- end -}}