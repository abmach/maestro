<#
.SYNOPSIS
Web bootstrap for Maestro — downloads the repo archive and runs the bundled installer.
No clone required.

.DESCRIPTION
Fetch a zip/tarball of the repository, extract to a temp dir, and invoke the
bundled Install-Maestro.ps1 with your parameters. Only the TARGET repo keeps
anything afterwards; the downloaded sources are cleaned up.

Canonical one-liner (note the scriptblock wrapper — plain `irm | iex` cannot
pass parameters):

  & ([scriptblock]::Create((irm https://gitlab.com/arthur_b_machado/maestro/-/raw/main/tools/install-from-web.ps1))) `
      -Target D:\repos\my-app -Locations .omp,.claude -Force

Pin an immutable release instead of the moving main branch:

  ... -Version v0.4.0-public ...

Remote code disclosure: this downloads and EXECUTES code from the given URL.
Review the source or pin -Version before running blind.
#>
[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [string[]]$Locations = @(".agents"),
    [string]$Version,                       # e.g. v0.4.0-public; omit for main branch
    [switch]$Clean,
    [switch]$Force,
    [string]$RepoBase = 'https://gitlab.com/arthur_b_machado/maestro',
    [string]$ArchivePath                    # offline/testing override: use a local archive
)

$ErrorActionPreference = "Stop"

$ref = if ($Version) { $Version } else { 'main' }
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('maestro-web-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

try {
    if ($ArchivePath) {
        Write-Host "Using local archive: $ArchivePath"
        $archive = Join-Path $tmp 'bundle-archive'
        Copy-Item -LiteralPath $ArchivePath -Destination $archive -Force
    }
    else {
        $url = "$RepoBase/-/archive/$ref/" + $(if ($Version) { "maestro-$ref" } else { "maestro-main" }) + '.zip'
        Write-Host "Downloading $url"
        $archive = Join-Path $tmp ('maestro-' + $ref + '.zip')
        Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing
    }

    # Access sanity: private repos / bot-protection return HTML (sign-in page or
    # Cloudflare challenge) instead of an archive. Fail with actionable guidance
    # BEFORE extraction. Real zips start with the PK magic bytes.
    $bytes = [System.IO.File]::ReadAllBytes($archive)
    $head = [System.Text.Encoding]::ASCII.GetString($bytes, 0, [Math]::Min(4096, $bytes.Length))
    if ($head -notmatch '^PK' -or $head -match '<html' -or $head -match '_cf_chl_opt' -or $head -match 'sign_in') {
        Remove-Item -LiteralPath $archive -Force -ErrorAction SilentlyContinue
        throw "GitLab did not return an archive (repo is private, or bot-protection challenged this client). Make the project public / run from an unrestricted network, or clone the repo and run .\Install-Maestro.ps1 locally."
    }

    Expand-Archive -LiteralPath $archive -DestinationPath $tmp

    # Locate the extracted source root: either a wrapped "<repo>-<ref>" dir
    # (web archives) or files at the extraction root (git archive / local zips).
    $src = Get-ChildItem -LiteralPath $tmp -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'Install-Maestro.ps1') } |
        Select-Object -First 1
    if (-not $src) { $src = Get-Item -LiteralPath $tmp }
    if (-not (Test-Path (Join-Path $src.FullName 'Install-Maestro.ps1'))) {
        throw "Installer not found inside archive (looked under $($tmp))"
    }

    Write-Host "Running bundled installer from $($src.FullName)"
    & (Join-Path $src.FullName 'Install-Maestro.ps1') -Target $Target -Locations $Locations -Clean:$Clean -Force:$Force
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
