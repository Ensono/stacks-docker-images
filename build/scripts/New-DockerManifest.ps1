
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
    # Build number to be use to find the images to group together and
    # the new manifest
    $Version = $env:DOCKER_IMAGE_TAG,

    [string]
    # Name of the manifest
    $Name = $env:DOCKER_IMAGE_NAME,

    [string[]]
    # List of the additional tags that need to be used to find the images
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
    # State that the script would run in dry run and not to execute any commands
    $Dryrun,

    [switch]
    # State if manifest should be tagged as Latest
    $Latest,

    [ValidateRange(1, [int]::MaxValue)]
    [int]
    # Number of times to check whether source image manifests are visible
    $ManifestCheckRetries = 24,

    [ValidateRange(1, [int]::MaxValue)]
    [int]
    # Delay between manifest availability checks in seconds
    $ManifestCheckDelaySeconds = 10
)

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

function Invoke-DockerCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Command,

        [switch]
        $Dryrun
    )

    Invoke-External -Command $Command -Dryrun:$Dryrun

    if (-not $Dryrun.IsPresent -and $LASTEXITCODE -ne 0) {
        throw ("Docker command failed with exit code {0}: {1}" -f $LASTEXITCODE, $Command)
    }
}

function Wait-ForDockerManifest {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Image,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Retries,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $DelaySeconds
    )

    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        & docker manifest inspect $Image *> $null

        if ($LASTEXITCODE -eq 0) {
            Write-Host ("Found image manifest: {0}" -f $Image)
            return
        }

        if ($attempt -eq $Retries) {
            # Emit inspect output once at the end to help diagnose registry propagation/auth issues in CI logs.
            & docker manifest inspect $Image
            throw ("Image manifest did not become available after {0} attempts: {1}" -f $Retries, $Image)
        }

        Write-Host ("Waiting for image manifest ({0}/{1}): {2}" -f $attempt, $Retries, $Image)
        Start-Sleep -Seconds $DelaySeconds
    }
}

function Get-PositiveIntEnvOverride {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $EnvVarName,

        [Parameter(Mandatory = $true)]
        [int]
        $CurrentValue
    )

    $rawValue = [Environment]::GetEnvironmentVariable($EnvVarName)
    if ([string]::IsNullOrWhiteSpace($rawValue)) {
        return $CurrentValue
    }

    $parsedValue = 0
    if (-not [int]::TryParse($rawValue, [ref]$parsedValue)) {
        throw ("Invalid value for {0}: '{1}'. Expected a positive integer." -f $EnvVarName, $rawValue)
    }

    if ($parsedValue -le 0) {
        throw ("Invalid value for {0}: '{1}'. Value must be greater than zero." -f $EnvVarName, $rawValue)
    }

    return $parsedValue
}

# Allow retry behavior to be controlled from pipeline variables without changing taskctl invocation.
$ManifestCheckRetries = Get-PositiveIntEnvOverride -EnvVarName "DOCKER_MANIFEST_CHECK_RETRIES" -CurrentValue $ManifestCheckRetries
$ManifestCheckDelaySeconds = Get-PositiveIntEnvOverride -EnvVarName "DOCKER_MANIFEST_CHECK_DELAY_SECONDS" -CurrentValue $ManifestCheckDelaySeconds

Write-Host ("Manifest availability checks configured: retries={0}, delaySeconds={1}" -f $ManifestCheckRetries, $ManifestCheckDelaySeconds)

# Define default values for parameters not set
if ([string]::IsNullOrEmpty($registry)) {
    $registry = "docker.io"
}

# Iterate around the tags and build up the list of images
$images = @()
foreach ($tag in $Tags) {
    $images += "{0}/{1}:{2}-{3}" -f $registry, $Name, $Version, $tag
}

$loggedIn = $false

try {
# Login to the specified container registry
Write-Host ("Logging into registry: {0}" -f $registry)
if ($Dryrun.IsPresent) {
    Write-Host ("DRYRUN: docker login -u {0} --password-stdin {1}" -f $username, $registry)
}
else {
    $password | docker login -u $username --password-stdin $registry

    if ($LASTEXITCODE -ne 0) {
        throw ("docker login failed for registry: {0}" -f $registry)
    }

    $loggedIn = $true
}
if (-not $Dryrun.IsPresent) {
    foreach ($image in $images) {
        Wait-ForDockerManifest -Image $image -Retries $ManifestCheckRetries -DelaySeconds $ManifestCheckDelaySeconds
    }
}
else {
    Write-Host "Skipping manifest-availability checks in dry-run mode"
}

Invoke-DockerCommand -Command "docker manifest create `"${registry}/${Name}:${Version}`" $($images -join " ")" -Dryrun:$Dryrun

# Now push the manifest to the registry
Invoke-DockerCommand -Command "docker manifest push `"${registry}/${Name}:${Version}`"" -Dryrun:$Dryrun

if ($Latest.IsPresent) {
    # Tag manifest with the latest tag
    Invoke-DockerCommand -Command "docker manifest create `"${registry}/${Name}:latest`" $($images -join " ")" -Dryrun:$Dryrun

    Invoke-DockerCommand -Command "docker manifest push `"${registry}/${Name}:latest`"" -Dryrun:$Dryrun
}
} finally {
    $manifestOperationExitCode = $global:LASTEXITCODE

    if ($loggedIn) {
        try {
            $null = (& docker logout $registry 2>&1 | Out-String)

            if ($LASTEXITCODE -ne 0) {
                Write-Warning ("docker logout failed for registry: {0}" -f $registry)
            }
        }
        catch {
            Write-Warning ("docker logout raised an error for registry: {0}" -f $registry)
        }
    }

    $global:LASTEXITCODE = $manifestOperationExitCode

    $ErrorActionPreference = $previousErrorActionPreference
}
