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

By default the pod runs on the namespace `default` SA, so `<k8s-sa>` is `default`. Annotate that SA yourself if you want ADC to become the robot SA:

```bash
kubectl -n <namespace> annotate sa default \
  iam.gke.io/gcp-service-account=robot@gcp-project.iam.gserviceaccount.com
```

Because the binding is on `default`, every pod in that namespace can impersonate the robot SA. Install into a namespace dedicated to this bridge, or use a dedicated SA instead:

```yaml
serviceAccount:
  create: true
  annotations:
    iam.gke.io/gcp-service-account: robot@gcp-project.iam.gserviceaccount.com
```

That creates K8s SA `<release>-tfy-scim-bridge`, and the Token Creator binding must name it instead of `default`. Annotations are ignored when `serviceAccount.create` is `false`.

The robot SA still needs domain-wide delegation in Google Admin (Directory readonly scopes) with `googleAdminEmail` as the impersonated admin.

Without WI, set `secret.googleSaJsonB64` to `base64 -i sa.json | tr -d '\n'`. Do not set `GOOGLE_APPLICATION_CREDENTIALS`.

## Parameters

