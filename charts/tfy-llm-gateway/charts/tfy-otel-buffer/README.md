# tfy-otel-buffer helm chart by Truefoundry

Disk-buffered delivery of AI Gateway traces. The gateway exports traces over OTLP to tfy-otel-buffer, which writes them to a disk buffer on a PersistentVolume per replica and forwards them to the control plane tfy-otel-collector (`<global.controlPlaneURL>/api/otel/v1/traces`), retrying until delivery succeeds. The same traces can also be sent to additional OTLP destinations with `additionalSinks`.

This chart is a subchart of `tfy-llm-gateway`. It is deployed by default (`enableOtelBuffer: true`), and the gateway exports traces to it. Set `enableOtelBuffer: false` to skip it. Its values go under the `tfy-otel-buffer` key of the gateway values (`tfy-llm-gateway.tfy-otel-buffer` in the `truefoundry` chart). Changing only these values does not restart the gateway pods, and sink changes are reloaded without restarting the buffer pods.

## Prerequisites

In the gateway namespace:

- `global.controlPlaneURL` is set.
- The `truefoundry-creds` Secret with the `TFY_API_KEY` key.
- A StorageClass that can provision `ReadWriteOnce` volumes (3 PVCs of `22Gi` with the defaults).

Optional overrides in the `tfy-llm-gateway` values:

```yaml
# enableOtelBuffer: true   # default
tfy-otel-buffer:
  additionalSinks: {}
```

## Disk budget

Each replica's volume (`persistence.size`, default `22Gi`) is shared by every disk buffer:

- `buffer.maxSizeBytes` (default 15 GiB) for the control plane sink.
- `buffer.headroomBytes` (default 2 GiB) kept free for buffer overhead.
- The rest (5 GiB with the defaults) for the disk buffers of all `additionalSinks` together. Growing `persistence.size` gives the extra space to them.

The chart fails to render when the additional sinks' disk buffers do not fit in what is left.

## Additional sinks

Each entry under `additionalSinks` is one sink, keyed by sink ID, and is passed through as written. Entries that do not set `inputs` or `buffer` get them from `additionalSinkDefaults` (the gateway traces, and a 10,000-event memory buffer that drops new spans when full).

Store credentials in a Secret named `tfy-otel-buffer-sink-credentials` (or set `additionalSinksCredentials.secretName`) and reference each key as `SECRET[additional_sink_credentials.<KEY>]`:

```yaml
tfy-otel-buffer:
  additionalSinks:
    logfire:
      type: opentelemetry
      buffer:
        type: disk
        max_size: 5368709120
        when_full: drop_newest
      protocol:
        type: http
        uri: https://logfire-us.pydantic.dev/v1/traces
        method: post
        compression: gzip
        encoding:
          codec: otlp
        request:
          headers:
            Authorization: "SECRET[additional_sink_credentials.LOGFIRE_TOKEN]"
```

## Parameters

### Global parameters

