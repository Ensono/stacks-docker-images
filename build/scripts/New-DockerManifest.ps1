
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
    $dryrun,

    [switch]
    # State if manifest should be tagged as Latest
    $Latest
)

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
Invoke-External -Command "docker login -u $username -p $password $registry" -Dryrun:$dryrun

Invoke-External -Command "docker manifest create `"${registry}/${Name}:${Version}`" $($images -join " ")" -Dryrun:$dryrun

# Now push the manifest to the registry
Invoke-External -Command "docker manifest push `"${registry}/${Name}:${Version}`"" -Dryrun:`$$dryrun

if ($Latest.IsPresent) {
    # Tag manifest with the latest tage
    Invoke-External -Command "docker manifest create `"${registry}/${Name}:latest`" $($images -join " ")" -Dryrun:$dryrun

    Invoke-External -Command "docker manifest push `"${registry}/${Name}:latest`"" -Dryrun:$dryrun
}
