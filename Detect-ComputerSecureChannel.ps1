$ErrorActionPreference = 'Stop'

try {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    if (-not $computerSystem.PartOfDomain) {
        Write-Output 'Device is not domain-joined; secure-channel check skipped.'
        exit 0
    }

    $domain = $computerSystem.Domain
    $nltestPath = Join-Path $env:SystemRoot 'System32\nltest.exe'
    $null = & $nltestPath "/dsgetdc:$domain" /force 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "No domain controller is currently reachable for '$domain'; secure-channel check skipped."
        exit 0
    }

    $secureChannelHealthy = Test-ComputerSecureChannel -ErrorAction Stop
    if ($secureChannelHealthy) {
        Write-Output 'Computer secure channel is healthy.'
        exit 0
    }

    Write-Output 'Computer secure channel is unhealthy; remediation is required.'
    exit 1
}
catch {
    Write-Output "Secure-channel detection failed: $($_.Exception.Message)"
    exit 1
}
