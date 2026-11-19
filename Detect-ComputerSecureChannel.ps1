<#
.SYNOPSIS
Detects whether the computer's domain secure channel is healthy.

Usage: Use this script as the "Detection script" paired with Remediate-ComputerSecureChannel.ps1 in Intune Remediations. Run in 64-bit PowerShell as SYSTEM.
Return: exits with code 0 when compliant or when a check is safely skipped, and code 1 when the secure channel is unhealthy or detection fails.
#>

$ErrorActionPreference = 'Stop'

try {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    if (-not $computerSystem.PartOfDomain) {
        Write-Output 'Warning:Device is not domain-joined; secure-channel check skipped.'
        exit 0
    }

    $domain = $computerSystem.Domain
    $nltestPath = Join-Path $env:SystemRoot 'System32\nltest.exe'
    $null = & $nltestPath "/dsgetdc:$domain" /force 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: No domain controller is currently reachable for '$domain'; secure-channel check skipped."
        exit 0
    }

    $secureChannelHealthy = Test-ComputerSecureChannel -ErrorAction Stop
    if ($secureChannelHealthy) {
        Write-Output 'Compliant: Computer secure channel is healthy.'
        exit 0
    }

    Write-Output 'Non-compliant: Computer secure channel is unhealthy. Remediation is required.'
    exit 1
}
catch {
    Write-Error "Secure-channel detection failed: $($_.Exception.Message)"
    exit 1
}
