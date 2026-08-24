#!/usr/bin/env pwsh
<#
.SYNOPSIS
Install MaestroKit (skills, references, agents) into one or more config dirs of a target repo.

.DESCRIPTION
Copies `skills/`, `references/`, and `agents/` from the Maestro source repo into
<Target>/<Location>/ for each location in -Locations. During the copy, every
`{{MAESTRO_CONFIG}}` token in `.md` files is replaced with the location string,
so skills and agents can reference reference files via a relative path that
resolves correctly at runtime.

Supported locations:
  .agents    — OpenCode-compatible (default). Full coverage on OpenCode (skills
               and agents). On Oh My Pi, skills are discovered natively (canonical
               OMP location) but the agents/ folder is ignored — prefer .omp for OMP.
  .omp       — Oh My Pi native. Full coverage: .omp/skills/ (native provider) and
               .omp/agents/ (OMP's only project-level subagent root).
  .claude    — Claude Code-compatible. Full coverage on Claude Code; skills also
               discovered by OpenCode and Oh My Pi (Claude-compatible path).
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
Accepts: .agents, .omp, .claude, .opencode. Pass multiple to install to all, e.g.:
    -Locations .agents,.claude,.opencode,.omp

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
    [ValidateSet('Project', 'User')][string]$Scope = 'Project',
    [switch]$Clean,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Non-interactive hosts cannot answer the overwrite prompt — fail closed with guidance.
if (-not $Force -and -not [Environment]::UserInteractive) {
    throw "Non-interactive session detected and an existing installation may need overwriting. Re-run with -Force to overwrite in place."
}

$ValidLocations = @(".agents", ".omp", ".claude", ".opencode")

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

    # Placeholder resolution (see conventions.md): skill texts write
    #   [{{WORKSPACE}}/]{{MAESTRO_CONFIG}}/references/...
    # Project scope keeps {{WORKSPACE}} runtime-resolved and bakes the harness
    # folder; User scope bakes an absolute profile root instead.
    $script:MaestroConfigPath = if ($Scope -eq 'User') {
        (($EffectiveTarget -replace '\\', '/') + "/" + $Location)
    } else {
        ("{{WORKSPACE}}/" + $Location)
    }

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
                    $content = $content -replace '(\{\{WORKSPACE\}\}/)?\{\{MAESTRO_CONFIG\}\}', $script:MaestroConfigPath
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
        $SrcChangelog = Join-Path $SourceRoot "CHANGELOG.md"
        if (Test-Path -LiteralPath $SrcChangelog) {
            Copy-Item -LiteralPath $SrcChangelog -Destination (Join-Path $DestDir "MAESTRO_CHANGELOG.md") -Force
            Write-Ok "Shipped MAESTRO_CHANGELOG.md (migration notes for this version)"
        }
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

# Accept both `-.Locations a,b` (interactive: PS binds an array) and
# `pwsh -File ... -Locations a,b` (-File mode: binds ONE string) by splitting commas here.
$Normalized = foreach ($loc in $Locations) {
    foreach ($part in $loc.Split(',')) {
        $trimmed = $part.Trim()
        if (-not $trimmed) { continue }
        $first = $trimmed.Substring(0, 1)
        if ($first -ne '.') { $trimmed = ".$trimmed" }
        if ($ValidLocations -notcontains $trimmed) {
            throw "Invalid location '$trimmed'. Valid: $($ValidLocations -join ', ')"
        }
        $trimmed
    }
}

if (-not $Normalized) { $Normalized = @(".agents") }

# Resolve effective install root. Project scope installs into the given repo;
# User scope installs into your profile so the bundle is usable everywhere.
# An explicit -Target together with -Scope User overrides the profile root
# (documented testing hook).
$EffectiveTarget = $Target
if ($Scope -eq 'User') {
    if ($PSBoundParameters.ContainsKey('Target')) { $EffectiveTarget = $Target }
    else { $EffectiveTarget = [Environment]::GetFolderPath('UserProfile') }
    Write-Host ("  scope    : user (" + $EffectiveTarget + ")")
}


Write-Host "Installing Maestro" -ForegroundColor White
Write-Host "  from     : $SourceRoot" -ForegroundColor DarkGray
Write-Host "  target   : $EffectiveTarget" -ForegroundColor DarkGray
Write-Host "  locations: $($Normalized -join ', ')" -ForegroundColor DarkGray
if ($Clean) { Write-Host "  mode     : clean" -ForegroundColor DarkGray }
elseif ($Force) { Write-Host "  mode     : force-overwrite" -ForegroundColor DarkGray }

foreach ($loc in $Normalized) {
    Install-SingleLocation -SourceRoot $SourceRoot -TargetRoot $EffectiveTarget -Location $loc -CleanFlag ([bool]$Clean) -ForceFlag ([bool]$Force)
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
