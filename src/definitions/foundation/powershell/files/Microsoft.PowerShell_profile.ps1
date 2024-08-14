# Profile script for PowerShell
# Settings in here apply to all users on the machine

# Update the location for PowerShell modules, if the PSModule path does not contain `/modules`
if ($env:PSModulePath -notlike "*:/modules*")
{
    $env:PSModulePath += ":/modules"
}

# Set the information preference so that Write-Information is always displayed
$InformationPreference = "Continue"

# Set the ErrorAction so that if there is an error it will stop
$ErrorActionPreference = "Stop"

# Allow errors from CLI commands to be treated more like PowerShell errors
# This is available in PowerShell 7,3 and later
# https://matthorgan.xyz/blog/powershell-handling-native-applications/
$PSNativeCommandErrorActionPreference = $true