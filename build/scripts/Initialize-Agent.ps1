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
    # Version of taskctl to install
    $TaskctlVersion,

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
    $DockerPushRMVersion
)

# Determine the architecture that is being used
$uname_arch = Invoke-Expression -Command "uname -m"
if ($uname_arch -eq "x86_64") {
        $bin_arch = "amd64"
        $abbr_arch = "x64"
        $taskctl_arch = "amd64"
} elseif (@("aarch64", "arm64") -contains $uname_arch) {
        $bin_arch = "arm64"
        $abbr_arch = $bin_arch
        $taskctl_arch = "armv7"
}

# Install Taskctl
# - if not exists, download and install
# - if it does exist, check the version and update if necessary
$install_taskctl = $false
$taskctl_bin = "/usr/local/bin/taskctl"
if (Test-Path -Path $taskctl_bin) {

    Write-Information "Taskctl is installed, getting version"

    # get the current version and compare the with the version to install
    $version_string = Invoke-Expression -Command "taskctl --version"
    $version = ($version_string -split " ")[2]
    if ($version -ne $TaskctlVersion) {

        Write-Information "Taskctl [$version] is out of date, updating to version $TaskctlVersion"

        $install_taskctl = $true
    }

} else {

    Write-Information "Taskctl is not installed, installing version $TaskctlVersion"

    $install_taskctl = $true
}

if ($install_taskctl) {

    # Set the URL to download taskctl
    $url = "https://github.com/Ensono/taskctl/releases/download/v{0}/taskctl_{0}_linux_{1}.tar.gz" -f $TaskctlVersion, $taskctl_arch

    Invoke-RestMethod -Uri $url -OutFile "/tmp/taskctl.tar.gz"

    # Extract the tarball
    tar zxf /tmp/taskctl.tar.gz -C /usr/local/bin taskctl
}

# Install EnsonoBuild
# Ensure that the Module directory exists
$module_path = "/home/vsts/.local/share/powershell/Modules/EnsonoBuild"
if (!(Test-Path -Path $module_path)) {
    Write-Information "Creating EnsonoBuild module directory"
    New-Item -Path $module_path -Force -Type Directory
}

# Download the EnsonoBuild module files
$module_files = @(
    "https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psd1" -f $EnsonoBuildVersion,
    "https://github.com/Ensono/independent-runner/releases/download/v{0}/EnsonoBuild.psm1" -f $EnsonoBuildVersion
)

Write-Information "Installing EnsonoBuild module"
foreach ($module_file in $module_files) {

    # Get the filename of the file being downloaded
    $filename = Split-Path -Path $module_file -Leaf

    Invoke-RestMethod -Uri $module_file -Outfile $module_path/$filename
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
        "uri" = "https://github.com/christian-korneck/docker-pushrm/releases/download/v{0}/docker-pushrm_linux_{1}" -f $DockerPushRMVersion, $abbr_arch
        "outfile" = Join-Path -Path $plugins_path -ChildPath "docker-pushrm"
    }
}

# - if not exists, download and install
foreach ($plugin in $plugins.GetEnumerator()) {

    if (!(Test-Path -Path $plugin.Value.outfile)) {

        Write-Information "Installing Docker plugin: ${plugin.Name}"

        Invoke-RestMethod -Uri $plugin.Value.uri -OutFile $plugin.Value.outfile
    }
}




