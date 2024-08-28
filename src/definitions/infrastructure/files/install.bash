#!/bin/bash

# Script to install python and the cloud CLI tools

# Get the architecture of the container
. /usr/local/bin/platform.bash

# Install necessary linux packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl apt-transport-https lsb-release gnupg python3-pip
unlink /etc/localtime
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# Install AWS CLI
curl --fail-with-body -L "https://awscli.amazonaws.com/awscli-exe-linux-${UNAME_ARCH}-${AWS_CLI_VERSION}.zip" -o /tmp/awscliv2.zip
cd /tmp
unzip awscliv2.zip
./aws/install

# Install necessary pip packages
pip3 install -r /tmp/requirements.txt

rm /tmp/requirements.txt

# Ensure TENV directory is writable to prevent warnings about writing to the 'last-use.txt'
chmod -R a+w /usr/local/tenv/.tenv