| Name                                               | Description                                                                                                                      | Value                      |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `global.controlPlaneURL`                           | Control plane URL. Traces are forwarded to <controlPlaneURL>/api/otel/v1/traces (tfy-otel-collector).                            | `""`                       |
| `global.namespaceOverride`                         | Namespace override (defaults to the release namespace)                                                                           | `""`                       |
| `global.imagePullSecrets`                          | Image pull secrets, used when imagePullSecrets is empty                                                                          | `[]`                       |
| `global.truefoundryImagePullConfigJSON`            | When set (truefoundry chart creates truefoundry-image-pull-secret from it), that secret is used if no other pull secrets are set | `""`                       |
| `global.labels`                                    | Labels added to every resource                                                                                                   | `{}`                       |
| `global.annotations`                               | Annotations added to every resource                                                                                              | `{}`                       |
| `global.podLabels`                                 | Labels added to every pod                                                                                                        | `{}`                       |
| `global.podAnnotations`                            | Annotations added to every pod                                                                                                   | `{}`                       |
| `global.tolerations`                               | Tolerations, used when tolerations is empty                                                                                      | `[]`                       |
| `global.nodeSelector`                              | Node selector, merged under nodeSelector                                                                                         | `{}`                       |
| `global.affinity`                                  | Affinity, used when affinity is empty                                                                                            | `{}`                       |
| `global.image.registry`                            | Registry for images that do not set their own                                                                                    | `tfy.jfrog.io`             |
| `global.customCA.enabled`                          | Bool to trust a custom CA                                                                                                        | `false`                    |
| `global.customCA.certificate`                      | PEM-encoded CA certificate. The chart creates a ConfigMap with it.                                                               | `""`                       |
| `global.customCA.existingConfigMap.name`           | Name of the existing ConfigMap                                                                                                   | `""`                       |
| `global.customCA.existingConfigMap.overrideCAList` | When true, the ConfigMap replaces the system CA bundle instead of being merged into it                                           | `false`                    |
| `global.customCA.image.registry`                   | Registry for the initContainer image (defaults to global.image.registry)                                                         | `""`                       |
| `global.customCA.image.repository`                 | Repository for the initContainer image                                                                                           | `tfy-mirror/alpine`        |
| `global.customCA.image.tag`                        | Tag for the initContainer image                                                                                                  | `3.21`                     |
| `global.customCA.securityContext`                  | Security context for the custom CA initContainer                                                                                 | `{}`                       |
| `global.mTLS.tlsSecretName`                        | Secret holding ca.crt, tls.crt, and tls.key                                                                                      | `truefoundry-internal-tls` |
| `global.mTLS.externalMtlsSecret`                   | Use this Secret instead of tlsSecretName                                                                                         | `""`                       |

### OTEL buffer

