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

{{/*
AppGW ingress labels — user-supplied only.
*/}}
{{- define "tfy-istio-ingress.appgwLabels" -}}
{{- if .Values.appgw.ingress.labels }}
{{- toYaml .Values.appgw.ingress.labels }}
{{- else }}
{}
{{- end }}
{{- end }}

{{/*
AppGW ingress annotations — fixed probe/routing settings plus user-supplied extras.
*/}}
{{- define "tfy-istio-ingress.appgwAnnotations" -}}
appgw.ingress.kubernetes.io/backend-protocol: http
appgw.ingress.kubernetes.io/connection-draining: "true"
appgw.ingress.kubernetes.io/connection-draining-timeout: "30"
appgw.ingress.kubernetes.io/cookie-based-affinity: "true"
appgw.ingress.kubernetes.io/health-probe-interval: "30"
appgw.ingress.kubernetes.io/health-probe-path: /healthz/ready
appgw.ingress.kubernetes.io/health-probe-port: "15021"
appgw.ingress.kubernetes.io/health-probe-status-codes: 200-399
appgw.ingress.kubernetes.io/health-probe-timeout: "30"
appgw.ingress.kubernetes.io/health-probe-unhealthy-threshold: "3"
appgw.ingress.kubernetes.io/request-timeout: "300"
appgw.ingress.kubernetes.io/ssl-redirect: "false"
appgw.ingress.kubernetes.io/use-private-ip: "false"
{{- range $key, $value := .Values.appgw.ingress.annotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Additional HTTP2 paths block shared by ALB and AppGW flyte ingresses.
Expects dict: paths (list of {path, pathType, serviceName?, servicePort?}), releaseName (string)
*/}}
{{- define "tfy-istio-ingress.additionalHttp2Paths" -}}
{{- range .paths }}
- path: {{ .path }}
  pathType: {{ .pathType }}
  backend:
    service:
      name: {{ .serviceName | default $.releaseName }}
      port:
        number: {{ .servicePort | default 80 }}
{{- end }}
{{- end }}