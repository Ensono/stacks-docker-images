#!/bin/bash

# Get the ARCH of the enviornment
. /usr/local/bin/platform.bash

# Install the necessary documentation

# Docker --------------------------------------------------------------------
echo "Installing: Docker"
mkdir -p /usr/local/docker/bin
URL="https://download.docker.com/linux/static/stable/${UNAME_ARCH}/docker-${DOCKER_VERSION}.tgz"
echo $URL
curl --fail-with-body -L $URL --insecure -o /tmp/docker.tgz
tar zxf /tmp/docker.tgz -C /tmp
mv /tmp/docker/* /usr/local/docker/bin
# ---------------------------------------------------------------------------

# Docker Buildx -------------------------------------------------------------
# Used to extend Docker so that builds for other platforms can be created
echo "Installing: Docker Buildx"
mkdir -p /usr/libexec/docker/cli-plugins
curl --fail-with-body -L "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${BIN_ARCH}" -o /usr/libexec/docker/cli-plugins/docker-buildx
chmod +x /usr/libexec/docker/cli-plugins/docker-buildx
# ---------------------------------------------------------------------------

# Clean Up ******************************************************************
# Remove everything from the temp directory
rm -rf /tmp/*
# ***************************************************************************
