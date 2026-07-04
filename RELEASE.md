# Releasing `truefoundry` and `tfy-llm-gateway`

Most charts in this repo are released the traditional way: bump the version
in a PR, merge to `main`, and `release.yaml` (chart-releaser) tags +
publishes it. **`truefoundry` and `tfy-llm-gateway` do not follow that
path.** This doc explains how they actually get here and why.

## Where these two charts actually come from

They are copied into this repo by `truefoundry/helm-charts`' own release
pipeline (`release-start.yml` there), not edited directly here. Do not open
a PR against this repo to change either chart's `Chart.yaml` version, or to
fix a template bug in `charts/truefoundry/` / `charts/tfy-llm-gateway/` —
make the change in `truefoundry/helm-charts` instead and run its release
pipeline. See `.github/workflows/block-version-bump-on-main.yaml`, which
rejects a PR into `main` here that changes either chart's version, for
exactly this reason.

## The branch model

Whenever helm-charts ships a **final** release (a bare `truefoundry-X.Y.Z`
git tag there — RCs never reach this repo at all), its
`release-public-truefoundry.yaml` workflow:

1. Ensures a branch here named `release/truefoundry-<VERSION>` exists (cut
   from this repo's `main` if it doesn't) — e.g.
   `release/truefoundry-0.156.0`. It carries the same `truefoundry-X.Y.Z`
   string as the git tag on the helm-charts side, under a `release/` prefix.
   The prefix is load-bearing, not cosmetic: a branch named EXACTLY
   `truefoundry-<VERSION>` collides with the identically-named git tag
   chart-releaser mints in this repo, and git short-ref resolution
   (`actions/checkout`, `create-pull-request`) breaks on the ambiguity for
   every run after the tag exists.
2. Copies `truefoundry` + `tfy-llm-gateway` into that branch via a PR, then
   auto-merges it (only after that PR's own checks pass).
3. That push triggers `release.yaml` (gh-pages) and
   `artifactory-helm-release.yaml` (public + inframold OCI) here — both
   trigger on `release/truefoundry-[0-9]*` branch pushes, not just `main`.
4. **Only if this was the current latest shipped line**, that branch is ALSO
   fast-forwarded into this repo's `main` (same "latest-line-only" rule
   helm-charts applies to its own `main`). An older-line hotfix final still
   completes steps 1–3 — it publishes — it just never touches `main` here.

`tfy-llm-gateway` is versioned independently of `truefoundry` (they can ship
different patch numbers in the same release) and separately gets its own
`release/tfy-llm-gateway-<its own version>` branch as a pure reference
snapshot, so its version history is browsable on its own even when it
diverges from the umbrella's version. That branch is inert — it never merges
anywhere and can't trigger a publish (its name doesn't match either publish
trigger).

## The "Latest" release badge

chart-releaser is configured to never implicitly mark a newly-created
release as the repo's Latest (`CR_MAKE_RELEASE_LATEST: false`) — GitHub
defaults the badge to the newest-CREATED release, so an older-line hotfix
(e.g. `truefoundry-0.140.6` shipped after `0.148.0`) would otherwise steal
it from the actual newest version. A step in `release.yaml` deterministically
re-asserts the highest-semver final `truefoundry-X.Y.Z` release as Latest
after every run.

## Why `main` doesn't publish these two charts

`release.yaml` / `artifactory-helm-release.yaml` both explicitly strip
`charts/truefoundry` and `charts/tfy-llm-gateway` from the working tree
before running, when triggered from `main`. This is deliberate: RCs and
older-line hotfixes structurally cannot reach `main` (main only advances for
the latest line), so if these charts' publish were gated on a `main` merge,
those cases could never publish at all. Publishing off the branch push
instead — decoupled from whether `main` ever advances — is what makes an
RC deployable for QA and an older-line hotfix shippable to its own customer
cluster.

## If something looks wrong

- **A manual PR bumping one of these charts' versions against `main` gets
  rejected** — this is `block-version-bump-on-main.yaml` working as
  intended. Make the fix in `truefoundry/helm-charts` instead.
- **A version seems to be "stuck" on an old value on `main`** — check
  whether it's actually an older-line release: `main` here only ever
  reflects the *latest* line, by design, not everything that's ever shipped.
  Check the `release/truefoundry-<VERSION>` branch and the git tag directly.
