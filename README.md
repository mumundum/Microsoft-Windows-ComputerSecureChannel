# Intune Remediation: Computer Secure Channel

These Windows PowerShell 5.1 scripts detect and remediate a broken domain computer secure channel. Deploy Detect-ComputerSecureChannel.ps1 as the Intune detection script and Remediate-ComputerSecureChannel.ps1 as its remediation script. Run both scripts in the 64-bit PowerShell host as SYSTEM.

## Detection

The detection script first verifies that the device is domain-joined and that a domain controller is reachable. It then uses Test-ComputerSecureChannel to determine whether the computer secure channel is healthy.

- Exit code 0 indicates a compliant device or a safely skipped check.
- Exit code 1 indicates an unhealthy secure channel or a detection failure.

Non-domain-joined devices and devices with no reachable domain controller are skipped so that remediation is not triggered.

## Remediation

The remediation script repeats the domain membership and domain-controller checks, then calls Test-ComputerSecureChannel -Repair.

- Exit code 0 indicates that the secure channel was repaired successfully.
- Exit code 1 indicates that the device was not eligible or that remediation failed.

## Intune configuration

- Detection script: Detect-ComputerSecureChannel.ps1
- Remediation script: Remediate-ComputerSecureChannel.ps1
- Run scripts in 64-bit PowerShell: Enabled
- Run as: System
