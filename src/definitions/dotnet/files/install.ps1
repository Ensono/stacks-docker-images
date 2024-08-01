<#

.SYNOPSIS
Installs different versions of the .NET SDKS

.DESCRIPTION
Many .NET SDKS can be installed on the same machine using the same install script from
Microsoft. However that tool cannot install multiple versions at the same time. This script
takes a comma delimited list of the versions to install and iterates around them installing
each one using the dotnet-install.bash script

#>

[CmdletBinding()]
param (

    [string]
    # Comma delimited list of .NET SDK versions to install
    $list,

    [string]
    # Path to the tool to use to install the SDK
    $toolpath = "/usr/local/dotnet",

    [string]
    # Version of SONARSCANNER to install
    $sonarscanner_version,

    [string]
    # Version of the reportgenerator to install
    $reportgenerator_version
)

# Check to see if the tool exists, if not install it
if (!(Test-Path -Path $toolpath)) {
    Write-Host "Downloading Dotnet installation tool"

    # Download the script to the tmp directory
    Invoke-RestMethod -Method GET -Uri https://dot.net/v1/dotnet-install.bash -OutFile /tmp/dotnet-install.bash -FollowRelLink
}

# Split the version into an array to iterate around
$versions = $list -Split ","

# If there are no versions specified, exit with a message
if ($versions.length -eq 0) {
    Write-Host -Object "Please provide a list of versions to install"
} else {


    # Iterate around each version
    foreach ($version in $versions) {

        # Determine the framework moniker
        # https://learn.microsoft.com/en-us/dotnet/standard/frameworks#latest-versions
        $moniker = "net{0}.0" -f $($version -split "\.")[0]

        $cmds = @()

        # Build up the commands that need to be executed
        # --- Install Framework
        $cmds += "bash /tmp/dotnet-install.bash --install-dir {0} --version {1}" -f $toolpath, $version

        # --- Install SonarScanner
        $cmds += "dotnet tool install dotnet-sonarscanner --version {0} --tool-path {1} --framework {2}" -f $sonarscanner_version, $toolpath, $moniker

        # --- Install ReportGenerator
        $cmds += "dotnet tool install dotnet-reportgenerator-globaltool --version {0} --tool-path {1} --framework {2}" -f $reportgenerator_version, $toolpath, $moniker

        # iterate around the commands
        foreach ($cmd in $cmds) {
            Write-Host $cmd

            # Execute the command
            Invoke-Expression $cmd
        }

        
    }
}
