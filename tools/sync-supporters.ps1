# Rebuilds the tiered sections of SUPPORTERS.md from live GitHub Sponsors data.
#
# Prerequisites:
#   MAESTRO_GH_TOKEN environment variable - a GitHub PAT with read:user scope.
#
# Behavior:
#   - Fetches active sponsors + latest tier activity for the given login.
#   - Maps monthly contribution to tiers: >= $25 Conductor's Circle,
#     >= $10 Encore, > $0 Applause. Adjust thresholds below if needed.
#   - Regenerates ONLY the three tier sections; everything above the first
#     '## 💎' heading (intro, links) is preserved untouched.
#   - Private sponsors (hidden by their choice) never appear in the API and
#     therefore never appear here - by design.
#
# Usage:
#   ./tools/sync-supporters.ps1            # write changes
#   ./tools/sync-supporters.ps1 -DryRun    # preview only
param(
    [string]$Login = 'abmach',
    [string]$Token = $env:MAESTRO_GH_TOKEN,
    [string]$Root,
    [string]$ModulePath,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $Token) { throw "Set MAESTRO_GH_TOKEN (a GitHub PAT with read:user scope) to sync supporters." }
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$file = Join-Path $Root 'SUPPORTERS.md'
if (-not (Test-Path -LiteralPath $file)) { throw "SUPPORTERS.md not found at $file" }

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

# Latest activity per sponsor determines current tier/status
$state = @{}
foreach ($a in $activities) {
    $login = $a.sponsor.login
    if (-not $state.ContainsKey($login)) {
        $state[$login] = @{
            tier  = 0
            since = ([datetime]$a.timestamp).ToUniversalTime().ToString('yyyy-MM')
        }
    }
    switch ($a.action) {
        'NEW_SPONSORSHIP'       { $state[$login].tier = [Math]::Max($state[$login].tier, [int]$a.tier.monthlyPriceInDollars) }
        'SPONSORSHIP_TIER_CHANGE'{ $state[$login].tier = [Math]::Max($state[$login].tier, [int]$a.tier.monthlyPriceInDollars) }
        'CANCELLED_SPONSORSHIP' { $state[$login].tier = 0 }
    }
}

$tiers = @{
    Conductor = @{ label = 'Conductor''s Circle'; min = 25 }
    Encore    = @{ label = 'Encore';              min = 10 }
    Applause  = @{ label = 'Applause';            min = 1 }
}
$result = @{}
foreach ($t in $tiers.Keys) { $result[$t] = New-Object System.Collections.Generic.List[string] }

foreach ($login in $state.Keys) {
    $amount = $state[$login]
    if ($amount -le 0) { continue }   # cancelled -> removed from lists entirely
    $bucket = if ($amount -ge 25) { 'Conductor' } elseif ($amount -ge 10) { 'Encore' } else { 'Applause' }
    $entry = '- [@' + $login + '](https://github.com/' + $login + ') - $' + $amount + '/mo since ' + $state[$login].since
    $result[$bucket].Add($entry)
}

# --- rewrite tier sections, preserving everything above the first tier heading ---
$lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$i = 0
while ($i -lt $lines.Count -and $lines[$i] -notmatch '^## 💎') { $out.Add($lines[$i]); $i++ }

foreach ($t in @('Conductor', 'Encore', 'Applause')) {
    $header = switch ($t) {
        'Conductor' { '## 💎 Conductor''s Circle' }
        'Encore'    { '## 🎭 Encore' }
        'Applause'  { '## 👏 Applause' }
    }
    $out.Add('')
    $out.Add($header)
    if ($result[$t].Count -eq 0) {
        $out.Add('_No entries yet._')
    } else {
        foreach ($e in $result[$t]) { $out.Add($e) }
    }
}

$newContent = ($out -join "`n") + "`n"

if ($DryRun) {
    Write-Host 'DRY RUN - resulting SUPPORTERS.md:' -ForegroundColor Yellow
    Write-Output $newContent
} else {
    [System.IO.File]::WriteAllText($file, $newContent, (New-Object System.Text.UTF8Encoding $false))
    $total = ($result['Conductor'].Count + $result['Encore'].Count + $result['Applause'].Count)
    Write-Host ("synced: $total active supporter(s) across tiers") -ForegroundColor Green
    Write-Host 'next: review the diff, then commit & push through GitLab (mirror carries it)'
}
