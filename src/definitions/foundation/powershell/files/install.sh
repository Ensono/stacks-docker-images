#!/bin/bash

# Get the ARCH of the enviornment
export PROPER_ARCH="$(uname -m)"
if [ "$PROPER_ARCH" = "x86_64" ]
then 
    export ARCH="amd64"
    export PWSH_ARCH="x64"
elif [ "$PROPER_ARCH" = "aarch64" ]
then 
    export ARCH="arm64"
    export PWSH_ARCH="arm64"
fi

# Install dependencies for PowerShell
apt-get install -y libc6 libgcc-s1 libicu70 libssl3 libstdc++6 libunwind8 zlib1g

# Download the PowerShell binary for the platform
URL="https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-${PWSH_ARCH}.tar.gz"
echo "Downloading: ${URL}"
curl -L $URL -o /tmp/powershell.tar.gz

mkdir -p /opt/microsoft/powershell/7
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Remove the package
# rm /tmp/powershell.tar.gz

# Taskctl Runner ------------------------------------------------------------
mkdir -p /usr/local/taskctl/bin && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://github.com/Ensono/taskctl/releases/download/v${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/taskctl.tar.gz && \
    tar zxf /tmp/taskctl.tar.gz -C /usr/local/taskctl/bin taskctl && \
    rm -f /tmp/taskctl.tar.gz && \
    chmod +x /usr/local/taskctl/bin/taskctl
# ---------------------------------------------------------------------------

# Independent Runner module *************************************************
mkdir -p /modules/EnsonoBuild && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psd1" -o /modules/EnsonoBuild/EnsonoBuild.psd1 && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/v${ENSONOBUILD_VERSION}/EnsonoBuild.psm1" -o /modules/EnsonoBuild/EnsonoBuild.psm1
# ***************************************************************************