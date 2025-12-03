# tfy-cert-mamager-config

## Parameters

### Configuration for certificate manager

| Name                                  | Description                                                                 | Value              |
| ------------------------------------- | --------------------------------------------------------------------------- | ------------------ |
| `namespace`                           | Namespace where cert-manager resources (Issuer/Certificate) will be created | `istio-system`     |
| `issuer.name`                         | Name of the cert-manager Issuer or ClusterIssuer to be created              | `""`               |
| `issuer.type`                         | DNS solver type to use for certificate challenges (cloudDNS | azureDNS)     | `""`               |
| `issuer.privateKeySecretRef`          | Secret name that stores the Issuer private key (optional)                   | `""`               |
| `issuer.cloudDNS.project`             | GCP project ID used for DNS-01 challenge                                    | `""`               |
| `issuer.azureDNS.hosted_zone_name`    | DNS zone name to use for DNS-01 verification                                | `""`               |
| `issuer.azureDNS.resource_group_name` | Resource group name where the DNS zone is located                           | `""`               |
| `issuer.azureDNS.subscription_id`     | Subscription ID for the Azure account                                       | `""`               |
| `issuer.azureDNS.environment`         | Azure environment (e.g., AzurePublicCloud)                                  | `AzurePublicCloud` |
| `issuer.azureDNS.identity_client_id`  | Client ID of the user-assigned managed identity                             | `""`               |
| `certificate.name`                    | Name of the certificate resource to create                                  | `""`               |
| `certificate.secretName`              | Name of the Kubernetes secret where the TLS certificate will be stored      | `""`               |
| `certificate.domain_names`            | List of domain names to include in the certificate                          | `[]`               |
| `certificate.duration`                | Total lifetime of the certificate (default 90 days)                         | `2160h`            |
| `certificate.renewBefore`             | Time before expiry when renewal should start (default 15 days)              | `360h`             |
