
<#

.SYNOPSIS
Create a manifest for multiple Docker images

.DESCRIPTION
This script is used to create a manifest for multiple Docker images. The manifest will be created with the specified tags and pushed to the registry.

The main aim of the script is to being together multiple archictures under one manifest.

#>

[CmdletBinding()]
param (

    [string]
    # Build number to be use to find the iumages to group together and
    # the new manifest
    $Version = $env:DOCKER_IMAGE_TAG,

    [string]
    # Name of the manifest
    $Name = $env:DOCKER_IMAGE_NAME,

    [string[]]
    # List of the additional tags that nee to be used to find the images
    $Tags = @("amd64", "arm64"),

    [string]
    # Container registry
    $registry = $env:DOCKER_CONTAINER_REGISTRY_NAME,

    [string]
    # Username to login to the specified registry
    $username = $env:DOCKER_USERNAME,

    [String]
    # Associated password with the Docker username
    $password = $env:DOCKER_PASSWORD,

    [switch]
    # State that the scritp whould run in dryrun and not to execute any commands
    $dryrun
)

# Define cmd array from which all commands will be built
$cmds = @()

# Define default values for parameters not set
if ([string]::IsNullOrEmpty($registry)) {
    $registry = "docker.io"
}

# Iterate around the tages and build up the list of images
$images = @()
foreach ($tag in $Tags) {
    $images += "{0}/{1}:{2}-{3}" -f $registry, $Name, $Version, $tag
}

# Login to the specified container registry
Write-Host ("Logging into registry: {0}" -f $registry)
$cmds += "docker login -u {0} -p {1} {2}" -f $username, $password, $registry

# Build up the command to use to create the manifest
$cmds += "docker manifest create {0}/{1}:{2} {3}" -f $registry, $Name, $Version, ($images -join " ")

# Now push the manifest to the registry
$cmds += "docker manifest push {0}/{1}:{2}" -f $registry, $Name, $Version

foreach ($cmd in $cmds) {
    Write-Host $cmd
    if (!$dryrun.IsPresent) {
        Invoke-Expression $cmd
    }
}

