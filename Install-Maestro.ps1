#!/usr/bin/env pwsh
<#
.SYNOPSIS
Install the Maestro bundle (skills, references, agents) into one or more config dirs of a target repo.

.DESCRIPTION
Copies `skills/`, `references/`, and `agents/` from the Maestro source repo into
<Target>/<Location>/ for each location in -Locations. During the copy, every
`{{MAESTRO_CONFIG}}` token in `.md` files is replaced with the location string,
so skills and agents can reference reference files via a relative path that
resolves correctly at runtime.

Supported locations:
  .agents    — OpenCode-compatible (default). Works on OpenCode for both skills
               and agents. Not discovered by Claude Code.
  .claude    — Claude Code-compatible. Works on Claude Code for skills and
               agents. Also discovered by OpenCode (Claude-compatible path).
  .opencode  — OpenCode native. Same coverage as .agents but checked first by
               OpenCode when present.

Pick one location per platform you support, or pass multiple to install in
parallel. Re-running overwrites in place, which is the recommended upgrade path.
Use -Clean to first wipe stale skill/reference/agent folders (e.g., after a
skill has been renamed or removed upstream).

.PARAMETER Target
Path to the destination repo root. Defaults to the current working directory.

.PARAMETER Locations
One or more config directories to install into. Defaults to @(".agents").
Accepts: .agents, .claude, .opencode. Pass multiple to install to all, e.g.:
    -Locations .agents,.claude,.opencode

.PARAMETER Clean
Delete <Target>/<Location>/skills, references, and agents folders before
copying. Preserves any other content (opencode.json, user-installed skills, etc.).

.PARAMETER Force
Skip the confirmation prompt when an existing installation is found and -Clean
is not used. Implies overwrite-in-place via Copy-Item -Force.

.EXAMPLE
.\Install-Maestro.ps1 -Target D:\Personal\my-app

.EXAMPLE
.\Install-Maestro.ps1 -Target . -Locations .claude,.agents -Clean -Force
#>

