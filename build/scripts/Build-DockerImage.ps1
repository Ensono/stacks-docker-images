
[CmdletBinding()]
param (

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

$previousErrorActionPreference = $ErrorActionPreference

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
        $DelaySeconds
    )

    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        & docker manifest inspect $Image *> $null

        if ($LASTEXITCODE -eq 0) {
            Write-Host ("Verified image exists in registry: {0}" -f $Image)
            return
        }

        if ($attempt -eq $Retries) {
            & docker manifest inspect $Image
            throw ("Image was not found in registry after push ({0} attempts): {1}" -f $Retries, $Image)
        }

        Write-Host ("Verifying image push ({0}/{1}): {2}" -f $attempt, $Retries, $Image)
        Start-Sleep -Seconds $DelaySeconds
    }
}

try {
    $ErrorActionPreference = "Stop"

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
    Invoke-External -Command "docker login -u ${username} -p ${password} ${registry}" -Dryrun:$dryrun

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
    Invoke-External -Command "docker build $($buildArgs -join " ")" -Dryrun:$dryrun

    # Verify the image was built locally before attempting push
    if (-not $dryrun.IsPresent) {
        & docker image inspect $image_name *> $null
        if ($LASTEXITCODE -ne 0) {
            throw ("Docker build failed: image not found locally: {0}" -f $image_name)
        }
        Write-Host ("Verified image built locally: {0}" -f $image_name)
    }

    Write-Host ("Push docker image: {0}" -f $image_name)
    Invoke-External -Command "docker push ${image_name}" -Dryrun:$dryrun

    # Verify the image exists in the registry after push
    if (-not $dryrun.IsPresent) {
        Wait-ForDockerImagePush -Image $image_name -Retries $PushVerifyRetries -DelaySeconds $PushVerifyDelaySeconds
    }
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}
