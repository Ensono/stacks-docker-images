#!/bin/bash

# Download and install the specified version of NVM
curl -L -o /tmp/nvm_install https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh 
chmod +x /tmp/nvm_install
/tmp/nvm_install

# Activate NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Iterate around the versions of Node required
versions=$(echo ${NODE_VERSIONS} | tr "," "\n")

for node_version in $versions
do
    nvm install $node_version
done

# Set the latest version of node as the default
nvm alias default node
