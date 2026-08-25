# Adds a supporter to SUPPORTERS.md (single source of truth).
# Nothing here touches plans/issues/code - one markdown file, one section.
#
# Usage:
#   ./tools/add-supporter.ps1 -Name 'Acme Corp' -Tier Encore `
#       -Link 'https://acme.example' -LogoUrl 'https://acme.example/logo.png'
#   ./tools/add-supporter.ps1 -Name 'Jane Dev' -Tier Applause
#   ./tools/add-supporter.ps1 ... -DryRun     # preview, write nothing
param(
    [Parameter(Mandatory)] [string]$Name,
    [Parameter(Mandatory)][ValidateSet('Applause', 'Encore', 'Conductor')]
    [string]$Tier,
    [string]$Link,
    [string]$LogoUrl,
    [string]$Root,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$file = Join-Path $Root 'SUPPORTERS.md'
if (-not (Test-Path -LiteralPath $file)) { throw "SUPPORTERS.md not found at $file" }

$since = Get-Date -Format 'yyyy-MM'
$display = if ($LogoUrl) { '<img src="' + $LogoUrl + '" alt="' + $Name + '" width="140">' } else { $Name }
$entryLine = if ($Link) { '- [' + $display + '](' + $Link + ') - since ' + $since } else { '- ' + $display + ' - since ' + $since }

$sectionHeader = switch ($Tier) {
    'Conductor' { '## 💎 Conductor''s Circle' }
    'Encore'    { '## 🎭 Encore' }
    'Applause'  { '## 👏 Applause' }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.AddRange([System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8))
$start = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq $sectionHeader) { $start = $i; break }
}
if ($null -eq $start) { throw "section '$sectionHeader' not found in SUPPORTERS.md" }

# Find where the section ends (next '## ' heading or EOF)
$end = $lines.Count
for ($i = $start + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like '## *') { $end = $i; break }
}

# Insert newest-first: right after the section header + blank separator.
$insertAt = $start + 2
if ($insertAt -gt $end) { $insertAt = $end }

# If the empty-state placeholder lives in this section, drop it when adding the first real entry.
for ($i = $start + 1; $i -lt $end; $i++) {
    if ($lines[$i] -match '^_.+_?$') {
        $lines.RemoveAt($i)   # removes e.g. "_No entries yet._"
        if ($insertAt -gt $i) { $insertAt-- }
        break
    }
}

$final = New-Object System.Collections.Generic.List[string]
$final.AddRange($lines)
$final.Insert($insertAt, $entryLine)

if ($DryRun) {
    Write-Host 'DRY RUN - would insert:' -ForegroundColor Yellow
    Write-Host $entryLine
} else {
    [System.IO.File]::WriteAllLines($file, $final, (New-Object System.Text.UTF8Encoding $false))
    Write-Host ("added to " + $Tier + ": " + $Name) -ForegroundColor Green
    Write-Host 'next: git add SUPPORTERS.md && git commit && git push (mirror carries it)'
}
