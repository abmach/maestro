$ErrorActionPreference = 'Stop'
$token = $env:MAESTRO_GH_TOKEN
if (-not $token) { Write-Output 'NO TOKEN in environment'; exit 0 }

$headers = @{ Authorization = "Bearer $token"; 'User-Agent' = 'maestro-probe' }
$ep = 'https://api.github.com/graphql'

# 1. What activity types exist?
$q1 = '{ __type(name: "SponsorsActivityAction") { enumValues { name } } }'
$r1 = Invoke-RestMethod -Uri $ep -Method Post -Headers $headers -Body (@{ query = $q1 } | ConvertTo-Json) -ContentType 'application/json'
Write-Output '=== SponsorsActivityAction enum ==='
Write-Output (($r1.data.__type.enumValues | ForEach-Object Name) -join ', ')

# 2. Does Sponsorship have a nullable/one-time tier field?
$q2 = '{ __type(name: "Sponsorship") { fields { name type { kind name ofType { name } } } } }'
$r2 = Invoke-RestMethod -Uri $ep -Method Post -Headers $headers -Body (@{ query = $q2 } | ConvertTo-Json) -ContentType 'application/json'
Write-Output '=== Sponsorship fields (tier/oneTime related) ==='
foreach ($f in $r2.data.__type.fields) {
    if ($f.name -match 'tier|oneTime|amount') {
        Write-Output ("  " + $f.name + " : " + $f.type.kind + " " + $f.type.name + $f.type.ofType.name)
    }
}

# 3. Does the User expose one-time payment info?
$q3 = '{ __type(name: "User") { fields { name } } }'
$r3 = Invoke-RestMethod -Uri $ep -Method Post -Headers $headers -Body (@{ query = $q3 } | ConvertTo-Json) -ContentType 'application/json'
Write-Output '=== User fields mentioning sponsor/payment ==='
foreach ($f in $r3.data.__type.fields) {
    if ($f.name -match 'sponsor|payment') { Write-Output ("  " + $f.name) }
}
