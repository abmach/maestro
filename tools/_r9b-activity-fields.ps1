$ErrorActionPreference = 'Stop'
$token = $env:MAESTRO_GH_TOKEN
$headers = @{ Authorization = "Bearer $token"; 'User-Agent' = 'maestro-probe' }
$ep = 'https://api.github.com/graphql'

$q = '{ __type(name: "SponsorsActivity") { fields { name type { kind name ofType { kind name } } } } }'
$r = Invoke-RestMethod -Uri $ep -Method Post -Headers $headers -Body (@{ query = $q } | ConvertTo-Json) -ContentType 'application/json'
foreach ($f in $r.data.__type.fields) {
    $t = $f.type.name; if (-not $t) { $t = $f.type.kind }; if ($f.type.ofType.name) { $t += '/' + $f.type.ofType.name }
    Write-Output ("  " + $f.name + " : " + $t)
}
