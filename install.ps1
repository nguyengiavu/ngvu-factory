<#
.SYNOPSIS
  Install ngvu-ai-factory (user level) into ~/.claude by running install.sh with Git Bash.
.EXAMPLE
  .\install.ps1 -WhatIf     # show what would be copied
  .\install.ps1             # install (asks before overwriting changed files)
  .\install.ps1 -Yes        # overwrite changed files without asking
  .\install.ps1 -NoGuardrails  # skip registering the push/Jira-write guardrails
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param([switch]$Yes, [switch]$NoGuardrails)

$candidates = @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe")
$bash = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $bash) {
    Write-Error 'Git Bash not found. Install Git for Windows first.'
    exit 1
}
$argList = @()
if ($WhatIfPreference) { $argList += '--dry-run' }
if ($Yes) { $argList += '--yes' }
if ($NoGuardrails) { $argList += '--no-guardrails' }
& $bash "$PSScriptRoot/install.sh" @argList
exit $LASTEXITCODE
