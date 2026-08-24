# End-to-end installer smoke test. Complements tools/validate-bundle.ps1:
# validate checks the source bundle; this proves the INSTALLED result.
# PowerShell 5.1-compatible.
param(
    [string]$Root,
    [switch]$Keep
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }

$script:failures = 0
function Fail([string]$msg) { $script:failures++; Write-Host ("  FAIL " + $msg) -ForegroundColor Red }
function Pass([string]$msg) { Write-Host ("  ok   " + $msg) -ForegroundColor DarkGray }

Write-Host "== Maestro install smoke test =="
Write-Host ("root: " + $Root)

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("maestro-smoke-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

try {
    # --- install to two locations via the CLI form (comma string binding) ---
    $pwshExe = "powershell"
    if (Get-Command pwsh -ErrorAction SilentlyContinue) { $pwshExe = "pwsh" }
    & $pwshExe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "Install-Maestro.ps1") `
        -Target $tmp -Locations ".omp,.claude" -Force *> (Join-Path $tmp "install-log.txt")
    if ($LASTEXITCODE -ne 0) {
        Fail ("installer exited nonzero (see " + (Join-Path $tmp "install-log.txt") + ")")
    } else { Pass "installer ran clean for .omp,.claude via comma-string Locations" }

    # --- skill count matches source ---
    $srcSkills = @(Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Directory).Count
    $dstSkills = @(Get-ChildItem -LiteralPath (Join-Path $tmp ".omp/skills") -Directory).Count
    if ($dstSkills -ne $srcSkills) { Fail ("installed skills: $dstSkills, expected $srcSkills") } else { Pass "skills: $dstSkills installed" }

    # --- placeholder substitution ---
    $compose = Join-Path $tmp ".omp/skills/compose/SKILL.md"
    if (-not (Test-Path $compose)) { Fail "missing .omp/skills/compose/SKILL.md" }
    else {
        $t = [System.IO.File]::ReadAllText($compose)
        if ($t -notlike "*.omp/references/conventions.md*") { Fail "compose: {{MAESTRO_CONFIG}} not substituted to .omp path" } else { Pass "substitution: config path baked in" }
    }

    # --- no unresolved placeholders anywhere ---
    $stray = @(Get-ChildItem -LiteralPath $tmp -Filter "*.md" -Recurse -File | Where-Object {
        $_.Name -ne "MAESTRO_CHANGELOG.md" -and
        ([System.IO.File]::ReadAllText($_.FullName)) -match "\{\{MAESTRO_CONFIG\}\}"
    })
    if ($stray.Count -gt 0) { Fail ("unresolved {{MAESTRO_CONFIG}} in: " + (($stray | ForEach-Object { $_.Name }) -join ", ")) } else { Pass "placeholders: zero unresolved" }

    # --- agents land ---
    foreach ($a in @("play.md", "tune.md")) {
        if (-not (Test-Path (Join-Path $tmp ".claude/agents/$a"))) { Fail "missing .claude/agents/$a" }
    }

    # --- version stamp ---
    $want = ([System.IO.File]::ReadAllText((Join-Path $Root "VERSION"))).Trim()
    $got = ([System.IO.File]::ReadAllText((Join-Path $tmp ".omp/MAESTRO_VERSION"))).Trim()
    if ($got -ne $want) { Fail "MAESTRO_VERSION '$got' != VERSION '$want'" } else { Pass "version stamp: $got" }

    # --- changelog shipped ---
    if (-not (Test-Path (Join-Path $tmp ".omp/MAESTRO_CHANGELOG.md"))) { Fail "missing MAESTRO_CHANGELOG.md" } else { Pass "changelog: MAESTRO_CHANGELOG.md shipped" }

    # --- user-scope pass (isolated fake profile via explicit Target override) ---
    $fakeHome = Join-Path $tmp "fakehome"
    New-Item -ItemType Directory -Path $fakeHome | Out-Null
    & $pwshExe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "Install-Maestro.ps1") -Target $fakeHome -Locations ".omp,.claude" -Force -Scope User *> (Join-Path $tmp "user-scope-log.txt")
    if ($LASTEXITCODE -ne 0) {
        Fail ("user-scope install exited nonzero (see user-scope-log.txt)")
    }
    else {
        $uCount = @(Get-ChildItem -LiteralPath (Join-Path $fakeHome ".omp/skills") -Directory).Count
        $uVersion = ([System.IO.File]::ReadAllText((Join-Path $fakeHome ".omp/MAESTRO_VERSION"))).Trim()
        if ($uCount -ne $srcSkills) { Fail ("user-scope skills: $uCount, expected $srcSkills") }
        elseif ($uVersion -ne $want) { Fail ("user-scope MAESTRO_VERSION '$uVersion' != '$want'") }
        else { Pass "user-scope: skills installed under isolated fake profile" }
    $composeAbs = ([System.IO.File]::ReadAllText((Join-Path $fakeHome ".omp/skills/compose/SKILL.md"))).Contains((($fakeHome -replace '\\','/')) + "/.omp/references/conventions.md")
    if ($composeAbs) { Pass "user-scope: spec paths baked absolute" } else { Fail "user-scope: absolute spec path missing in installed skills" }
    }
}
finally {
    if ($Keep) { Write-Host ("temp kept: " + $tmp) -ForegroundColor Yellow }
    else { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ""
if ($script:failures -gt 0) {
    Write-Host ("INSTALL SMOKE FAILED: " + $script:failures + " problem(s)") -ForegroundColor Red
    exit 1
}
Write-Host "INSTALL SMOKE PASSED" -ForegroundColor Green
exit 0
