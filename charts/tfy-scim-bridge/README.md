# tfy-scim-bridge

Syncs Google Workspace users and groups into TrueFoundry over SCIM, for Workspace tenants that cannot push SCIM themselves.

It runs in your cluster, polls the Google Directory API, and calls the TrueFoundry SCIM endpoint. All traffic is outbound, so the chart has no Service or Ingress.

Groups become TrueFoundry teams named after the group email local part, so `platform-team@acme.com` becomes team `platform-team`. Only direct user members are synced; members that are themselves groups are skipped.

## Before you install

1. Enable SCIM on your Google SSO connection in TrueFoundry. Note the SCIM base URL and token.
2. Create a GCP service account for reading the Directory, and enable the **Admin SDK API** in that project.
3. In Google Admin, go to **Security → Access and data control → API controls → Domain-wide delegation** and authorize that service account's **Client ID** (its numeric Unique ID) for these scopes:

   ```
   https://www.googleapis.com/auth/admin.directory.user.readonly
   https://www.googleapis.com/auth/admin.directory.group.readonly
   https://www.googleapis.com/auth/admin.directory.group.member.readonly
   ```

4. Pick a Workspace **user** who is a super admin. The bridge impersonates that account, so it must be a real user, not a group alias.

## Install

```bash
helm repo add truefoundry https://truefoundry.github.io/infra-charts
helm repo update

helm install tfy-scim-bridge truefoundry/tfy-scim-bridge \
  --namespace tfy-scim-bridge --create-namespace \
  -f my-values.yaml
```

A minimal `my-values.yaml`:

```yaml
googleAdminEmail: admin@acme.com
googleServiceAccountEmail: directory-reader@my-project.iam.gserviceaccount.com
googleGroupEmails: platform-team@acme.com
scimBaseUrl: https://<control-plane>/api/svc/v1/scim/v2/<tenant>/<ssoId>
secret:
  scimToken: <scim-token>
dryRun: true
```

Leave `dryRun: true` for the first install and check the logs to see what would be created. Set it to `false` once the plan looks right.

Leave `googleGroupEmails` empty only if you want every user and group in the Workspace synced.

Keep `replicaCount` at 1. This is a single poller, and the Deployment uses the `Recreate` strategy so an upgrade never runs two of them at once.

## Directory credentials

Choose one of the following.

### GKE Workload Identity (recommended)

No key material is stored in the cluster. Set `googleServiceAccountEmail` to the service account from step 2, then grant **Service Account Token Creator** on it to the Kubernetes service account the pod runs as:

```bash
gcloud iam service-accounts add-iam-policy-binding \
  directory-reader@my-project.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator \
  --member="serviceAccount:<gke-project>.svc.id.goog[tfy-scim-bridge/default]"
```

By default the pod runs as the namespace `default` service account, which is why the binding above names `default`. That grant lets any pod in the namespace impersonate the service account, so install into a namespace used only by this chart.

To use a dedicated service account instead, set the following and bind the role to `<release>-tfy-scim-bridge` rather than `default`:

```yaml
serviceAccount:
  create: true
```

`serviceAccount.annotations` are only applied to a service account this chart creates. If you keep the default `serviceAccount.create: false`, annotate the existing service account yourself.

### Service account key

Where Workload Identity is not available, pass the key JSON instead:

```bash
base64 -i sa.json | tr -d '\n'
```

Put the result in `secret.googleSaJsonB64`. The chart stores it in the release Secret under `secret.googleSaJsonB64Key` (default `GOOGLE_SA_JSON_B64`) and the bridge decodes it at startup.

To reuse an existing Secret, set `secret.existingName` and the key names. The chart then does not create a Secret:

```yaml
secret:
  existingName: my-scim-bridge-secret
  scimTokenKey: SCIM_TOKEN
  googleSaJsonB64Key: GOOGLE_SA_JSON_B64
```

Leave `googleSaJsonB64Key` empty when the existing Secret has no Google key (Workload Identity).

## Parameters

