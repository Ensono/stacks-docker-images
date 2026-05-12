<#

.SYNOPSIS
Configure the agent with the necessary tools to build the Docker images

#>

[CmdletBinding()]
param (

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # Version of eirctl to install
    $EirctlVersion,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # Version of EnsonoBuild to install
    $EnsonoBuildVersion,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # Version of DockerPushRM to install
    $DockerPushRMVersion,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # Version of yq to install
    $YqVersion,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # The Build Number of the current run
    $BuildNumber,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # The Registry for pushing images
    $DockerContainerRegistryName

)

# Determine the architecture that is being used
$unameArch = Invoke-Expression -Command "uname -m"
if ($unameArch -eq "x86_64") {
    $binArch = "amd64"
}
elseif (@("aarch64", "arm64") -contains $unameArch) {
    $binArch = "arm64"
}

# Install Eirctl
# - if not exists, download and install
# - if it does exist, check the version and update if necessary
$installEirctl = $false
$eirctlBin = "/usr/local/bin/eirctl"
if (Test-Path -Path $eirctlBin) {
    Write-Information "Eirctl is installed, getting version"

    # Get the current version and compare the with the version to install
    $versionString = Invoke-Expression -Command "eirctl --version"
    $rawVersion = ($versionString -split " ")[2]
    $version = ($rawVersion -split "-")[0]
    if ($version -ne $EirctlVersion) {

        Write-Information "Eirctl [$rawVersion] is out of date, updating to version $EirctlVersion"

        $installEirctl = $true
    }
}
else {
    Write-Information "Eirctl is not installed, installing version $EirctlVersion"
    $installEirctl = $true
}

if ($installEirctl) {
    Write-Information "Downloading Eirctl, version $EirctlVersion"
    $url = "https://github.com/Ensono/eirctl/releases/download/{0}/eirctl-linux-{1}" -f $EirctlVersion, $binArch

    Invoke-RestMethod -Uri $url -OutFile "/usr/local/bin/eirctl"

    chmod +x /usr/local/bin/eirctl

    /usr/local/bin/eirctl --version
}

# Install EnsonoBuild
# Ensure that the Module directory exists
$modulePath = "{0}/.local/share/powershell/Modules/EnsonoBuild" -f $home
if (!(Test-Path -Path $modulePath)) {
    Write-Information "Creating EnsonoBuild module directory"
    New-Item -Path $modulePath -Force -Type Directory
}

# Download the EnsonoBuild module files
$moduleFiles = @(
    ("https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psd1" -f $EnsonoBuildVersion),
    ("https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psm1" -f $EnsonoBuildVersion)
)

Write-Information "Installing EnsonoBuild module"
foreach ($moduleFile in $moduleFiles) {

    # Get the filename of the file being downloaded
    $filename = Split-Path -Path $moduleFile -Leaf

    Write-Information ("Downloading module file '{0}' from {1}" -f $filename, $moduleFile)

    $outputPath = Join-Path -Path $modulePath -ChildPath $filename
    Invoke-RestMethod -Uri $moduleFile -Outfile $outputPath
}

# PowerShell modules
# Set the list of powershell modules to install
$powershellModules = @(
    "Powershell-Yaml"
)

foreach ($powershellModule in $powershellModules) {
    Install-Module -Name $powershellModule -Scope CurrentUser -Repository PSGallery -Force
}

# Install Docker plugins
$pluginsPath = "{0}/.docker/cli-plugins" -f $env:HOME

if (!(Test-Path -Path $pluginsPath)) {
    New-Item -Path $pluginsPath -Force -Type Directory
}

$plugins = @{
    "docker-pushrm" = @{
        "uri"     = "https://github.com/christian-korneck/docker-pushrm/releases/download/v{0}/docker-pushrm_linux_{1}" -f $DockerPushRMVersion, $binArch
        "outfile" = Join-Path -Path $pluginsPath -ChildPath "docker-pushrm"
    }
}

# Install plug-ins and set them up if needed
foreach ($plugin in $plugins.GetEnumerator()) {

    if (!(Test-Path -Path $plugin.Value.outfile)) {

        Write-Information ("Installing Docker plugin: {0}" -f $plugin.Name)
        Write-Information ("`tDownloading from: {0}" -f $plugin.Value.uri)

        $splat = @{
            Uri     = $plugin.Value.uri
            OutFile = $plugin.Value.outfile
        }

        Invoke-RestMethod @splat
    }

    # Ensure the plugin command is executable by root...
    Write-Information ("Ensuring the file '{0}' is executable by root..." -f $plugin.Value.outfile)
    sudo chmod u+x $plugin.Value.outfile
}

# Install 'yq' and munge the 'powershell_docker' context in the 'contexts.yaml'
# file with the build number...
$splat = @{
    Uri     = "https://github.com/mikefarah/yq/releases/download/v{0}/yq_linux_{1}" -f $YqVersion, $binArch
    OutFile = "/usr/local/bin/yq"
}

Write-Information ("Downloading from: {0}" -f $splat.Uri)
Invoke-RestMethod @splat

chmod u+x /usr/local/bin/yq

## Replace registry and tag
$yqCommand = '.contexts.powershell_docker.container.name = "{0}/ensono/eir-foundation-builder:{1}"' -f $DockerContainerRegistryName, $BuildNumber
Write-Information ("Executing yq with '{0}'" -f $yqCommand)
yq -i $yqCommand build/eirctl/contexts.yaml

Get-Content -Raw build/eirctl/contexts.yaml
