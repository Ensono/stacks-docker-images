#!/bin/bash

POWERSHELL_VERSION=$1

# Get the ARCH of the enviornment
ARCH="$(uname -m)"
if [[ ${ARCH} == "x86_64" ]];
then
    ARCH="amd64"
elif [[ ${ARCH} == "aarch64" ]];
then
    ARCH="arm64"
fi

# Download the PowerShell install file
URL="https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.deb_${ARCH}.deb"
echo "Downloading: ${URL}"
curl -L $URL -o /tmp/powershell.deb && \

# Install the package
dpkg -i /tmp/powershell.deb

# Install any missing dependencies
apt-get install -y -f

# Remove the package
rm /tmp/powershell.deb
