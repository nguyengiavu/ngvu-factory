<#
.SYNOPSIS
  ngvu factory kit for Windows: runs deploy/<command>.sh with Git Bash.
.EXAMPLE
  .\deploy\ngvu-kit.ps1 bootstrap -Team <team> -DryRun
  .\deploy\ngvu-kit.ps1 bootstrap -Team ngvu -Workspace D:/workspace
  .\deploy\ngvu-kit.ps1 doctor
  .\deploy\ngvu-kit.ps1 uninstall -DryRun
#>
param(
    [Parameter(Mandatory = $true, Position = 0)][ValidateSet('bootstrap', 'doctor', 'uninstall')][string]$Command,
    [string]$Source,
    [string]$Workspace,
    [string]$Team,
    [switch]$DryRun,
    [switch]$Yes,
    [switch]$KeepLegacy
)

$candidates = @($env:CLAUDE_CODE_GIT_BASH_PATH, "$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe")
$bash = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $bash) {
    Write-Error 'Git Bash not found. Install Git for Windows, or set CLAUDE_CODE_GIT_BASH_PATH.'
    exit 30
}
$argList = @()
if ($Source) { $argList += @('--source', $Source) }
if ($Workspace) { $argList += @('--workspace', $Workspace) }
if ($Team) { $argList += @('--team', $Team) }
if ($DryRun) { $argList += '--dry-run' }
if ($Yes) { $argList += '--yes' }
if ($KeepLegacy) { $argList += '--keep-legacy' }
& $bash "$PSScriptRoot/$Command.sh" @argList
exit $LASTEXITCODE
