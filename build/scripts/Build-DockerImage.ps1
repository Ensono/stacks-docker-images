
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
    # State that the script would run in dryrun and not to execute any commands
    $dryrun
)

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
$buildArgs = @("build", ($tags -join " "))

if (![string]::IsNullOrEmpty($arguments)) {
    $buildArgs += $arguments
}

# Build and push the image
Write-Host ("Building docker image: {0}" -f ($platform -join ","))
Invoke-External -Command "docker build $($args -join " ")" -Dryrun:$dryrun

Write-Host ("Push docker image: {0}" -f $image_name)
Invoke-External -Command "docker push ${image_name}" -Dryrun:$dryrun

# Push the readme if the registry is docker.io
if ($registry -ieq "docker.io") {

    # get the path to the readme file from the args that have been set
    $status = $arguments -match '-f\s\./([a-zA-Z/\.-]*)/Dockerfile\.ubuntu'
    if ($status) {

        $path_parts = $Matches[1] -split "/"
        $readme_path = [IO.Path]::Combine([IO.Path]::Combine($path_parts), "README.md")

        Write-Host ("Pushing README file: {0}" -f $readme_path)
        Invoke-External -Command "docker pushrm --provider dockerhub ${registry}/${name} --file ${readme_path}" -Dryrun:$dryrun
    }
}
