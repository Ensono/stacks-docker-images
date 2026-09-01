#!/bin/bash

# Ensure TENV directory is writable to prevent warnings about writing to the 'last-use.txt'
chmod -R a+w /usr/local/tenv/.tenv

# Install Python tools in an isolated virtual environment.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv
python3 -m venv /opt/venv
/opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt