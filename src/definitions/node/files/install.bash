#!/bin/bash

set -euxo pipefail

mkdir "${NVM_ROOT}"
export NVM_DIR="${NVM_ROOT}"

# Download and install the specified version of NVM
curl --fail-with-body -L https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh -o /tmp/nvm_install
chmod +x /tmp/nvm_install
/tmp/nvm_install
rm /tmp/nvm_install

# Activate NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Iterate around the versions of Node required
versions=$(echo ${NODE_VERSIONS} | tr "," "\n")

for node_version in $versions
do
    nvm install $node_version
done

chmod -R a+w "${NVM_ROOT}"

# Set the latest version of node as the default
nvm alias default node
