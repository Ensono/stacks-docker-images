[CmdletBinding()]
param (
    [string]
    $registry = $env:DOCKER_CONTAINER_REGISTRY_NAME,

    [string]
    $name = $env:DOCKER_IMAGE_NAME,

    [string]
    $tag = $env:DOCKER_IMAGE_TAG,

    [ValidateSet("amd64", "arm64")]
    [string]
    $arch
)

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

function Invoke-DockerCleanupCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]
        $Arguments,

        [switch]
        $IgnoreExitCode,

        [string]
        $Description = ($Arguments -join " ")
    )

    Write-Host ("> docker {0}" -f ($Arguments -join " "))
    & docker @Arguments

    if ($LASTEXITCODE -ne 0 -and -not $IgnoreExitCode.IsPresent) {
        throw ("Docker cleanup command failed with exit code {0}: {1}" -f $LASTEXITCODE, $Description)
    }
}

try {
    Write-Host "Docker disk usage before cleanup:"
    Invoke-DockerCleanupCommand -Arguments @("system", "df") -IgnoreExitCode -Description "docker system df"

    if (-not [string]::IsNullOrWhiteSpace($registry) -and -not [string]::IsNullOrWhiteSpace($name) -and -not [string]::IsNullOrWhiteSpace($tag) -and -not [string]::IsNullOrWhiteSpace($arch)) {
        $imageName = "{0}/{1}:{2}-{3}" -f $registry, $name, $tag, $arch
        Write-Host ("Removing job image if present: {0}" -f $imageName)
        Invoke-DockerCleanupCommand -Arguments @("image", "rm", "-f", $imageName) -IgnoreExitCode -Description "docker image rm -f $imageName"
    }
    else {
        Write-Host "Skipping targeted image removal because image metadata is incomplete."
    }

    Invoke-DockerCleanupCommand -Arguments @("container", "prune", "--force") -IgnoreExitCode -Description "docker container prune --force"
    Invoke-DockerCleanupCommand -Arguments @("image", "prune", "--all", "--force") -Description "docker image prune --all --force"
    Invoke-DockerCleanupCommand -Arguments @("builder", "prune", "--all", "--force") -Description "docker builder prune --all --force"

    Write-Host "Docker disk usage after cleanup:"
    Invoke-DockerCleanupCommand -Arguments @("system", "df") -IgnoreExitCode -Description "docker system df"
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}
