#!/bin/bash

# Get the ARCH of the enviornment
export PROPER_ARCH="$(uname -m)"
if [ "$PROPER_ARCH" = "x86_64" ]
then 
    export ARCH="amd64"
elif [ "$PROPER_ARCH" = "aarch64" ]
then 
    export ARCH="arm64"
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

# Taskctl Runner ------------------------------------------------------------
mkdir -p /usr/local/taskctl/bin && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://github.com/russellseymour/taskctl/releases/download/v${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/taskctl.tar.gz && \
    tar zxf /tmp/taskctl.tar.gz -C /usr/local/taskctl/bin taskctl && \
    rm -f /tmp/taskctl.tar.gz && \
    chmod +x /usr/local/taskctl/bin/taskctl
# ---------------------------------------------------------------------------

# Independent Runner module *************************************************
mkdir -p /modules/EnsonoBuild && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psd1" -o /modules/EnsonoBuild/EnsonoBuild.psd1 && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psm1" -o /modules/EnsonoBuild/EnsonoBuild.psm1
# ***************************************************************************