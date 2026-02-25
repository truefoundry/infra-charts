{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tfy-istio-ingress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels
*/}}
{{- define "tfy-istio-ingress.labels" -}}
helm.sh/chart: {{ include "tfy-istio-ingress.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.tfyGateway.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Annotations
*/}}
{{- define "tfy-istio-ingress.annotations" -}}
{{- if .Values.tfyGateway.annotations }}
  {{- toYaml .Values.tfyGateway.annotations }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
aws-elb-controller-checker fullname
*/}}
{{- define "aws-elb-controller-checker.fullname" -}}
{{- printf "%s-aws-elb-controller-checker" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
aws-elb-controller-checker ServiceAccount name
*/}}
{{- define "aws-elb-controller-checker.serviceAccountName" -}}
{{- if .Values.awsElbControllerChecker.serviceAccount.create }}
{{- include "aws-elb-controller-checker.fullname" . }}
{{- else }}
{{- .Values.awsElbControllerChecker.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}