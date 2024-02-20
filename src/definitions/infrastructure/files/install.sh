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

# Install necessary linux packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl apt-transport-https lsb-release gnupg
unlink /etc/localtime
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# Install AWS CLI
curl -L "https://awscli.amazonaws.com/awscli-exe-linux-${PROPER_ARCH}-${AWS_CLI_VERSION}.zip" -o /tmp/awscliv2.zip
cd /tmp
unzip awscliv2.zip
./aws/install
