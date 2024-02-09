#!/bin/bash

# Script to install python and the cloud CLI tools

# Get the architecture of the container
export PROPER_ARCH="$(uname -m)"
if [ "$PROPER_ARCH" = "x86_64" ]
then 
    export ARCH="amd64"
elif [ "$PROPER_ARCH" = "aarch64" ]
then 
    export ARCH="arm64"
fi

# Install AWS CLI
curl -L "https://awscli.amazonaws.com/awscli-exe-linux-${PROPER_ARCH}-${AWS_CLI_VERSION}.zip" -o /tmp/awscliv2.zip
cd /tmp
unzip awscliv2.zip
./aws/install

# Install AZ CLI
mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/keyrings/microsoft.gpg > /dev/null
chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" |
    tee /etc/apt/sources.list.d/azure-cli.list

apt-get update
apt-get install azure-cli=${AZURE_CLI_VERSION}-1~${AZ_DIST}
