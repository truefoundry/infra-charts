# TrueFoundry LLM Gateway Infra Stack

## Parameters

### global


### global.auth [object] auth config


### global.auth.nats [object] nats auth config

| Name                                                   | Description                                           | Value |
| ------------------------------------------------------ | ----------------------------------------------------- | ----- |
| `global.auth.nats.adminPassword`                       | password for nats admin user                          | `""`  |
| `global.auth.nats.llmGatewayRequestLoggerPassword`     | password for nats llm-gateway-request-logger user     | `""`  |
| `global.auth.nats.clickhouseRequestLogsReaderPassword` | password for nats clickhouse-request-logs-reader user | `""`  |

### global.auth.clickhouse [object] clickhouse auth config

| Name                              | Description         | Value  |
| --------------------------------- | ------------------- | ------ |
| `global.auth.clickhouse.user`     | clickhouse user     | `user` |
| `global.auth.clickhouse.password` | clickhouse password | `""`   |

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