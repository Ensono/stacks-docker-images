#!/bin/bash

set -euxo pipefail

# Install dependencies for PowerShell
#
# The dependencies are from running PowerShell when they have not been installed:
#   - Couldn't find a valid ICU package - Please install libicu (https://aka.ms/dotnet-missing-libicu)
apt-get update
apt-get install -y libicu70 lsb-release curl git

# Containers often need this, such as signing Java Packages for publishing
apt-get install -y gpg

# Get the ARCH of the enviornment
. /usr/local/bin/platform.bash

# Download the PowerShell binary for the platform
URL="https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-${ABBR_ARCH}.tar.gz"
echo "Downloading: ${URL}"
curl --fail-with-body -L $URL -o /tmp/powershell.tar.gz

mkdir -p /opt/microsoft/powershell/7
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Remove the package
rm /tmp/powershell.tar.gz

# Taskctl Runner ------------------------------------------------------------
mkdir -p /usr/local/eirctl/bin
curl --fail-with-body -L "https://github.com/Ensono/eirctl/releases/download/${EIRCTL_VERSION}/eirctl-linux-${BIN_ARCH}" -o /usr/local/eirctl/bin/eirctl
chmod +x /usr/local/eirctl/bin/eirctl
# ---------------------------------------------------------------------------

# Independent Runner module *************************************************
mkdir -p /modules/EnsonoBuild
curl --fail-with-body -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psd1" -o /modules/EnsonoBuild/EnsonoBuild.psd1
curl --fail-with-body -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psm1" -o /modules/EnsonoBuild/EnsonoBuild.psm1
# ***************************************************************************
