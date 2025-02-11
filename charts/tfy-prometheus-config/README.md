# Prometheus Config

This chart is used to configure prometheus. It is used to configure the scrape configs, alert managers, prometheus rules, and service monitors for prometheus.

## Parameters

### Configuration for tfy-prometheus-config

| Name                                           | Description                                     | Value                     |
| ---------------------------------------------- | ----------------------------------------------- | ------------------------- |
| `scrapeConfigs.envoy.enabled`                  | Enable scrape config for envoy                  | `true`                    |
| `scrapeConfigs.envoy.name`                     | Name of the scrape config                       | `envoy-stats`             |
| `scrapeConfigs.envoy.extraKubernetesSDConfigs` | Extra kubernetes SD configs for envoy           | `[]`                      |
| `scrapeConfigs.pods.enabled`                   | Enable scrape config for kubernetes pods        | `true`                    |
| `scrapeConfigs.pods.name`                      | Name of the scrape config                       | `kubernetes-pods`         |
| `scrapeConfigs.pods.extraKubernetesSDConfigs`  | Extra kubernetes SD configs for kubernetes pods | `[]`                      |
| `scrapeConfigs.additionalScrapeConfigs`        | Additional scrape configs for prometheus        | `[]`                      |
| `alertManagers.tfyAgent.enabled`               | Enable alert manager for tfy-agent              | `true`                    |
| `alertManagers.tfyAgent.name`                  | Name of the alert manager                       | `tfy-alertmanager-config` |
| `prometheusRules.kubecost.enabled`             | Enable prometheus rules for kubecost            | `true`                    |
| `prometheusRules.kubecost.name`                | Name of the prometheus rules                    | `tfy-alertmanager-config` |
| `serviceMonitors.enabled`                      | Enable service monitors for prometheus          | `true`                    |
| `serviceMonitors.workflows.enabled`            | Enable service monitor for workflows            | `true`                    |
| `serviceMonitors.workflows.name`               | Name of the service monitor                     | `argo-workflows`          |
| `serviceMonitors.workflows.extraEndpoints`     | Extra endpoints for workflows                   | `[]`                      |
| `serviceMonitors.keda.enabled`                 | Enable service monitor for keda                 | `true`                    |
| `serviceMonitors.keda.name`                    | Name of the service monitor                     | `keda`                    |
| `serviceMonitors.keda.extraEndpoints`          | Extra endpoints for keda                        | `[]`                      |
| `serviceMonitors.elasti.enabled`               | Enable service monitor for elasti               | `true`                    |
| `serviceMonitors.elasti.name`                  | Name of the service monitor                     | `elasti-resolver`         |
| `serviceMonitors.elasti.extraEndpoints`        | Extra endpoints for elasti                      | `[]`                      |
| `serviceMonitors.kubecost.enabled`             | Enable service monitor for kubecost             | `true`                    |
| `serviceMonitors.kubecost.name`                | Name of the service monitor                     | `kubecost`                |
| `serviceMonitors.kubecost.extraEndpoints`      | Extra endpoints for kubecost                    | `[]`                      |
| `serviceMonitors.prometheus.enabled`           | Enable service monitor for prometheus           | `true`                    |
| `serviceMonitors.prometheus.name`              | Name of the service monitor                     | `prometheus`              |
| `serviceMonitors.prometheus.extraEndpoints`    | Extra endpoints for prometheus                  | `[]`                      |
| `serviceMonitors.loki.enabled`                 | Enable service monitor for loki                 | `true`                    |
| `serviceMonitors.loki.name`                    | Name of the service monitor                     | `loki`                    |
| `serviceMonitors.loki.extraEndpoints`          | Extra endpoints for loki                        | `[]`                      |
| `serviceMonitors.loki.promtail.enabled`        | Enable service monitor for promtail             | `true`                    |
| `serviceMonitors.loki.promtail.name`           | Name of the service monitor                     | `loki-promtail`           |
| `serviceMonitors.loki.promtail.extraEndpoints` | Extra endpoints for promtail                    | `[]`                      |
| `extraObjects`                                 | Extra objects for prometheus                    | `[]`                      |



