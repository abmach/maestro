# Requires PowerShell 5.1+ compatible syntax (no PS7-only constructs).
# Dev-time validator for the Maestro bundle. Run from the repo root or pass -Root.
param(
    [string]$Root
)

$ErrorActionPreference = "Stop"

if (-not $Root) {
    $Root = Split-Path -Parent $PSScriptRoot
}

$script:failures = 0

function Fail([string]$msg) {
    $script:failures++
    Write-Host ("  FAIL " + $msg) -ForegroundColor Red
}

function Pass([string]$msg) {
    Write-Host ("  ok   " + $msg) -ForegroundColor DarkGray
}

$KnownTokens = @("WORKSPACE", "MAESTRO_CONFIG")
$PreflightNeedles = @("git rev-parse --show-toplevel", "references/conventions.md")

Write-Host "== Maestro bundle validation =="
Write-Host ("root: " + $Root)
Write-Host ""

function Get-MdFiles([string]$dir) {
    if (Test-Path -LiteralPath $dir) {
        return @(Get-ChildItem -LiteralPath $dir -Filter "*.md" -Recurse -File |
            Where-Object { $_.FullName -notmatch "[\\/]backup[\\/]" })
    }
    return @()
}

function Remove-FencedBlocks([string]$text) {
    # Toggle out fenced code blocks so template/example links are not link-checked.
    $lines = $text -split "`r?`n"
    $out = New-Object System.Collections.Generic.List[string]
    $inFence = $false
    foreach ($line in $lines) {
        if ($line -match "^````") { $inFence = -not $inFence; continue }
        if (-not $inFence) { [void]$out.Add($line) }
    }
    return ($out -join "`n")
}

# --- 1. Frontmatter integrity -------------------------------------------------
$skillCount = 0
foreach ($f in @(Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Filter "SKILL.md" -Recurse -File)) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    $name = [regex]::Match($t, "(?m)^name:\s*(\S+)").Groups[1].Value
    $desc = [regex]::Match($t, "(?m)^description:\s*(.+)$").Groups[1].Value
    if (-not $name -or -not $desc) {
        Fail ("skills/" + $f.Directory.Name + "/SKILL.md: missing name/description frontmatter")
    } else { $skillCount++ }
}
Pass ("skills: $skillCount SKILL.md files with name+description")

$agentOk = $true
foreach ($f in @(Get-ChildItem -LiteralPath (Join-Path $Root "agents") -Filter "*.md" -File)) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    $name = [regex]::Match($t, "(?m)^name:\s*(\S+)").Groups[1].Value
    $desc = [regex]::Match($t, "(?m)^description:\s*(.+)$").Groups[1].Value
    $mode = [regex]::Match($t, "(?m)^mode:\s*(\S+)").Groups[1].Value
    if (-not $name -or -not $desc -or $mode -ne "subagent") {
        Fail ("agents/" + $f.Name + ": missing name/description or mode: subagent")
        $agentOk = $false
    }
}
if ($agentOk) { Pass "agents: all declare name+description+mode: subagent" }

# --- 2. Placeholder tokens -----------------------------------------------------
$tokenBad = $false
foreach ($f in @(Get-MdFiles (Join-Path $Root "references")) ) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    foreach ($m in [regex]::Matches($t, "\{\{([A-Za-z_]+)\}\}")) {
        if ($KnownTokens -notcontains $m.Groups[1].Value) {
            Fail ($f.Name + ": unknown placeholder {{" + $m.Groups[1].Value + "}}")
            $tokenBad = $true
        }
    }
}
if (-not $tokenBad) { Pass "placeholders: only {{WORKSPACE}} and {{MAESTRO_CONFIG}} appear" }

# --- 3. Broken-link typo class: (...md} instead of (...md) --------------------
$typoBad = $false
foreach ($f in @(Get-MdFiles $Root)) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    if ([regex]::IsMatch($t, "\]\([^()]*\.[A-Za-z0-9]+\}")) {
        Fail ($f.FullName.Substring($Root.Length) + ": markdown link ends with '}' instead of ')'")
        $typoBad = $true
    }
}
if (-not $typoBad) { Pass "links: no '.md}' typo-class breakage" }

