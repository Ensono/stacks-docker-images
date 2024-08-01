#!/bin/bash

# Update Apt and install the necessary tools
apt-get update
apt-get install -y build-essential ruby ruby-dev

# Prevent documents being installed for Gems
echo "gem: --no-document" > /etc/gemrc

# Install a specific version of ruby
gem install etc bigdecimal io-console
gem install inspec-bin -v ${INSPEC_VERSION}

# Remove unncessary tools
apt-get remove -y build-essential ruby-dev
apt-get autoremove -y
