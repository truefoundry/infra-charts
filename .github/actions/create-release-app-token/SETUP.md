# Release GitHub App — org setup

Workflows no longer use `TF_GITHUB_CI_ADMIN_TOKEN` (PAT). They mint an
installation token via this composite action.

## Required org/repo secrets

| Secret | Value |
| --- | --- |
| `RELEASE_GITHUB_APP_ID` | App ID (or Client ID) of the release GitHub App |
| `RELEASE_GITHUB_APP_PRIVATE_KEY` | Full PEM private key for that App |

Grant these secrets to **helm-charts**, **ubermold-base**, **infra-charts**, and
any other repo whose workflows call this action (org secrets + selected repos,
or duplicate per repo).

## App permissions (repository)

- Actions: read & write
- Contents: read & write
- Issues: read & write
- Metadata: read
- Pull requests: read & write
- Workflows: write (only if a job edits workflow files)

Install on all repos the release flow touches (or **All repositories**).

## Branch protection / rulesets

Grant this App **bypass** on protected branches involved in auto-merge
(helm-charts, infra-charts, service repos, ubermold-*, tfy-*-gitops, docs).
Workflows use plain `gh pr merge` (no `--admin`); bypass replaces the old
SaaS PAT admin merge.

## Spike

1. Mint a token locally or in a disposable workflow with this action.
2. Open a throwaway PR and run `gh pr merge <n> --squash` with that token.
3. Confirm merge succeeds with bypass and fails without it.

## After cutover — delete PATs

Once greps are clean in helm-charts / ubermold-base and release-app no longer
reads `TF_GITHUB_CI_ADMIN_TOKEN`, delete org/repo secrets:

- `TF_GITHUB_CI_ADMIN_TOKEN`
- `SAAS_GITHUB_TOKEN` (if present)
- `TRUEFOUNDRY_HELM_TOKEN` (if still present anywhere)

`infra-charts` release / stale workflows also mint this App token (still join
Tailscale for org IP allow-list egress). `bot-commit.yml` keeps the dedicated
`infra-charts-bot` App for artifact download + push.
