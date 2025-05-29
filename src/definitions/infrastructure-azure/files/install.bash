#!/bin/bash

# Ensure TENV directory is writable to prevent warnings about writing to the 'last-use.txt'
chmod -R a+w /usr/local/tenv/.tenv

# Install necessary pip packages
pip3 install -r /tmp/requirements.txt