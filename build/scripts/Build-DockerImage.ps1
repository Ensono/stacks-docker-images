
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
    $tag = ${env:DOCKER_IMAGE_TAG},

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
    # State that the scritp whould run in dryrun and not to execute any commands
    $dryrun
)

# Enable experimental builds
$env:DOCKER_CLI_AKV2_EXPERIMENTAL="enabled"

# Define default values for parameters not set
if ([string]::IsNullOrEmpty($registry)) {
    $registry = "docker.io"
}

# Create a list of the tags that are required
$tags = @(
    (" -t {0}/{1}:latest" -f $registry, $name)
)

if (![string]::IsNullOrEmpty($tag)) {
    $tags += ("-t {0}/{1}:{2}" -f $registry, $name, $tag)
}

# Build up the arguments for the full command
$args = @(
    "--platform",
    ($platform -join ","),
    ($tags -join " "),
    "--push"
)

if (![string]::IsNullOrEmpty($arguments)) {
    $args += $arguments
}

# Login to the specified container registry
Write-Host ("Logging into registry: {0}" -f $registry)
$cmd = "docker login -u {0} -p {1} {2}" -f $username, $password, $registry

if ($dryrun.IsPresent) {
    Write-Host $cmd
} else {
    Invoke-Expression $cmd
}

# Create a new buildx driver to
Write-Host "Creating new buildx profile"
$cmd = "docker buildx create --use"

if ($dryrun.IsPresent) {
    Write-Host $cmd
} else {
    Invoke-Expression $cmd
}

# Build and push the image
Write-Host ("Building docker image: {0}" -f ($platform -join ","))
$cmd = "docker buildx build {0}" -f ($args -join " ")

if ($dryrun.IsPresent) {
    Write-Host $cmd
} else {
    Invoke-Expression $cmd
}
