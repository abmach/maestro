# Contributing / Maintainer guide

Everything here concerns *developing the Maestro bundle itself*. End users only need the Installation section of the README.

## Dev environment

- PowerShell 7+ (`pwsh`) and git
- No other dependencies — validators and smoke tests are self-contained

## Bundle edit loop

1. Edit sources (`skills/`, `agents/`, `references/`, installer, tools)
2. Run the consistency validator:
   ```powershell
   pwsh ./tools/validate-bundle.ps1
   ```
   Checks frontmatter, placeholders, markdown links, canonical Pre-flight blocks in every skill/agent, retry-rule consistency, references-map completeness, README counts, vocabulary drift.
3. Run the end-to-end install gate:
   ```powershell
   pwsh ./tools/smoke-install.ps1        # add -Keep to inspect the temp install
   ```
4. Update `CHANGELOG.md` (newest section on top) and bump `VERSION`.

## Code signing (release scripts)

User-facing scripts should be Authenticode-signed so execution policy and AV reputation treat them kindly. Two routes:

- **SignPath Foundation** (free for OSS): apply at signpath.org with this repo's GitHub URL. Remote signing — private key never local. Wire their GitHub Action/API into the tag-release flow.
- **Own certificate**: load a Code Signing cert into `Cert:\CurrentUser\My`, then:
  ```powershell
  ./tools/sign-release.ps1 -CertThumbprint <thumbprint>
  ```
  Timestamp server required; every target must verify `Valid`. Sign LAST — any byte change invalidates.

## Module packaging (MaestroKit)

```powershell
pwsh ./tools/build-module.ps1          # -> dist/module/MaestroKit (gitignored artifact)
```
Assembles payload + thin wrapper functions over the canonical scripts. Publish to the PowerShell Gallery once an account/API key exists:

```powershell
$env:MAESTRO_PSGALLERY_KEY = '<key>'   # once per machine
./tools/publish-gallery.ps1
```
Version guard enforced: manifest must equal `VERSION`. Each publish requires a bumped `ModuleVersion`.

## Release checklist

1. `CHANGELOG.md` section on top + `VERSION` bump
2. `tools/validate-bundle.ps1` → green
3. `tools/smoke-install.ps1` → green
4. Sign scripts (once certificate exists)
5. Create an annotated tag at the release commit:
   ```powershell
   git tag -a v<version> -m "<changelog highlights>"
   git push origin main v<version>
   ```
   Mirrors propagate branches and tags automatically.

## Supporter recognition sync

`SUPPORTERS.md` can be rebuilt from live GitHub Sponsors data:

```powershell
$env:MAESTRO_GH_TOKEN = '<PAT with read:user>'
./tools/sync-supporters.ps1 -DryRun   # preview
./tools/sync-supporters.ps1           # write; review diff, then commit & push via GitLab
```

Tier mapping: >= $25 Conductor's Circle, >= $10 Encore, else Applause. Cancelled sponsors drop out automatically. Conductor's Circle *Founding* permanence is honored by re-adding manually if desired (cancellations are reported by the API - the script does not silently forget founders).

Or per-backer: `./tools/add-supporter.ps1 -Name X -Tier Encore`.

## Repository policy

Development happens on GitLab; the GitHub repository is an automated read-only mirror — issues and PRs belong on GitLab.
