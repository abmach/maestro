# Rebuilds the tiered sections of SUPPORTERS.md from live GitHub Sponsors data.
#
# Preservation guarantees:
#   - Conductor's Circle: entries are PERMANENT (Founding rule). Cancellations,
#     refunds, downgrades - nothing removes them automatically. Manual only.
#   - Encore/Applause: entries tied to GitHub sponsorships follow the API -
#     cancellations and refunds drop them. Manual entries (lines without a
#     github.com link, e.g. bank-transfer backers) are preserved untouched.
#
# One-time payments: surfaced for manual review (printed as a notice) because
# the API does not reliably expose their amount - run add-supporter.ps1 for
# whoever qualifies after eyeballing the payment.
#
# Usage:
#   ./tools/sync-supporters.ps1                # live sync
#   ./tools/sync-supporters.ps1 -DryRun        # preview resulting file
#   ./tools/sync-supporters.ps1 -MockActivitiesJson '<json>' -MockSponsorshipsJson '<json>'
param(
    [string]$Login = 'abmach',
    [string]$Token = $env:MAESTRO_GH_TOKEN,
    [string]$Root,
    [string]$MockActivitiesJson,
    [string]$MockSponsorshipsJson,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $MockActivitiesJson -and -not $Token) {
    throw "Set MAESTRO_GH_TOKEN (a GitHub PAT with read:user scope) to sync supporters."
}
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$file = Join-Path $Root 'SUPPORTERS.md'
if (-not (Test-Path -LiteralPath $file)) { throw "SUPPORTERS.md not found at $file" }

$query = @'
query($login:String!){
  user(login:$login){
    sponsorsActivities(first:100,order:{field:TIMESTAMP,direction:DESC}){
      nodes{
        action
        sponsor{ login }
        sponsorsTier{ monthlyPriceInDollars }
        previousSponsorsTier{ monthlyPriceInDollars }
      }
    }
    sponsorshipsAsMaintainer(first:100){
      nodes{
        sponsor{ login }
        tier{ monthlyPriceInDollars }
        isOneTimePayment
      }
    }
  }
}
'@

$activities = @()
$sponsorships = @()

if ($MockActivitiesJson) {
    Write-Host 'using mocked data' -ForegroundColor Yellow
    $mock = @{ data = @{ user = @{
        sponsorsActivities       = @{ nodes = ($MockActivitiesJson | ConvertFrom-Json) }
        sponsorshipsAsMaintainer = @{ nodes = if ($MockSponsorshipsJson) { ($MockSponsorshipsJson | ConvertFrom-Json) } else { @() } }
    } } }
    $activities = $mock.data.user.sponsorsActivities.nodes
    $sponsorships = $mock.data.user.sponsorshipsAsMaintainer.nodes
} else {
    $body = @{ query = $query; variables = @{ login = $Login } } | ConvertTo-Json -Depth 6
    $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Method Post `
        -Headers @{ Authorization = "Bearer $Token"; 'User-Agent' = 'maestro-sync' } `
        -Body $body -ContentType 'application/json'
    $activities = $response.data.user.sponsorsActivities.nodes
    $sponsorships = $response.data.user.sponsorshipsAsMaintainer.nodes
}

# --- derive current state ---
$state = @{}
$pendingManual = New-Object System.Collections.Generic.List[string]

foreach ($s in $sponsorships) {
    $login = $s.sponsor.login
    if (-not $state.ContainsKey($login)) {
        $state[$login] = @{ amount = 0; active = $true }
    }
    if ($s.isOneTimePayment) {
        # One-time payment: amount not exposed via tier - flag for manual review.
        $pendingManual.Add("one-time payment from @$login (amount unknown via API)")
        continue
    }
    $amt = 0
    if ($s.tier -and $s.tier.monthlyPriceInDollars) { $amt = [int]$s.tier.monthlyPriceInDollars }
    $state[$login].amount = [Math]::Max($state[$login].amount, $amt)
}

foreach ($a in $activities) {
    $login = $a.sponsor.login
    if (-not $state.ContainsKey($login)) {
        $state[$login] = @{ amount = 0; active = $false }
    }
    switch ($a.action) {
        'NEW_SPONSORSHIP'          { if ($a.sponsorsTier -and $a.sponsorsTier.monthlyPriceInDollars) { $state[$login].amount = [Math]::Max($state[$login].amount, [int]$a.sponsorsTier.monthlyPriceInDollars); $state[$login].active = $true } }
        'TIER_CHANGE'              { if ($a.sponsorsTier -and $a.sponsorsTier.monthlyPriceInDollars) { $state[$login].amount = [Math]::Max($state[$login].amount, [int]$a.sponsorsTier.monthlyPriceInDollars) } }
        'CANCELLED_SPONSORSHIP'    { $state[$login].active = $false }
        'REFUND'                   { $state[$login].active = $false }
        default                    { }   # PENDING_CHANGE / SPONSOR_MATCH_DISABLED ignored
    }
}

function Get-Bucket([int]$amount) {
    if ($amount -ge 25) { 'Conductor' } elseif ($amount -ge 10) { 'Encore' } else { 'Applause' }
}

# --- parse existing SUPPORTERS.md (preservation source) ---
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

$firstTierIdx = $null
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^## 💎') { $firstTierIdx = $i; break } }
if (-not $firstTierIdx) { throw 'tier headings not found in SUPPORTERS.md' }

$intro = $lines[0..($firstTierIdx - 1)]
$preserved = @{}
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

# --- merge with guarantees ---
$final = @{}
foreach ($t in $sectionOrder) {
    $final[$t] = New-Object System.Collections.Generic.List[string]
    if ($preserved.ContainsKey($t)) { foreach ($e in $preserved[$t]) { $final[$t].Add($e) } }
}

# Removals: inactive GitHub-channel sponsors drop from Encore/Applause only.
# Conductor's Circle is intentionally untouched here - Founding permanence
# means cancellations/refunds NEVER auto-remove conductors (manual only).
foreach ($t in @('Encore', 'Applause')) {
    for ($i = $final[$t].Count - 1; $i -ge 0; $i--) {
        $lg = Get-EntryLogin $final[$t][$i]
        if ($lg -and $state.ContainsKey($lg) -and (-not $state[$lg].active)) {
            Write-Host ("dropping inactive sponsor from " + $t + ": @" + $lg) -ForegroundColor DarkGray
            $final[$t].RemoveAt($i)
        }
    }
}

foreach ($login in $state.Keys) {
    $st = $state[$login]
    if (-not $st.active) { continue }   # cancelled/refunded -> drops from Encore/Applause;
                                        # Conductor entries preserved unconditionally above
    $bucket = Get-Bucket $st.amount
    $already = $false
    foreach ($t in $sectionOrder) {
        for ($i = 0; $i -lt $final[$t].Count; $i++) {
            if ((Get-EntryLogin $final[$t][$i]) -eq $login) {
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

# --- assemble ---
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
