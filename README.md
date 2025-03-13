# TrueFoundry Infra Charts

Please visit the [GitHub Repo](https://github.com/truefoundry/infra-charts) for sources

## To enable scraping metrics for a particular service
1. Create a service monitor object in `charts/tfy-prometheus-config/templates/serviceMonitors`
2. Add an entry in `charts/tfy-prometheus-config/values.yaml`
3. Add an entry in `charts/tfy-prometheus-config/templates/_helpers.tpl`
4. Update the chart version in `charts/tfy-prometheus-config/Chart.yaml`
5. Create a corresponding entry in [here](https://github.com/truefoundry/ubermold-base/blob/main/k8s/%7B%7Bcookiecutter.project_slug%7D%7D/templates/%7B%25%20if%20cookiecutter.prometheus.config.enabled%20%3D%3D%20%22True%22%20%25%7Dprometheus-config.yaml%7B%25%20endif%20%25%7D) and update chart version
