
[CmdletBinding()]
param (

    [ValidateSet("linux/amd64", "linux/arm64")]
    [string[]]
    # Platforms that the image should be built for
    $platform = @("linux/amd64"),

    [string]
    # Container registry
    $registry = $env:DOCKER_CONTAINER_REGISTRY_NAME,

    [string]
    # Name of the image
    $name,

    [string]
    # Tag to assign to the image
    $tag,

    [string]
    # Additional arguments to pass to the build command
    $arguments,

    [string]
    # Username to login to the specified registry
    $username = $env:DOCKER_USERNAME,

    [String]
    # Associated password with the Docker username
    $password = $env:DOCKER_PASSWORD,

    [switch]
    # State that the script would run in dryrun and not to execute any commands
    $dryrun,

    [ValidateRange(1, [int]::MaxValue)]
    [int]
    # Number of times to verify image exists in registry after push
    $PushVerifyRetries = 5,

    [ValidateRange(0, [int]::MaxValue)]
    [int]
    # Delay in seconds between push verification attempts
    $PushVerifyDelaySeconds = 10
)

. (Join-Path $PSScriptRoot "RegistryManifestTools.ps1")

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

function Wait-ForDockerImagePush {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Image,

        [Parameter(Mandatory = $true)]
        [int]
        $Retries,

        [Parameter(Mandatory = $true)]
        [int]
        $DelaySeconds,

        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
    )

    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        $checkResult = Test-RegistryManifestAvailability -Image $Image -Username $Username -Password $Password

        if ($checkResult.Available) {
            Write-Host ("Verified image exists in registry via {0}: {1}" -f $checkResult.Probe, $Image)
            return
        }

        if ($attempt -eq $Retries) {
            throw ("Image was not found in registry after push ({0} attempts via {1}): {2}. Last detail: {3}" -f $Retries, $checkResult.Probe, $Image, $checkResult.Detail)
        }

        Write-Host ("Verifying image push ({0}/{1}) via {2}: {3}" -f $attempt, $Retries, $checkResult.Probe, $Image)
        Start-Sleep -Seconds $DelaySeconds
    }
}

$loggedIn = $false

try {
    # Enable experimental builds
    $env:DOCKER_CLI_AKV2_EXPERIMENTAL="enabled"

    # Determine the arch based on the platform info
    switch ($platform) {
        "linux/amd64" {
            $arch = "amd64"
        }
        "linux/arm64" {
            $arch = "arm64"
        }
        default {
            throw ("Unsupported platform '{0}'. Supported values are linux/amd64 and linux/arm64." -f $platform)
        }
    }

    # Define default values for parameters not set
    if ([string]::IsNullOrEmpty($registry)) {
        $registry = "docker.io"
    }

    # Create a list of the tags that are required
    $tags = @()
    # $tags += (" -t {0}/{1}:latest" -f $registry, $name)

    $image_name = "{0}/{1}:{2}-{3}" -f $registry, $name, $tag, $arch

    # Login to the specified container registry
    Write-Host ("Logging into registry: {0}" -f $registry)
    Invoke-DockerRegistryLogin -Registry $registry -Username $username -Password $password -Dryrun:$dryrun
    $loggedIn = -not $dryrun.IsPresent

    if (![string]::IsNullOrEmpty($tag)) {
        $tags += ("-t {0}" -f $image_name)
    }

    # Build up the arguments for the full command
    $buildArgs = @(($tags -join " "))

    if (![string]::IsNullOrEmpty($arguments)) {
        $buildArgs += $arguments
    }

    # Build and push the image
    Write-Host ("Building docker image: {0}" -f ($platform -join ","))
    Write-Host "docker build $($buildArgs -join " ")"
    Invoke-DockerCommand -Command "docker build $($buildArgs -join " ")" -Dryrun:$dryrun

    # Verify the image was built locally before attempting push
    if (-not $dryrun.IsPresent) {
        & docker image inspect $image_name *> $null
        if ($LASTEXITCODE -ne 0) {
            throw ("Docker build failed: image not found locally: {0}" -f $image_name)
        }
        Write-Host ("Verified image built locally: {0}" -f $image_name)
    }

    Write-Host ("Push docker image: {0}" -f $image_name)
    Invoke-DockerCommand -Command "docker push ${image_name}" -Dryrun:$dryrun

    # Verify the image exists in the registry after push
    if (-not $dryrun.IsPresent) {
        Wait-ForDockerImagePush -Image $image_name -Retries $PushVerifyRetries -DelaySeconds $PushVerifyDelaySeconds -Username $username -Password $password

        # Release local image immediately after a verified push to keep agent disk usage low.
        Invoke-DockerCommand -Command "docker image rm -f ${image_name}" -Dryrun:$dryrun
    }
}
finally {
    if ($loggedIn) {
        Invoke-DockerRegistryLogout -Registry $registry
    }

    $ErrorActionPreference = $previousErrorActionPreference
}
