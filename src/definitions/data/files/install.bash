#!/bin/bash

set -euxo pipefail

# Install Python and pip
apt-get update
apt-get install -y \
    python3-pip \
    gpg

# Install the AZ CLI datafactory extenstion
az extension add --name datafactory

# Install the necessary python extension
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv
python3 -m venv /opt/venv
/opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

rm -r /tmp/requirements.txt