[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [string[]]$Locations = @(".agents"),
    [switch]$Clean,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ValidLocations = @(".agents", ".claude", ".opencode")

function Write-Step($msg) { Write-Host "-> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "   $msg" -ForegroundColor Yellow }

function Install-SingleLocation {
    param(
        [string]$SourceRoot,
        [string]$TargetRoot,
        [string]$Location,
        [bool]$CleanFlag,
        [bool]$ForceFlag
    )

    $SourceSkills = Join-Path $SourceRoot "skills"
    $SourceRefs   = Join-Path $SourceRoot "references"
    $SourceAgents = Join-Path $SourceRoot "agents"
    $VersionFile  = Join-Path $SourceRoot "VERSION"

    $DestDir         = Join-Path $TargetRoot $Location
    $DestSkills      = Join-Path $DestDir "skills"
    $DestRefs        = Join-Path $DestDir "references"
    $DestAgents      = Join-Path $DestDir "agents"
    $DestVersionFile = Join-Path $DestDir "MAESTRO_VERSION"

    $HasRefs   = Test-Path -LiteralPath $SourceRefs -PathType Container
    $HasAgents = Test-Path -LiteralPath $SourceAgents -PathType Container
    $Version   = $null
    if (Test-Path -LiteralPath $VersionFile) {
        $Version = (Get-Content -LiteralPath $VersionFile -TotalCount 1).Trim()
    }

    Write-Host ""
    Write-Host "Installing Maestro -> $DestDir" -ForegroundColor White
    if ($Version) { Write-Host "  version: $Version" -ForegroundColor DarkGray }

    if (-not (Test-Path -LiteralPath $DestDir)) {
        Write-Step "Creating $DestDir"
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    if ($CleanFlag) {
        foreach ($sub in @($DestSkills, $DestRefs, $DestAgents)) {
            if (Test-Path -LiteralPath $sub) {
                Write-Step "Cleaning $sub"
                Remove-Item -LiteralPath $sub -Recurse -Force
            }
        }
    }
    elseif ((Test-Path -LiteralPath $DestSkills) -or ($HasRefs -and (Test-Path -LiteralPath $DestRefs)) -or ($HasAgents -and (Test-Path -LiteralPath $DestAgents))) {
        $existingVersion = $null
        if (Test-Path -LiteralPath $DestVersionFile) {
            $existingVersion = (Get-Content -LiteralPath $DestVersionFile -TotalCount 1).Trim()
        }
        $upgradeNote = if ($existingVersion -and $Version -and $existingVersion -ne $Version) {
            "  Existing install is v$existingVersion; upgrading to v$Version."
        } elseif ($existingVersion -and $Version -and $existingVersion -eq $Version) {
            "  Existing install is the same version (v$Version); will overwrite in place."
        } else { "" }

        if (-not $ForceFlag) {
            $prompt = @"
Existing Maestro installation found at:
  $DestDir
$upgradeNote
Re-running will overwrite skill/reference/agent files in place. Any skills or
agents you renamed or removed upstream will linger under $Location/. To wipe
those first, abort and rerun with -Clean. Continue?
"@
            $decision = $PSCmdlet.Host.UI.PromptForChoice(
                "Overwrite existing Maestro installation at $Location?",
                $prompt,
                @("&Yes", "&No"), 0)
            if ($decision -ne 0) {
                Write-Warn "Skipping $Location. No changes made."
                return
            }
        } else {
            if ($upgradeNote) { Write-Host $upgradeNote -ForegroundColor DarkGray }
        }
    }

    function Copy-WithSubstitution {
        param([string]$Src, [string]$Dst)
        New-Item -ItemType Directory -Path $Dst -Force | Out-Null
        $items = Get-ChildItem -LiteralPath $Src
        foreach ($item in $items) {
            $destItem = Join-Path $Dst $item.Name
            if ($item.PSIsContainer) {
                Copy-WithSubstitution -Src $item.FullName -Dst $destItem
            } else {
                if ($item.Extension -eq ".md") {
                    $content = [System.IO.File]::ReadAllText($item.FullName, [System.Text.Encoding]::UTF8)
                    $content = $content -replace '\{\{MAESTRO_CONFIG\}\}', $Location
                    [System.IO.File]::WriteAllText($destItem, $content, (New-Object System.Text.UTF8Encoding $false))
                } else {
                    Copy-Item -LiteralPath $item.FullName -Destination $destItem -Force
                }
            }
        }
    }

    Write-Step "Copying skills/  -> $Location/skills/"
    Copy-WithSubstitution -Src $SourceSkills -Dst $DestSkills
    $skillCount = (Get-ChildItem -LiteralPath $DestSkills -Directory).Count
    Write-Ok "$skillCount skill(s) installed"

    if ($HasRefs) {
        Write-Step "Copying references/ -> $Location/references/"
        Copy-WithSubstitution -Src $SourceRefs -Dst $DestRefs
        $refCount = (Get-ChildItem -LiteralPath $DestRefs -File).Count
        Write-Ok "$refCount reference file(s) installed"
    } else {
        Write-Warn "No references/ folder found in source; skipped"
    }

    if ($HasAgents) {
        Write-Step "Copying agents/  -> $Location/agents/"
        Copy-WithSubstitution -Src $SourceAgents -Dst $DestAgents
        $agentCount = (Get-ChildItem -LiteralPath $DestAgents -File).Count
        Write-Ok "$agentCount agent(s) installed"
    } else {
        Write-Warn "No agents/ folder found in source; skipped"
    }

    if ($Version) {
        Write-Step "Writing $Location/MAESTRO_VERSION"
        Set-Content -LiteralPath $DestVersionFile -Value $Version -NoNewline
        Write-Ok "Recorded version: $Version"
    } else {
        Write-Warn "No VERSION file in source; MAESTRO_VERSION not written"
    }

    Write-Ok "Maestro installed to: $DestDir"
}

# --- main ---

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    throw "Target directory does not exist: $Target"
}

$SourceRoot   = $PSScriptRoot
$SrcSkills    = Join-Path $SourceRoot "skills"
if (-not (Test-Path -LiteralPath $SrcSkills -PathType Container)) {
    throw "Source skills/ not found at: $SrcSkills (run this script from the maestro repo root)"
}

$Normalized = foreach ($loc in $Locations) {
    $trimmed = $loc.Trim()
    $first = $trimmed.Substring(0,1)
    if ($first -ne '.') { $trimmed = ".$trimmed" }
    if ($ValidLocations -notcontains $trimmed) {
        throw "Invalid location '$loc'. Valid: $($ValidLocations -join ', ')"
    }
    $trimmed
}

if (-not $Normalized) { $Normalized = @(".agents") }

Write-Host "Installing Maestro" -ForegroundColor White
Write-Host "  from     : $SourceRoot" -ForegroundColor DarkGray
Write-Host "  target   : $Target" -ForegroundColor DarkGray
Write-Host "  locations: $($Normalized -join ', ')" -ForegroundColor DarkGray
if ($Clean) { Write-Host "  mode     : clean" -ForegroundColor DarkGray }
elseif ($Force) { Write-Host "  mode     : force-overwrite" -ForegroundColor DarkGray }

foreach ($loc in $Normalized) {
    Install-SingleLocation -SourceRoot $SourceRoot -TargetRoot $Target -Location $loc -CleanFlag ([bool]$Clean) -ForceFlag ([bool]$Force)
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green

$claudes = $Normalized | Where-Object { $_ -eq ".claude" }
if (-not $claudes) {
    Write-Host ""
    Write-Warn "Note: not installed to .claude — Claude Code will not discover these skills or agents."
    Write-Warn "      Re-run with -Locations .claude,.agents to enable Claude Code as well."
}