# --- 4. Link targets resolve (outside fences) ---------------------------------
$linkBad = 0
foreach ($f in @(Get-MdFiles $Root)) {
    $t = Remove-FencedBlocks ([System.IO.File]::ReadAllText($f.FullName))
    foreach ($m in [regex]::Matches($t, "\[[^\]]*\]\(([^)]+)\)")) {
        $target = $m.Groups[1].Value.Trim()
        if ($target -match "^(https?:|mailto:|#)" ) { continue }
        if ($target -match "[\{\}]") { continue }  # placeholder paths resolved at runtime/install
        if ($target -cmatch "[A-Z]{3,}") { continue }  # template placeholders like NNNN-slug.md
        $target = ($target -split "#")[0]
        if (-not $target) { continue }
        $resolved = Join-Path $f.DirectoryName $target
        if (-not (Test-Path -LiteralPath $resolved)) {
            Fail ($f.Name + ": broken link target '" + $target + "'")
            $linkBad++
        }
    }
}
if ($linkBad -eq 0) { Pass "links: all non-fenced relative targets resolve" }

# --- 5. Canonical Pre-flight in every skill and agent -------------------------
$promiseBad = $false
foreach ($f in @((Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Filter "SKILL.md" -Recurse -File) +
                 (Get-ChildItem -LiteralPath (Join-Path $Root "agents") -Filter "*.md" -File))) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    foreach ($needle in $PreflightNeedles) {
        if (-not $t.Contains($needle)) {
            Fail ($f.Directory.Parent.Name + "/" + $f.Directory.Name + "/" + $f.Name + ": preflight missing '" + $needle + "'")
            $promiseBad = $true
        }
    }
}
if (-not $promiseBad) { Pass "preflight: every skill/agent resolves workspace + reads conventions.md" }

# --- 6. Retry rule consistency ------------------------------------------------
$retryTargets = @(
    (Join-Path $Root "references/conventions.md"),
    (Join-Path $Root "references/plan.md"),
    (Join-Path $Root "skills/orchestrate/SKILL.md")
)
$retryBad = $false
foreach ($p in $retryTargets) {
    $t = ([System.IO.File]::ReadAllText($p)) -replace "\*", ""
    if (-not $t.Contains("Retries") -or -not ($t -match "immediately\s+(BEFORE|before)")) {
        Fail ((Split-Path -Leaf $p) + ": retry rule wording missing (expected spawn-counting 'immediately BEFORE' language)")
        $retryBad = $true
    }
}
if (-not $retryBad) { Pass "retries: spawn-counting rule present in conventions/plan/orchestrate" }

# --- 7. References map completeness -------------------------------------------
$mapBad = $false
$mapText = [System.IO.File]::ReadAllText((Join-Path $Root "references/references-map.md"))
$listed = @()
foreach ($m in [regex]::Matches($mapText, '(?m)^\| `[A-Za-z ]+` \| `([a-z0-9-]+\.md)` \|')) { $listed += $m.Groups[1].Value }
foreach ($a in @(Get-ChildItem -LiteralPath (Join-Path $Root "references") -Filter "*.md" -File)) {
    if ($listed -notcontains $a.Name) {
        Fail ("references-map.md: missing row for " + $a.Name)
        $mapBad = $true
    }
}
if (-not $mapBad) { Pass "references-map: every reference file listed" }

# --- 8. README counts match reality --------------------------------------------
$readme = [System.IO.File]::ReadAllText((Join-Path $Root "README.md"))
$sCount = @(Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Directory).Count
$aCount = @(Get-ChildItem -LiteralPath (Join-Path $Root "agents") -Filter "*.md" -File).Count
$rCount = @(Get-ChildItem -LiteralPath (Join-Path $Root "references") -Filter "*.md" -File).Count
$expected = "\*\*$sCount skills\*\* \+ \*\*$aCount agents\*\* \+ \*\*$rCount reference specs\*\*"
if ($readme -notmatch $expected) {
    Fail ("README counts line does not match disk (actual: $sCount skills / $aCount agents / $rCount references)")
} else {
    Pass "counts: README matches disk ($sCount/$aCount/$rCount)"
}

# --- 9. Vocabulary drift --------------------------------------------------------
$driftBad = $false
foreach ($f in @(Get-MdFiles $Root)) {
    $t = [System.IO.File]::ReadAllText($f.FullName)
    foreach ($m in [regex]::Matches($t, "(?i)(play|tune)[` ]{0,3}(skill|command)s?")) {
        Fail ($f.FullName.Substring($Root.Length) + ": '" + $m.Value.Trim() + "' — play/tune are subagents, not skills")
        $driftBad = $true
    }
}
if (-not $driftBad) { Pass "vocabulary: no play/tune-as-skill drift" }

# --- Summary -------------------------------------------------------------------
Write-Host ""
if ($script:failures -gt 0) {
    Write-Host ("VALIDATION FAILED: " + $script:failures + " problem(s)") -ForegroundColor Red
    exit 1
}
Write-Host "ALL CHECKS PASSED" -ForegroundColor Green
exit 0
