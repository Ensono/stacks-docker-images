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

function Get-AcrRegistryName {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Registry
    )

    if ($Registry -notlike "*.azurecr.io") {
        throw ("Registry is not an Azure Container Registry login server: {0}" -f $Registry)
    }

    return $Registry.Substring(0, $Registry.IndexOf(".azurecr.io"))
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

    $acrName = Get-AcrRegistryName -Registry $ImageParts.Registry
    $acrImage = if ($ImageParts.ReferenceKind -eq "digest") {
        "{0}@{1}" -f $ImageParts.Repository, $ImageParts.Reference
    }
    else {
        "{0}:{1}" -f $ImageParts.Repository, $ImageParts.Reference
    }

    $commandOutput = (& az acr repository show --name $acrName --image $acrImage --username $Username --password $Password --output none --only-show-errors 2>&1 | Out-String).Trim()
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        return [pscustomobject]@{
            Available = $true
            Probe     = "az acr repository show"
            Reason    = "Available"
            Detail    = "Resolved image reference in ACR"
        }
    }

    if ($commandOutput -match "(?i)unauthorized|authentication|authorization|denied") {
        throw ("Failed to query ACR for '{0}': {1}" -f $acrImage, $commandOutput)
    }

    $reason = "Transient"
    if ($commandOutput -match "(?i)manifest.*unknown|not found|does not exist|name_unknown|repository.*not found") {
        $reason = "NotFound"
    }

    if ([string]::IsNullOrWhiteSpace($commandOutput)) {
        $commandOutput = "Azure CLI exited with code {0}" -f $exitCode
    }

    return [pscustomobject]@{
        Available = $false
        Probe     = "az acr repository show"
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
    $azCommand = Get-Command -Name az -ErrorAction SilentlyContinue

    if ($imageParts.Registry -like "*.azurecr.io" -and $null -ne $azCommand) {
        return Test-AcrImageAvailability -ImageParts $imageParts -Username $Username -Password $Password
    }

    if ($imageParts.Registry -like "*.azurecr.io" -and $null -eq $azCommand) {
        Write-Host ("Azure CLI is not available; falling back to docker manifest inspection for {0}" -f $Image)
    }

    return Test-DockerManifestAvailability -Image $Image
}
