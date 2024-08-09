#!/bin/bash

set -euxo pipefail

# Script to detect the Architecture of the platform and set appropriate variables
# for us in other scripts.

# This is used extensively for installing applications in Docker images. As the images
# are now multi-platform the correct platform must be downloaded and installed.
#
# The script will export 3 variables
#   - UNAME_ARCH - architecture as reported by the uname command
#   - ABBR_ARCH - abbreviated architecture
#   - BIN_ARCH - archiecture to be used when downloading applications
#   - MUSL_ARCH - architecture when running with MUSL

# Detect MUSL
MUSL="$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)"

# Get the distcodename of the platform
export AZ_DIST=$(lsb_release -cs)

# Get the archiecture of the platform based on the `uname -m` command
# This is known as the UNAME_ARCH
export UNAME_ARCH="$(uname -m)"

# Set the ARCH to be used when downloading applications
if [ "$UNAME_ARCH" == "x86_64" ]
then
    export BIN_ARCH="amd64"
    export ABBR_ARCH="x64"

    # if MUSL has been detected, set the appropriate arch
    if [[ -n ${MUSL} ]]
    then
        export MUSL_ARCH="musl-x64"
    else
        export MUSL_ARCH="x64"
    fi
else
    export BIN_ARCH="arm64"
    export MUSL_ARCH=$BIN_ARCH
    export ABBR_ARCH=$BIN_ARCH
fi

echo "PLATFORM DETECTION =================================="
echo "Uname:             ${UNAME_ARCH} (UNAME_ARCH)"
echo "Binary arch:       ${BIN_ARCH}   (BIN_ARCH)"
echo "Abbreviated arch:  ${ABBR_ARCH}  (ABBR_ARCH)"
echo "Musl Arch:         ${MUSL_ARCH}  (MUSL_ARCH)"
echo "OS Distribution:   ${AZ_DIST}    (AZ_DIST)"
echo "====================================================="