| Name                                          | Description                                                                                                                                      | Value                                                                             |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| `nameOverride`                                | Override the chart name in labels                                                                                                                | `""`                                                                              |
| `fullnameOverride`                            | Name of the StatefulSet and Service (defaults to tfy-otel-buffer)                                                                                | `""`                                                                              |
| `replicaCount`                                | Number of replicas. Each replica has its own disk buffer.                                                                                        | `3`                                                                               |
| `image.registry`                              | Image registry (defaults to global.image.registry)                                                                                               | `""`                                                                              |
| `image.repository`                            | Image repository                                                                                                                                 | `tfy-mirror/timberio/vector`                                                      |
| `image.tag`                                   | Image tag                                                                                                                                        | `0.58.0-distroless-libc`                                                          |
| `image.pullPolicy`                            | Image pull policy                                                                                                                                | `IfNotPresent`                                                                    |
| `imagePullSecrets`                            | Image pull secrets. Falls back to global.imagePullSecrets, then truefoundry-image-pull-secret when global.truefoundryImagePullConfigJSON is set. | `[]`                                                                              |
| `buffer.maxSizeBytes`                         | Disk buffer for the control plane sink (tfy_otel_traces), per replica. Default 15 GiB.                                                           | `16106127360`                                                                     |
| `buffer.whenFull`                             | Behavior when the control plane buffer is full: drop_newest or block                                                                             | `drop_newest`                                                                     |
| `buffer.headroomBytes`                        | Disk kept free on each volume for buffer overhead. Default 2 GiB.                                                                                | `2147483648`                                                                      |
| `forward.compression`                         | Compression for the control plane export: gzip, none, snappy, zlib, or zstd                                                                      | `gzip`                                                                            |
| `forward.timeoutSecs`                         | Request timeout in seconds                                                                                                                       | `60`                                                                              |
| `forward.retryInitialBackoffSecs`             | Initial retry backoff in seconds                                                                                                                 | `1`                                                                               |
| `forward.retryMaxDurationSecs`                | Max retry backoff in seconds (retries are unlimited)                                                                                             | `120`                                                                             |
| `forward.retryStatusCodes`                    | HTTP status codes that are retried                                                                                                               | `[]`                                                                              |
| `forward.batch.maxBytes`                      | Max uncompressed batch size in bytes                                                                                                             | `10000000`                                                                        |
| `forward.batch.maxEvents`                     | Max spans per batch (null for no limit)                                                                                                          | `nil`                                                                             |
| `forward.batch.timeoutSecs`                   | Max age of a batch in seconds before it is sent                                                                                                  | `1`                                                                               |
| `forward.apiKeySecret.name`                   | Secret name                                                                                                                                      | `truefoundry-creds`                                                               |
| `forward.apiKeySecret.key`                    | Key in the Secret                                                                                                                                | `TFY_API_KEY`                                                                     |
| `additionalSinks`                             | Additional sinks keyed by sink ID                                                                                                                | `{}`                                                                              |
| `additionalSinkDefaults.inputs`               | Default inputs (the gateway traces)                                                                                                              | `[]`                                                                              |
| `additionalSinkDefaults.buffer`               | Default buffer                                                                                                                                   | `{}`                                                                              |
| `additionalSinksCredentials.secretName`       | Secret name. Each key is available as SECRET[additional_sink_credentials.<KEY>].                                                                 | `tfy-otel-buffer-sink-credentials`                                                |
| `mtls.enabled`                                | Require mTLS on the OTLP receivers (forced on by global.mTLS.enabled)                                                                            | `false`                                                                           |
| `logLevel`                                    | Log filter                                                                                                                                       | `info,vector::internal_events::http_client=debug,vector::sinks::util::http=debug` |
| `maxDecompressedSizeBytes`                    | Max decompressed OTLP request body size in bytes (HTTP and gRPC)                                                                                 | `256000000`                                                                       |
| `env`                                         | Extra environment variables                                                                                                                      | `[]`                                                                              |
| `persistence.enabled`                         | Create a PVC per replica. When false, buffers live in an emptyDir and are lost on reschedule.                                                    | `true`                                                                            |
| `persistence.size`                            | PVC size per replica                                                                                                                             | `22Gi`                                                                            |
| `persistence.storageClassName`                | Storage class for the PVC (empty uses the cluster default)                                                                                       | `""`                                                                              |
| `resources`                                   | Resource requests and limits                                                                                                                     | `{}`                                                                              |
| `nodeSelector`                                | Node selector (merged onto global.nodeSelector)                                                                                                  | `{}`                                                                              |
| `tolerations`                                 | Tolerations (falls back to global.tolerations)                                                                                                   | `[]`                                                                              |
| `affinity`                                    | Affinity (falls back to global.affinity)                                                                                                         | `{}`                                                                              |
| `podLabels`                                   | Extra pod labels                                                                                                                                 | `{}`                                                                              |
| `podAnnotations`                              | Extra pod annotations                                                                                                                            | `{}`                                                                              |
| `podSecurityContext`                          | Pod security context                                                                                                                             | `{}`                                                                              |
| `securityContext`                             | Container security context                                                                                                                       | `{}`                                                                              |
| `terminationGracePeriodSeconds`               | Time to flush in-flight batches on shutdown                                                                                                      | `60`                                                                              |
| `serviceAccount.create`                       | Create the service account                                                                                                                       | `true`                                                                            |
| `serviceAccount.name`                         | Service account name (defaults to the fullname)                                                                                                  | `""`                                                                              |
| `serviceAccount.annotations`                  | Service account annotations                                                                                                                      | `{}`                                                                              |
| `serviceAccount.automountServiceAccountToken` | Mount the service account token (the buffer has no RBAC)                                                                                         | `false`                                                                           |
| `readinessProbe`                              | Readiness probe                                                                                                                                  | `{}`                                                                              |
| `livenessProbe`                               | Liveness probe                                                                                                                                   | `{}`                                                                              |
| `podMonitor.enabled`                          | Enable PodMonitor                                                                                                                                | `true`                                                                            |
| `podMonitor.interval`                         | Scrape interval                                                                                                                                  | `30s`                                                                             |
| `podMonitor.additionalLabels`                 | Additional PodMonitor labels                                                                                                                     | `{}`                                                                              |
