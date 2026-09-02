#!/bin/bash

set -euxo pipefail

# Get the ARCH of the enviornment
. /usr/local/bin/platform.bash

apt-get update \
    && apt-get install -y --no-install-recommends \
        chromium \
        fonts-noto-color-emoji \
        fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

npm install -g --omit=dev --no-fund --no-audit \
    @asciidoctor/core@4.0.11 asciidoctor asciidoctor-pdf asciidoctor-kroki qrcode-generator@2.0.4 \
    && npm cache clean --force

addgroup --gid 1001 asciidoctor \
    && adduser --disabled-password --ingroup asciidoctor -u 1001 asciidoctor