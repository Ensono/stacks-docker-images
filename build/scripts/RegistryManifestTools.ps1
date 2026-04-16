function Get-ContainerImageReferenceParts {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Image
    )

    $separatorIndex = $Image.IndexOf("/")
    if ($separatorIndex -lt 0) {
        throw ("Image reference must include a registry and repository: {0}" -f $Image)
    }

    $registry = $Image.Substring(0, $separatorIndex)
    $remainder = $Image.Substring($separatorIndex + 1)

    $digestSeparatorIndex = $remainder.IndexOf("@")
    if ($digestSeparatorIndex -ge 0) {
        return [pscustomobject]@{
            Registry      = $registry
            Repository    = $remainder.Substring(0, $digestSeparatorIndex)
            Reference     = $remainder.Substring($digestSeparatorIndex + 1)
            ReferenceKind = "digest"
        }
    }

    $tagSeparatorIndex = $remainder.LastIndexOf(":")
    if ($tagSeparatorIndex -lt 0) {
        throw ("Image reference must include a tag or digest: {0}" -f $Image)
    }

    return [pscustomobject]@{
        Registry      = $registry
        Repository    = $remainder.Substring(0, $tagSeparatorIndex)
        Reference     = $remainder.Substring($tagSeparatorIndex + 1)
        ReferenceKind = "tag"
    }
}

function Test-AcrImageAvailability {
    param (
        [Parameter(Mandatory = $true)]
        [pscustomobject]
        $ImageParts,

        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
    )

    $acrImage = if ($ImageParts.ReferenceKind -eq "digest") {
        "{0}@{1}" -f $ImageParts.Repository, $ImageParts.Reference
    }
    else {
        "{0}:{1}" -f $ImageParts.Repository, $ImageParts.Reference
    }

    $fullImageReference = "{0}/{1}" -f $ImageParts.Registry, $acrImage

    $loginOutput = ($Password | & docker login $ImageParts.Registry --username $Username --password-stdin 2>&1 | Out-String).Trim()
    $loginExitCode = $LASTEXITCODE

    if ($loginExitCode -ne 0) {
        if ([string]::IsNullOrWhiteSpace($loginOutput)) {
            $loginOutput = "docker login exited with code {0}" -f $loginExitCode
        }

        throw ("Failed to authenticate to ACR '{0}': {1}" -f $ImageParts.Registry, $loginOutput)
    }

    $commandOutput = (& docker manifest inspect $fullImageReference 2>&1 | Out-String).Trim()
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        return [pscustomobject]@{
            Available = $true
            Probe     = "docker manifest inspect"
            Reason    = "Available"
            Detail    = "Resolved image reference in ACR"
        }
    }

    if ($commandOutput -match "(?i)unauthorized|authentication|authorization|denied|requested access to the resource is denied|no basic auth credentials") {
        throw ("Failed to query ACR for '{0}': {1}" -f $acrImage, $commandOutput)
    }

    $reason = "Transient"
    if ($commandOutput -match "(?i)manifest.*unknown|not found|does not exist|name_unknown|repository.*not found|no such manifest") {
        $reason = "NotFound"
    }

    if ([string]::IsNullOrWhiteSpace($commandOutput)) {
        $commandOutput = "docker manifest inspect exited with code {0}" -f $exitCode
    }

    return [pscustomobject]@{
        Available = $false
        Probe     = "docker manifest inspect"
        Reason    = $reason
        Detail    = $commandOutput
    }
}

function Test-DockerManifestAvailability {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Image
    )

    $commandOutput = (& docker manifest inspect $Image 2>&1 | Out-String).Trim()
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        return [pscustomobject]@{
            Available = $true
            Probe     = "docker manifest inspect"
            Reason    = "Available"
            Detail    = "Resolved image reference with docker"
        }
    }

    if ($commandOutput -match "(?i)unauthorized|authentication|authorization|denied") {
        throw ("Failed to query registry for '{0}': {1}" -f $Image, $commandOutput)
    }

    $reason = "Transient"
    if ($commandOutput -match "(?i)manifest.*unknown|no such manifest|not found|name_unknown") {
        $reason = "NotFound"
    }

    if ([string]::IsNullOrWhiteSpace($commandOutput)) {
        $commandOutput = "docker manifest inspect exited with code {0}" -f $exitCode
    }

    return [pscustomobject]@{
        Available = $false
        Probe     = "docker manifest inspect"
        Reason    = $reason
        Detail    = $commandOutput
    }
}

function Test-RegistryManifestAvailability {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Image,

        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
    )

    $imageParts = Get-ContainerImageReferenceParts -Image $Image

    if ($imageParts.Registry -like "*.azurecr.io") {
        return Test-AcrImageAvailability -ImageParts $imageParts -Username $Username -Password $Password
    }

    return Test-DockerManifestAvailability -Image $Image
}
