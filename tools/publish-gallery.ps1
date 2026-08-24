# Publishes the built MaestroKit module to the PowerShell Gallery.
# Prerequisites:
#   1. tools/build-module.ps1 has been run (dist/module/MaestroKit exists)
#   2. A PSGallery account with an API key (Account Settings -> API Key).
#      Recommend scoping the key: expiration date + Glob pattern 'MaestroKit*'.
#
# Usage:
#   ./tools/publish-gallery.ps1 -ApiKey <key>
#   (Run this yourself - never commit or paste the key anywhere.)
param(
    [Parameter(Mandatory)] [string]$ApiKey,
    [string]$Root,
    [string]$ModulePath
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
if (-not $ModulePath) { $ModulePath = Join-Path $Root "dist/module/MaestroKit" }

if (-not (Test-Path -LiteralPath (Join-Path $ModulePath "MaestroKit.psd1"))) {
    throw "module not found at $ModulePath - run tools/build-module.ps1 first"
}

$manifestVersion = (Import-PowerShellDataFile (Join-Path $ModulePath "MaestroKit.psd1")).ModuleVersion
$repoVersion = ([System.IO.File]::ReadAllText((Join-Path $Root "VERSION"))).Trim()
if ($manifestVersion -ne $repoVersion) {
    throw "module manifest version ($manifestVersion) != VERSION ($repoVersion) - rebuild first"
}

Publish-Module -Path $ModulePath -NuGetApiKey $ApiKey
Write-Host ("published: https://www.powershellgallery.com/packages/MaestroKit/" + $manifestVersion) -ForegroundColor Green
