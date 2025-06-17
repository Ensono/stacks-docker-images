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
    # Version of terraform to install
    $TerraformVersion,

    [string]
    [Parameter(
        Mandatory = $true
    )]
    # Version of EnsobBuild to install
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
$uname_arch = Invoke-Expression -Command "uname -m"
if ($uname_arch -eq "x86_64") {
    $bin_arch = "amd64"
    $abbr_arch = "x64"
    $eirctl_arch = "amd64"
}
elseif (@("aarch64", "arm64") -contains $uname_arch) {
    $bin_arch = "arm64"
    $abbr_arch = $bin_arch
    $eirctl_arch = "arm64"
}

# Install unzip on the agent, if it is not installed
$unzip_installed = Get-Command -Name "unzip" -ErrorAction SilentlyContinue
if ([String]::IsNullOrEmpty($unzip_installed)) {

    Write-Information "Unzip is not installed, installing it now"
    sudo apt-get update
    sudo apt-get install -y unzip

}
else {
    Write-Information "Unzip is already installed"
}

# Install eirctl
# - if not exists, download and install
# - if it does exist, check the version and update if necessary
$install_eirctl = $false
$eirctl_bin = "/usr/local/bin/eirctl"
if (Test-Path -Path $eirctl_bin) {

    Write-Information "eirctl is installed, getting version"

    # get the current version and compare the with the version to install
    $version_string = Invoke-Expression -Command "eirctl --version"
    $version = ($version_string -split " ")[2]
    if ($version -ne $eirctlVersion) {

        Write-Information "eirctl [$version] is out of date, updating to version $eirctlVersion"

        $install_eirctl = $true
    }

}
else {

    Write-Information "eirctl is not installed, installing version $eirctlVersion"

    $install_eirctl = $true
}

if ($install_eirctl) {

    # Set the URL to download eirctl
    $url = "https://github.com/Ensono/eirctl/releases/download/{0}/eirctl-linux-{1}" -f $eirctlVersion, $eirctl_arch

    Invoke-RestMethod -Uri $url -OutFile "/usr/local/bin/eirctl"

    # Extract the tarball
    # tar zxf /tmp/eirctl.tar.gz -C /usr/local/bin eirctl
    chmod +x /usr/local/bin/eirctl

    Get-ChildItem /usr/local/bin/eirctl

    # Output the version of eirctl
    eirctl -v
}

# Install Terraform
# On ADO agents using Ubuntu 24.04 Terraform is not installed by default
# This checks to see if Terraform is installed, and if not, installs it
$terraform_path = Get-Command -Name "terraform" -ErrorAction SilentlyContinue
$install_terraform = $false
if ([String]::IsNullOrEmpty($terraform_path)) {

    Write-Information "Terraform is not installed, installing version $TerraformVersion"
    $install_terraform = $true
}
else {
    Write-Information "Terraform is installed, checking version"
    $version_object = Invoke-Expression -Command "terraform version -json" | ConvertFrom-Json
    if ($version_object.terraform_version -ne $TerraformVersion) {
        Write-Information "Terraform [$version] is not as expected, installing version $TerraformVersion"
        $install_terraform = $true
    }
}

if ($install_terraform) {

    $url = "https://releases.hashicorp.com/terraform/{0}/terraform_{0}_linux_{1}.zip" -f $TerraformVersion, $bin_arch

    Invoke-RestMethod -Uri $url -OutFile "/tmp/terraform.zip"

    # Extract Terraform from the zip file
    unzip -j /tmp/terraform.zip -d /usr/local/bin terraform

    chmod +x /usr/local/bin/terraform

    terraform version
}

# Install EnsonoBuild
# Ensure that the Module directory exists
$module_path = "{0}/.local/share/powershell/Modules/EnsonoBuild" -f $home
if (!(Test-Path -Path $module_path)) {
    Write-Information "Creating EnsonoBuild module directory"
    New-Item -Path $module_path -Force -Type Directory
}

# Download the EnsonoBuild module files
$module_files = @(
    ("https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psd1" -f $EnsonoBuildVersion),
    ("https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psm1" -f $EnsonoBuildVersion)
)

Write-Information "Installing EnsonoBuild module"
foreach ($module_file in $module_files) {

    # Get the filename of the file being downloaded
    $filename = Split-Path -Path $module_file -Leaf

    Write-Information ("Downloading module file '{0}' from {1}" -f $filename, $module_file)

    $output_path = Join-Path -Path $module_path -ChildPath $filename
    Invoke-RestMethod -Uri $module_file -Outfile $output_path
}

# PowerShell modules
# Set the list of powershell modules to install
$powershell_modules = @(
    "Powershell-Yaml"
)

foreach ($powershell_module in $powershell_modules) {
    Install-Module -Name $powershell_module -Scope CurrentUser -Repository PSGallery -Force
}

# Install Docker plugins
$plugins_path = "{0}/.docker/cli-plugins" -f $env:HOME

if (!(Test-Path -Path $plugins_path)) {
    New-Item -Path $plugins_path -Force -Type Directory
}

$plugins = @{
    "docker-pushrm" = @{
        "uri"     = "https://github.com/christian-korneck/docker-pushrm/releases/download/v{0}/docker-pushrm_linux_{1}" -f $DockerPushRMVersion, $bin_arch
        "outfile" = Join-Path -Path $plugins_path -ChildPath "docker-pushrm"
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
    Uri     = "https://github.com/mikefarah/yq/releases/download/v{0}/yq_linux_{1}" -f $YqVersion, $bin_arch
    OutFile = "/usr/local/bin/yq"
}

Write-Information ("Downloading from: {0}" -f $splat.Uri)
Invoke-RestMethod @splat

chmod u+x /usr/local/bin/yq

## Replace registry and tag
$yqCommand = '.contexts.powershell_docker.container.name |= select(contains("ensono/eir-foundation-builder")) = "{0}/ensono/eir-foundation-builder:{1}"' -f $DockerContainerRegistryName, $BuildNumber
Write-Information ("Executing yq with '{0}'" -f $yqCommand)
yq -i $yqCommand build/eirctl/contexts.yaml

Get-Content -Raw build/eirctl/contexts.yaml
