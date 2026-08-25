# Builds the distributable PowerShell module (dist/module/MaestroKit/) from the
# repo sources. The module wraps the canonical scripts — zero logic duplication:
# Install-Maestro / Test-MaestroKit / Invoke-MaestroSmokeInstall invoke the
# bundled Install-Maestro.ps1, tools/validate-bundle.ps1 and tools/smoke-install.ps1.
param(
    [string]$Root,
    [string]$ModuleName = 'MaestroKit',
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
if (-not $OutputDir) { $OutputDir = Join-Path $Root ("dist/module/" + $ModuleName) }

$Version = ([System.IO.File]::ReadAllText((Join-Path $Root "VERSION"))).Trim()

# Latest CHANGELOG section becomes the gallery ReleaseNotes (flattened;
# single quotes doubled so the psd1 literal stays valid).
$clLines = (Get-Content -LiteralPath (Join-Path $Root "CHANGELOG.md")) -split "\r?\n"
$firstSection = ($clLines | Select-String -Pattern "^## " | Select-Object -First 1).LineNumber
$sectionLines = @()
for ($i = $firstSection - 1; $i -lt $clLines.Count; $i++) {
    if ($i -gt $firstSection - 1 -and $clLines[$i] -match "^## ") { break }
    if ($clLines[$i].Trim()) { $sectionLines += $clLines[$i].Trim() }
}
$ReleaseNotesFlat = ($sectionLines -join ' ').Replace("'", "''")

if (Test-Path -LiteralPath $OutputDir) { Remove-Item -LiteralPath $OutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

foreach ($item in @("skills", "references", "agents", "tools")) {
    Copy-Item -LiteralPath (Join-Path $Root $item) -Destination (Join-Path $OutputDir $item) -Recurse -Force
}
foreach ($file in @("Install-Maestro.ps1", "LICENSE", "CHANGELOG.md", "VERSION", "README.md")) {
    Copy-Item -LiteralPath (Join-Path $Root $file) -Destination (Join-Path $OutputDir $file) -Force
}

$manifest = @"
@{
    RootModule           = '$($ModuleName).psm1'
    ModuleVersion        = '$Version'
    GUID                 = 'b7e3a9c4-5d18-4f6a-9c2e-1a0d8f4b7e33'
    Author               = 'Arthur Biazon Machado'
    Description          = 'MaestroKit - plan/implement/test/document workflow installer, validators and packaging for AI coding agents.'
    Copyright            = '(c) 2026 Arthur Biazon Machado. MIT licensed.'
    PowerShellVersion    = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport    = @('Install-Maestro', 'Test-MaestroKit', 'Invoke-MaestroSmokeInstall')
    PrivateData          = @{
        PSData = @{
            Tags         = @('AgentSkills', 'AI', 'ClaudeCode', 'OpenCode', 'OhMyPi', 'Workflow')
            LicenseUri   = 'https://gitlab.com/arthur_b_machado/maestro/-/blob/main/LICENSE'
            ProjectUri   = 'https://gitlab.com/arthur_b_machado/maestro'
            ReleaseNotes = '$ReleaseNotesFlat'
        }
    }
}
"@
Set-Content -LiteralPath (Join-Path $OutputDir "$($ModuleName).psd1") -Value $manifest -Encoding UTF8

$psm1 = @'
# MaestroKit distribution module. Thin wrappers over the canonical scripts
# shipped in this directory — the git repo remains the single source of truth.

$script:BundleRoot = $PSScriptRoot

<#
.SYNOPSIS
Installs the Maestro bundle (skills, references, agents) into a target repo
(-Scope Project, the default) or into your profile (-Scope User).
.NOTES
Audience: everyone - primary deployment entry point.
.EXAMPLE
Install-Maestro -Target D:\repos\my-app -Locations .omp,.claude -Force
.EXAMPLE
Install-Maestro -Scope User -Locations .omp,.claude -Force
#>
function Install-Maestro {
    [CmdletBinding()]
    param(
        [string]$Target = (Get-Location).Path,
        [ValidateSet('Project', 'User')][string]$Scope = 'Project',
        [string[]]$Locations = @(".agents"),
        [switch]$Clean,
        [switch]$Force
    )
    $invokeArgs = @{ Scope = $Scope; Locations = $Locations; Clean = $Clean; Force = $Force }
    if ($PSBoundParameters.ContainsKey('Target')) { $invokeArgs.Target = $Target }
    & (Join-Path $script:BundleRoot "Install-Maestro.ps1") @invokeArgs
}

<#
.SYNOPSIS
Runs the source-bundle consistency validator against a checkout of the Maestro repo.
.NOTES
Audience: maintainers + end users running post-install self-checks.
#>
function Test-MaestroKit {
    [CmdletBinding()]
    param(
        [string]$Root,
        [string]$ToolsDir = (Join-Path $script:BundleRoot "tools")
    )
    $validator = Join-Path $ToolsDir "validate-bundle.ps1"
    $invokeArgs = @{}
    if ($Root) { $invokeArgs.Root = $Root }
    & $validator @invokeArgs
}

<#
.SYNOPSIS
End-to-end install gate: installs to a temp dir and asserts structure, substitution, version stamp.
.NOTES
Audience: maintainers + end users verifying their installed copy.
#>
function Invoke-MaestroSmokeInstall {
    [CmdletBinding()]
    param(
        [string]$Root,
        [switch]$Keep
    )
    $smoke = Join-Path $script:BundleRoot "tools/smoke-install.ps1"
    $invokeArgs = @{}
    if ($Root) { $invokeArgs.Root = $Root }
    if ($Keep) { $invokeArgs.Keep = $true }
    & $smoke @invokeArgs
}

Export-ModuleMember -Function Install-Maestro, Test-MaestroKit, Invoke-MaestroSmokeInstall
'@
Set-Content -LiteralPath (Join-Path $OutputDir "$($ModuleName).psm1") -Value $psm1 -Encoding UTF8

Write-Host ("module built: " + $OutputDir + " (v" + $Version + ")")
