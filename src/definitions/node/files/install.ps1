
<#

.SYNOPSIS
References the installed Node versions and makes them visible in PowerShell

.DESCRIPTION
Installs the PSNvm PowerShell module and configures it to references the installed node versions

Finally it updates the profile script to set the default version of Node to be used

#>

[CmdletBinding()]
param (
    [string]
    # List of node versions that are installed
    $Versions = $env:NODE_VERSIONS
)

# Split the Versions and get the default versions
$default_version = $Versions.Split(",")[0]

# Install the PSNvm module
Install-Module -Name nvm -Force -AllowClobber

# Set the location of the node versions that are installed
# This is done using a file because the Set-NodeInstallPath from the module automatially
# appends `.nvm` to the specified path.
$settings = '{"InstallPath": "/root/.nvm/versions/node"}'

Set-Content -Path /root/.local/share/powershell/Modules/nvm/2.5.4/settings.json -Value $settings

# Set the default version of node to be used
# This is added to the end of the profile
$profile_path = "/opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1"

$nvm_settings = @"

# Configure default node version
Set-NodeVersion -Version $default_version
"@

# Append the nvm_settings to the profile file, if not already present
if (!(Select-String -Path $profile_path -Pattern "Set-NodeVersion")) {
    Add-Content -Path $profile_path -Value $nvm_settings
}