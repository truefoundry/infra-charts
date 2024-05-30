# TrueFoundry LLM Gateway Monitoring Stack

## Parameters

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