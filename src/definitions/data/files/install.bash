#!/bin/bash

# Install Python and pip
apt-get update
apt-get install -y \
    python3-pip \
    gpg

# Install the AZ CLI datafactory extenstion
az extension add --name datafactory

# Install the necessary python extension
pip3 install -r /tmp/requirements.txt

rm -r /tmp/requirements.txt
