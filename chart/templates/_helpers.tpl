{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "aws-ecr-creds.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aws-ecr-creds.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "aws-ecr-creds.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aws-ecr-creds.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "aws-ecr-creds.labels" -}}
app.kubernetes.io/name: {{ include "aws-ecr-creds.name" . }}
helm.sh/chart: {{ include "aws-ecr-creds.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Pod labels
*/}}
{{- define "aws-ecr-creds.podLabels" -}}
app.kubernetes.io/name: {{ include "aws-ecr-creds.name" . }}
helm.sh/chart: {{ include "aws-ecr-creds.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "aws-ecr-creds.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aws-ecr-creds.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end -}}

{{/*
Create the total exception list
*/}}
{{- define "aws-ecr-creds.exceptionList" -}}
{{- $str := "" }}
{{- range $item := .Values.namespaceExceptions }}
{{- $str = print $str $item " " }}
{{- end }}
{{- range $item := .Values.additionalNamespaceExceptions }}
{{- $str = print $str $item " " }}
{{- end }}
{{- default "" $str }}
{{- end -}}

