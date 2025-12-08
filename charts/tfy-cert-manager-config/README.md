# tfy-cert-mamager-config

## Parameters

### Configuration for certificate manager

| Name                                       | Description                                                            | Value   |
| ------------------------------------------ | ---------------------------------------------------------------------- | ------- |
| `issuers.issuer1.name`                     | Name of the cert-manager Issuer or ClusterIssuer to be created         | `""`    |
| `issuers.issuer1.email`                    | Email address used for ACME registration and notifications             | `""`    |
| `issuers.issuer1.privateKeySecretRef`      | Secret name that stores the Issuer private key (optional)              | `""`    |
| `issuers.issuer1.solvers`                  | Solver configuration for the Issuer (optional, depending on type)      | `{}`    |
| `issuers.issuer1.certificate.name`         | Name of the certificate resource to create                             | `""`    |
| `issuers.issuer1.certificate.secretName`   | Name of the Kubernetes secret where the TLS certificate will be stored | `""`    |
| `issuers.issuer1.certificate.domain_names` | List of domain names to include in the certificate                     | `[]`    |
| `issuers.issuer1.certificate.duration`     | Total lifetime of the certificate (default 90 days)                    | `2160h` |
| `issuers.issuer1.certificate.renewBefore`  | Time before expiry when renewal should start (default 15 days)         | `360h`  |
