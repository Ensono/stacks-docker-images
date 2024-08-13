# Profile script for PowerShell
# Settings in here apply to all users on the machine

# Update the location for PowerShell modules, if the PSModule path does not contain `/modules`
if ($env:PSModulePath -notlike "*:/modules*")
{
    $env:PSModulePath += ":/modules"
}
