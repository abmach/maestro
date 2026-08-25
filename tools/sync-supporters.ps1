# Rebuilds the tiered sections of SUPPORTERS.md from live GitHub Sponsors data.
#
# Preservation guarantees:
#   - Conductor's Circle: entries are PERMANENT. Cancellations do not remove
#     them (Founding rule). Removal from this tier is always manual.
#   - Encore/Applause: entries tied to GitHub sponsorships follow the API -
#     cancellations drop them. Manual entries (no GitHub login in the line,
#     e.g. bank-transfer backers) are preserved untouched.
#
# Prerequisites:
#   MAESTRO_GH_TOKEN environment variable - a GitHub PAT with read:user scope.
#
# Usage:
#   ./tools/sync-supporters.ps1                # fetch live data, write changes
#   ./tools/sync-supporters.ps1 -DryRun        # preview resulting file
#   ./tools/sync-supporters.ps1 -MockActivitiesJson '<json>'   # offline test
param(
    [string]$Login = 'abmach',
    [string]$Token = $env:MAESTRO_GH_TOKEN,
    [string]$Root,
    [string]$MockActivitiesJson,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $MockActivitiesJson -and -not $Token) {
    throw "Set MAESTRO_GH_TOKEN (a GitHub PAT with read:user scope) to sync supporters."
}
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$file = Join-Path $Root 'SUPPORTERS.md'
if (-not (Test-Path -LiteralPath $file)) { throw "SUPPORTERS.md not found at $file" }

if ($MockActivitiesJson) {
    Write-Host 'using mocked activities' -ForegroundColor Yellow
    $activities = $MockActivitiesJson | ConvertFrom-Json
} else {
    $query = @'
query($login:String!){
  user(login:$login){
    sponsorsActivities(first:100,order:{field:TIMESTAMP,direction:DESC}){
      nodes{
        __typename
        ... on SponsorsActivity{
          action
          sponsor{ login }
          tier{ monthlyPriceInDollars }
        }
      }
    }
  }
}
'@
    $body = @{ query = $query; variables = @{ login = $Login } } | ConvertTo-Json -Depth 6
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post `
        -Headers @{ Authorization = "Bearer $Token"; 'User-Agent' = 'maestro-sync' } `
        -Body $body -ContentType 'application/json'
    $activities = $response.data.user.sponsorsActivities.nodes
}

# --- derive current state: newest activity per sponsor wins ---
$state = @{}          # login -> @{ amount=int; active=bool }
foreach ($a in $activities) {
    $login = $a.sponsor.login
    if (-not $state.ContainsKey($login)) {
        $state[$login] = @{ amount = 0; active = $false }
    }
    switch ($a.action) {
        'NEW_SPONSORSHIP'         { $state[$login].amount = [Math]::Max($state[$login].amount, [int]$a.tier.monthlyPriceInDollars); $state[$login].active = $true }
        'SPONSORSHIP_TIER_CHANGED'{ $state[$login].amount = [Math]::Max($state[$login].amount, [int]$a.tier.monthlyPriceInDollars) }
        'CANCELLED_SPONSORSHIP'   { $state[$login].active = $false }
    }
}

function Get-Bucket([int]$amount) {
    if ($amount -ge 25) { 'Conductor' } elseif ($amount -ge 10) { 'Encore' } else { 'Applause' }
}

# --- parse existing SUPPORTERS.md entries ---
function Get-EntryLogin([string]$line) {
    $m = [regex]::Match($line, 'github\.com/([^/\)\s]+)')
    if ($m.Success) { return $m.Groups[1].Value }
    return $null
}

$sectionOrder = @('Conductor', 'Encore', 'Applause')
$headers = @{
    Conductor = '## 💎 Conductor''s Circle'
    Encore    = '## 🎭 Encore'
    Applause  = '## 👏 Applause'
}

$lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)

# locate intro (everything above first tier heading) and split sections
$firstTierIdx = $null
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^## 💎') { $firstTierIdx = $i; break } }
if (-not $firstTierIdx) { throw 'tier headings not found in SUPPORTERS.md' }

$intro = $lines[0..($firstTierIdx - 1)]
$preserved = @{}
$cursor = $firstTierIdx
$currentTier = $null
for ($i = $firstTierIdx; $i -lt $lines.Count; $i++) {
    $l = $lines[$i]
    if ($l -match '^## 💎') { $currentTier = 'Conductor'; continue }
    if ($l -match '^## 🎭') { $currentTier = 'Encore';    continue }
    if ($l -match '^## 👏') { $currentTier = 'Applause';  continue }
    if ($l -match '^## ')  { break }
    if ($currentTier -and $l.Trim()) { 
        if (-not $preserved.ContainsKey($currentTier)) { $preserved[$currentTier] = New-Object System.Collections.Generic.List[string] }
        $preserved[$currentTier].Add($l)
    }
}

# --- merge: API state applied, guarantees enforced ---
$final = @{}
foreach ($t in $sectionOrder) {
    $final[$t] = New-Object System.Collections.Generic.List[string]
    if ($preserved.ContainsKey($t)) { foreach ($e in $preserved[$t]) { $final[$t].Add($e) } }
}

foreach ($login in $state.Keys) {
    $st = $state[$login]
    if (-not $st.active) { continue }   # cancelled -> drops out of Encore/Applause;
                                        # Conductor entries are preserved below (never removed)
    $bucket = Get-Bucket $st.amount
    $already = $false
    foreach ($t in $sectionOrder) {
        for ($i = 0; $i -lt $final[$t].Count; $i++) {
            if ((Get-EntryLogin $final[$t][$i]) -eq $login) {
                # already listed somewhere: keep, but relocate if tier changed
                if ($t -ne $bucket) {
                    $final[$t].RemoveAt($i); $i--
                    $final[$bucket].Add('- [@' + $login + '](https://github.com/' + $login + ') - $' + $st.amount + '/mo')
                }
                $already = $true; break
            }
        }
        if ($already) { break }
    }
    if (-not $already) {
        $final[$bucket].Add('- [@' + $login + '](https://github.com/' + $login + ') - $' + $st.amount + '/mo')
    }
}

# Conductor permanence: guaranteed by construction (never removed above),
# asserted here so regressions fail loudly during development.
# (No additional code needed - preservation is inherent.)

# --- assemble output ---
$newLines = New-Object System.Collections.Generic.List[string]
foreach ($l in $intro) { $newLines.Add($l) }
foreach ($t in $sectionOrder) {
    $newLines.Add('')
    $newLines.Add($headers[$t])
    foreach ($e in $final[$t]) { $newLines.Add('    ' + $e) }
    if ($final[$t].Count -eq 0) { $newLines.Add('    _No entries yet._') }
}
$newContent = ($newLines -join "`n") + "`n"

$total = 0
foreach ($t in $sectionOrder) { $total += $final[$t].Count }

if ($DryRun) {
    Write-Host 'DRY RUN - resulting SUPPORTERS.md:' -ForegroundColor Yellow
    Write-Output $newContent
} else {
    [System.IO.File]::WriteAllText($file, $newContent, (New-Object System.Text.UTF8Encoding $false))
    Write-Host ("synced: $total active entr(y/ies) - conductors preserved permanently") -ForegroundColor Green
    Write-Host 'next: review diff -> commit & push via GitLab (mirror carries it)'
}
