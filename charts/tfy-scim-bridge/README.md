# tfy-scim-bridge

Helm chart for the customer-run Google Workspace → TrueFoundry SCIM bridge.

The image is built from `truefoundry/tfy-dockerfiles` (`tfy-scim-bridge/`) and published as `tfy.jfrog.io/tfy-images/tfy-scim-bridge`. This process polls Directory and calls SCIM. It has no Service or Ingress.

## Install

```bash
helm install tfy-scim-bridge oci://tfy.jfrog.io/tfy-helm/tfy-scim-bridge \
  --namespace tfy-scim-bridge --create-namespace \
  --set googleAdminEmail=admin@customer.com \
  --set googleServiceAccountEmail=robot@gcp-project.iam.gserviceaccount.com \
  --set googleGroupEmails=aigateway@customer.com \
  --set scimBaseUrl='https://<control-plane>/api/svc/v1/scim/v2/<tenant>/<ssoId>' \
  --set secret.scimToken='<scim-jwt>' \
  --set dryRun=true
```

Keep `replicaCount` at 1. The Deployment uses `Recreate` so an upgrade does not run two pollers at once. Start with `dryRun=true`, then set `dryRun=false`.

From a local checkout of `infra-charts`:

```bash
helm install tfy-scim-bridge ./charts/tfy-scim-bridge -f my-values.yaml
```

Or after this chart is released from `truefoundry/infra-charts`:

```bash
helm repo add truefoundry https://truefoundry.github.io/infra-charts
helm install tfy-scim-bridge truefoundry/tfy-scim-bridge -f my-values.yaml
```

## GKE Workload Identity

Do not mount a JSON key. Set `googleServiceAccountEmail` to the Directory robot SA.

On that GCP SA, grant **Service Account Token Creator** to:

`serviceAccount:<gke-project>.svc.id.goog[<namespace>/<k8s-sa>]`

The chart creates K8s SA `<release>-tfy-scim-bridge` in the install namespace.

Optional (ADC becomes the robot SA). Annotate the K8s SA and grant **Workload Identity User**:

```yaml
serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: robot@gcp-project.iam.gserviceaccount.com
```

The robot SA still needs domain-wide delegation in Google Admin (Directory readonly scopes) with `googleAdminEmail` as the impersonated admin.

## Parameters
