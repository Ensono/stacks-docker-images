#!/bin/bash

# Download and install the specified version of NVM
curl -L -o /tmp/nvm_install https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh 

# Iterate around the versions of Node required
versions=$(echo ${NODE_VERSIONS} | tr "," "\n")

for node_version in $versions
do
    nvm install $node_version
done

# Set the latest version of node as the default
nvm alias default node
