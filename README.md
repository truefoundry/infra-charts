# TrueFoundry Infra Charts

Please visit the [GitHub Repo](https://github.com/truefoundry/infra-charts) for sources

See [RELEASE.md](./RELEASE.md) for how `truefoundry` and `tfy-llm-gateway`
specifically are released — they follow a different flow from every other
chart in this repo.

## Do not hand-edit the `*-inframold` charts

The five inframold charts are **generated and copied into this repo by an
upstream pipeline** — they are not authored here:

- `charts/tfy-k8s-aws-eks-inframold/`
- `charts/tfy-k8s-azure-aks-inframold/`
- `charts/tfy-k8s-civo-talos-inframold/`
- `charts/tfy-k8s-gcp-gke-standard-inframold/`
- `charts/tfy-k8s-generic-inframold/`

Every change to them arrives as a bot commit (`[CI] Publish inframold charts
version to X.Y.Z`, authored by `truefoundry-saas`). A manual edit here is
**silently reverted by the next publish** — you get a green PR, a released
chart, and a fix that vanishes days later with nothing pointing at why.

The tell that these five are generated, not maintained: the same block is
byte-identical across all five files, at the same line number. If you find
yourself making the identical edit five times, stop — that is the generator's
job, and you are editing its output.

**To change one of these charts, make the change in the upstream generator and
let it publish** — not here.

A real instance of this trap: the Spark job monitoring dashboards were blank
because `spark-role` and `sparkoperator.k8s.io/app-name` were missing from the
kube-state-metrics `metricLabelsAllowlist` in `templates/prometheus.yaml`.
Adding them to all five charts here would have shipped, then been reverted by
the next publish.

Everything else in `charts/` is authored here and safe to edit directly — with
the exception of `charts/truefoundry/` and `charts/tfy-llm-gateway/`, which come
from `truefoundry/helm-charts` for the same reason (see
[RELEASE.md](./RELEASE.md)).

## To enable scraping metrics for a particular service
1. Create a service monitor object in `charts/tfy-prometheus-config/templates/serviceMonitors`
2. Add an entry in `charts/tfy-prometheus-config/values.yaml`
3. Add an entry in `charts/tfy-prometheus-config/templates/_helpers.tpl`
4. Update the chart version in `charts/tfy-prometheus-config/Chart.yaml`
5. Create a corresponding entry in [here](https://github.com/truefoundry/ubermold-base/blob/main/k8s/%7B%7Bcookiecutter.project_slug%7D%7D/templates/%7B%25%20if%20cookiecutter.prometheus.config.enabled%20%3D%3D%20%22True%22%20%25%7Dprometheus-config.yaml%7B%25%20endif%20%25%7D) and update chart version
