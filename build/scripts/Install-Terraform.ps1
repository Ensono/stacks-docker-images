[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]
	# The version of Terraform to install
	$Version
)

$ErrorActionPreference = 'Stop'

# Detect architecture and map to Terraform's naming convention
$arch = (uname -m).Trim()
$tfArch = switch ($arch) {
    "x86_64"  { "amd64" }
    "aarch64" { "arm64" }
    default   { throw "Unsupported architecture: $arch" }
}

$baseFile = "terraform_${Version}"
$baseURL = "https://releases.hashicorp.com/terraform/${Version}/${baseFile}"
$baseTmp = "/tmp/terraform-download"

$hashicorpKeys = "${baseTmp}/hashicorp_pgp_keys.asc"
$terraformZip = "${baseTmp}/${baseFile}_linux_${tfArch}.zip"
$terraformSums = "${baseTmp}/${baseFile}_SHA256SUMS"
$terraformSig = "${baseTmp}/${baseFile}_SHA256SUMS.sig"

function Remove-FileIfExists(
	[Parameter(Mandatory=$true)]
	[string]
	$File
)
{
	if (Test-Path -Path ${File})
	{
		Remove-Item `
			-Path ${File} `
			-Force
	}
}

New-Item `
	-Path ${baseTmp} `
	-Type Directory `
	-Force

Remove-FileIfExists -File ${hashicorpKeys}
Remove-FileIfExists -File ${terraformZip}
Remove-FileIfExists -File ${terraformSums}
Remove-FileIfExists -File ${terraformSig}

# Download Hasicorp Public Key and install it
Write-Host "INFO: Downloading the Terraform Public Key"
Invoke-WebRequest `
	-Uri https://keybase.io/hashicorp/pgp_keys.asc `
	-OutFile ${hashicorpKeys}

Write-Host "INFO: Importing the Terraform Public Keys"
gpg --import ${hashicorpKeys}

if ($? -eq $false)
{
	Write-Error "ERROR: Couldn't Import the Hashicorp Public Key..!"
}

# Download Checksum and Signature
Write-Host "INFO: Downloading the Terraform SHA Checksums"
Invoke-WebRequest `
	-Uri "${baseUrl}_SHA256SUMS" `
	-OutFile ${terraformSums}

Write-Host "INFO: Downloading the Terraform Signature"
Invoke-WebRequest `
	-Uri "${baseUrl}_SHA256SUMS.sig" `
	-OutFile ${terraformSig}

# Download Terraform
Write-Host "INFO: Downloading the Terraform Binary ZIP"
Invoke-WebRequest `
	-Uri "${baseUrl}_linux_${tfArch}.zip" `
	-OutFile ${terraformZip}

# Verify Checksum and Signature
Write-Host "INFO: GPG verify the Terraform Signature"
gpg --verify ${terraformSig} ${terraformSums}

if ($? -eq $false)
{
	Write-Error "ERROR: Could not verify GPG Signature..."
}

Set-Location -Path ${baseTmp}

# Verify downloaded archive
Write-Host "INFO: Verifying the Terraform SHA Checksum of the Terraform Binary Zip"
sha256sum --check ${terraformSums} --ignore-missing
$exitCode = $?

Set-Location -Path -

if ($exitCode -eq $false)
{
	Write-Error "ERROR: Could not verify SHA Checksum..."
}

Write-Host "INFO: Installing the Terraform Binary"
unzip -o ${terraformZip} terraform -d /usr/local/bin
