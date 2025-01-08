# TrueFoundry LLM Gateway Infra Stack

## Parameters

### global

| Name                                            | Description                                 | Value |
| ----------------------------------------------- | ------------------------------------------- | ----- |
| `global.existingTruefoundryImagePullSecretName` | Existing truefoundry image pull secret name | `""`  |

### global.auth [object] auth config

| Name                     | Description | Value                        |
| ------------------------ | ----------- | ---------------------------- |
| `global.auth.secretName` | secret name | `tfy-llm-gateway-infra-auth` |

### global.auth.nats [object] nats auth config

| Name                                                      | Description                                           | Value                                          |
| --------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| `global.auth.nats.adminPasswordKey`                       | password for nats admin user                          | `NATS_ADMIN_PASSWORD`                          |
| `global.auth.nats.llmGatewayRequestLoggerPasswordKey`     | password for nats llm-gateway-request-logger user     | `NATS_LLM_GATEWAY_REQUEST_LOGGER_PASSWORD`     |
| `global.auth.nats.clickhouseRequestLogsReaderPasswordKey` | password for nats clickhouse-request-logs-reader user | `NATS_CLICKHOUSE_REQUEST_LOGS_READER_PASSWORD` |

### global.auth.clickhouse [object] clickhouse auth config

| Name                                 | Description         | Value |
| ------------------------------------ | ------------------- | ----- |
| `global.auth.clickhouse.passwordKey` | clickhouse password | `""`  |

### global.virtualService [object] virtual service config

| Name                                          | Description              | Value                       |
| --------------------------------------------- | ------------------------ | --------------------------- |
| `global.virtualService.enabled`               | enable virtual service   | `false`                     |
| `global.virtualService.gatewayName`           | gateway name             | `istio-system/tfy-wildcard` |
| `global.virtualService.natsServerHost`        | nats server host         | `""`                        |
| `global.virtualService.natsMetricsServerHost` | nats metrics server host | `""`                        |
| `global.virtualService.clickhouseServerHost`  | clickhouse server host   | `""`                        |

## Post Installtion Setup
### Add Logging Sink Configuration as env in TrueFoundry LLM Gateway

```
LOGGING_SINK_CONFIGURATION: >-
    {"type": "nats", 
    "url": "wss://<natsServerHost>", 
    "username": "llm-gateway-request-logger", 
    "password": "<llmGatewayRequestLoggerPassword>", 
    "subject": "tfy-model-logs.request-logs"}
```

### Add Clickhouse configuration as env in TrueFoundry Control Plane

```
CLICKHOUSE_HOST: https://<clickhouseServerHost>
CLICKHOUSE_USER: <clickhouse.user>
CLICKHOUSE_PASSWORD: <clickhouse.password>
```