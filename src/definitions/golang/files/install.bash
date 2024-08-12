#!/bin/bash

set -euxo pipefail

# Determine the architecture of the image
. /usr/local/bin/platform.bash

# Update APT and install nessary packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl
unlink /etc/localtime
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Download the specified version of GO
curl --fail-with-body -L https://go.dev/dl/go${GOLANG_VERSION}.linux-${BIN_ARCH}.tar.gz -o /tmp/golang.tar.gz
tar zxf /tmp/golang.tar.gz -C /usr/local

# Remove downloaded
rm -rf /tmp/*

# Install the necssary pacakges to run unitests for Stacks projects
/usr/local/go/bin/go install github.com/jstemmer/go-junit-report@latest
/usr/local/go/bin/go install github.com/t-yuki/gocover-cobertura@latest
/usr/local/go/bin/go install github.com/axw/gocov/gocov@latest
/usr/local/go/bin/go install github.com/AlekSi/gocov-xml@latest
