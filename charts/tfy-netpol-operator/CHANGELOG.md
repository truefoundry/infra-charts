## Changelog

### 0.2.2

- Chart moved into `truefoundry/infra-charts` from
  [truefoundry/network-policy-operator](https://github.com/truefoundry/network-policy-operator)
  (`deploy/helm/tfy-netpol-operator`). It is now released through this repo's
  standard pipeline: published to the `https://truefoundry.github.io/infra-charts`
  Helm repository and to `oci://tfy.jfrog.io/tfy-helm` on merge to `main`. The
  operator image continues to be built and published from the source repo.
- No template changes. `values.yaml` keys and defaults are unchanged; the file
  now carries `@param` annotations so the README parameter table is generated
  automatically, and `Chart.yaml` gained `maintainers`, `home`, `sources` and
  `keywords` metadata in line with other charts here.

### 0.2.1 and earlier

Released from `truefoundry/network-policy-operator`; see that repository's
[CHANGELOG](https://github.com/truefoundry/network-policy-operator/blob/main/CHANGELOG.md).
