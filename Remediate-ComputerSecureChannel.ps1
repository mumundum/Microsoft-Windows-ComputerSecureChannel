$ErrorActionPreference = 'Stop'

try {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    if (-not $computerSystem.PartOfDomain) {
        Write-Output 'Device is not domain-joined; secure-channel repair skipped.'
        exit 1
    }

    $domain = $computerSystem.Domain
    $nltestPath = Join-Path $env:SystemRoot 'System32\nltest.exe'
    $null = & $nltestPath "/dsgetdc:$domain" /force 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "No domain controller is currently reachable for '$domain'; secure-channel repair skipped."
        exit 1
    }

    $repairSucceeded = Test-ComputerSecureChannel -Repair -ErrorAction Stop
    if ($repairSucceeded) {
        Write-Output 'Computer secure channel was repaired successfully.'
        exit 0
    }

    Write-Output 'Computer secure-channel repair did not succeed.'
    exit 1
}
catch {
    Write-Output "Secure-channel remediation failed: $($_.Exception.Message)"
    exit 1
}
