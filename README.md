# TrueFoundry Infra Charts

This repository contains a collection of Helm charts for deploying TrueFoundry infrastructure components. 

The charts can be added to your Helm repository by running the following command:

```bash
helm repo add truefoundry https://truefoundry.github.io/infra-charts
helm repo update
```

To install a chart, run the following command:

```bash
helm install my-release truefoundry/<chart-name> 
```

Please visit the [GitHub Repo](https://github.com/truefoundry/infra-charts) for sources
