# Loki and Promtail charts packaged by Truefoundry.

## Loki configurations

https://github.com/grafana/loki/blob/c6a909b0ec52f2323f161e458e1fff99e9a1e6c0/production/helm/loki/values.yaml

## Promtail configurations

https://github.com/grafana/helm-charts/tree/8b9ca8240e4e412f72af2df42f833c94142a3d70/charts/promtail

## Parameters

### Upstream Loki configurations

| Name                                                           | Description                                                                                                                     | Value                               |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `loki.enabled`                                                 | Enable loki                                                                                                                     | `true`                              |
| `loki.loki.storage.type`                                       | Method to use for storage                                                                                                       | `filesystem`                        |
| `loki.loki.compactor.shared_store`                             | The shared store used for storing boltdb files.                                                                                 | `filesystem`                        |
| `loki.loki.compactor.retention_enabled`                        | Activate custom (per-stream,per-tenant) retention.                                                                              | `true`                              |
| `loki.loki.auth_enabled`                                       | Enables authentication through the X-Scope-OrgID header                                                                         | `false`                             |
| `loki.loki.limits_config.retention_period`                     | Retention period to apply to stored data.                                                                                       | `168h`                              |
| `loki.loki.limits_config.max_query_lookback`                   | Limit how far back in time series data and metadata can be queried, up until lookback duration ago.                             | `168h`                              |
| `loki.loki.limits_config.split_queries_by_interval`            | Split queries by a time interval and execute in parallel.                                                                       | `10h`                               |
| `loki.loki.limits_config.max_entries_limit_per_query`          | Maximum number of log entries that will be returned for a query.                                                                | `30000`                             |
| `loki.loki.limits_config.max_line_size`                        | Max line size of a log. If log exceeds this length, it will either be skipped or truncated depeneding on max_line_size_truncate | `20000`                             |
| `loki.loki.limits_config.max_line_size_truncate`               | If a log exceeds max_line_size, log will be truncated if set to true else skipped                                               | `true`                              |
| `loki.singleBinary.replicas`                                   | Number of replicas for the single binary                                                                                        | `1`                                 |
| `loki.singleBinary.resources.requests.cpu`                     | CPU requests for promtail container                                                                                             | `0.03`                              |
| `loki.singleBinary.resources.requests.memory`                  | Memory requests for promtail container                                                                                          | `250Mi`                             |
| `loki.singleBinary.persistence.size`                           | Size of persistent disk                                                                                                         | `50Gi`                              |
| `loki.singleBinary.persistence.enableStatefulSetAutoDeletePVC` | Enable StatefulSetAutoDeletePVC feature                                                                                         | `false`                             |
| `promtail.enabled`                                             | Enable promtail                                                                                                                 | `true`                              |
| `promtail.config.clients[0].url`                               | Loki push API URL                                                                                                               | `http://loki:3100/loki/api/v1/push` |
| `promtail.resources.requests.cpu`                              | CPU requests for promtail container                                                                                             | `40m`                               |
| `promtail.resources.requests.memory`                           | Memory requests for promtail container                                                                                          | `100Mi`                             |
| `promtail.resources.requests.ephemeral-storage`                | Ephemeral storage requests for promtail container                                                                               | `256Mi`                             |
