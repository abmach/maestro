# Signs all user-facing Maestro scripts with an Authenticode code-signing
# certificate. Requires the certificate to already exist in a cert store
# (Cert:\CurrentUser\My or Cert:\LocalMachine\My) with Code Signing EKU.
#
# Typical usage:
#   ./tools/sign-release.ps1 -CertThumbprint <thumbprint>
#
# Rules enforced here:
#   - Timestamp server is REQUIRED (signatures must outlive cert expiry).
#   - Every target must end with Status: Valid or the script fails.

param(
    [Parameter(Mandatory)] [string]$CertThumbprint,
    [string]$TimestampServer = 'http://timestamp.digicert.com',
    [string]$Root,
    [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }

$targets = @(
    'Install-Maestro.ps1',
    'tools/install-from-web.ps1',
    'tools/validate-bundle.ps1',
    'tools/smoke-install.ps1',
    'tools/build-module.ps1'
)

$cert = Get-ChildItem Cert:\CurrentUser\My, Cert:\LocalMachine\My -ErrorAction SilentlyContinue |
    Where-Object { $_.Thumbprint -eq $CertThumbprint } | Select-Object -First 1

if (-not $cert) { throw "Certificate $CertThumbprint not found in CurrentUser\My or LocalMachine\My" }
if ($cert.NotAfter -lt (Get-Date)) { throw 'Certificate is expired' }
if (-not ($cert.EnhancedKeyUsageList | Where-Object FriendlyName -eq 'Code Signing')) {
    Write-Warning 'Certificate does not advertise Code Signing EKU - signatures may not satisfy AllSigned policy'
}

Write-Host "Signing with: $($cert.Subject)"
Write-Host "Expires:      $($cert.NotAfter)"

foreach ($rel in $targets) {
    $path = Join-Path $Root $rel
    if (-not (Test-Path -LiteralPath $path)) { throw "missing target: $path" }

    if ($VerifyOnly) {
        $status = (Get-AuthenticodeSignature -LiteralPath $path).Status
        Write-Host ("  {0,-12} {1}" -f $status, $rel)
        continue
    }

    $result = Set-AuthenticodeSignature -LiteralPath $path -Certificate $cert -TimestampServer $TimestampServer
    if ($result.Status -ne 'Valid') {
        throw ("signing failed for {0}: {1} ({2})" -f $rel, $result.Status, $result.StatusMessage)
    }
    Write-Host ("  signed       {0}" -f $rel) -ForegroundColor Green
}

Write-Host ''
Write-Host '=== Verification pass ==='
foreach ($rel in $targets) {
    $sig = Get-AuthenticodeSignature -LiteralPath (Join-Path $Root $rel)
    Write-Host ("  {0,-12} {1}" -f $sig.Status, $rel)
    if ($sig.Status -ne 'Valid') { throw "post-sign verification failed for $rel" }
}
Write-Host 'ALL SCRIPTS SIGNED AND VALID' -ForegroundColor Green
