#!/bin/bash

set -euxo pipefail

# Configure the system to use the apt-cacher-ng container
# echo "Acquire::http::Proxy \"http://127.0.0.1:3142\";" > /etc/apt/apt.conf.d/00aptproxy

# Get the ARCH of the enviornment
. /usr/local/bin/platform.bash

# Install necessary packages
apt-get update
apt-get install -y \
    build-essential \
    cmake \
    bison \
    flex \
    pkg-config \
    libglib2.0-dev \
    graphviz \
    ruby \
    rubygems \
    ruby-dev \
    python3-pip \
    libfreetype-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-dev \
    libxml2-dev \
    libwebp-dev \
    libzstd-dev \
    libpng-dev \
    zlib1g-dev \
    libmagickwand-dev \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libasound2

# Install python packages
pip install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    seqdiag \
    pillow==9.5.0

echo "gem: --no-document" > /etc/gemrc

# Install ruby gems
gem install \
    "asciidoctor:${ASCIIDOCTOR_VERSION}" \
    "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
    "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
    "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
    "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
    "asciidoctor-fb2:${ASCIIDOCTOR_FB2_VERSION}" \
    "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
    "asciidoctor-chart:${ASCIIDOCTOR_CHART_VERSION}" \
    asciimath \
    "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
    coderay \
    epubcheck-ruby:4.2.4.0 \
    haml \
    "kramdown-asciidoc:${ASCIIDOCTOR_KRAMDOWN_VERSION}" \
    pygments.rb \
    rouge \
    slim \
    thread_safe \
    tilt \
    text-hyphen \
    "asciidoctor-bibtex:${ASCIIDOCTOR_BIBTEX_VERSION}" \
    "asciidoctor-kroki:${ASCIIDOCTOR_KROKI_VERSION}" \
    "asciidoctor-reducer:${ASCIIDOCTOR_REDUCER_VERSION}" \
    barby \
    rqrcode \
    prawn-icon \
    bigdecimal \
    rmagick

# Install mermaid-cli using node
export PATH="${PATH}:/usr/local/node/bin"
/usr/local/node/bin/npm install -g @mermaid-js/mermaid-cli

# Remove obsolete packages
apt-get remove -y build-essential
apt-get autoremove -y
apt-get clean

# Update the arch to fit in with the pattern for the erd binary
if [ "${BIN_ARCH}" == "arm64" ]; then
    ERD_ARCH="arm"
else
    ERD_ARCH="${BIN_ARCH}"
fi

# Install ERD binary
curl --fail-with-body -L "https://github.com/kaishuu0123/erd-go/releases/download/v${ERD_VERSION}/linux_${ERD_ARCH}_erd-go" -o /usr/local/bin/erd
chmod +x /usr/local/bin/erd

# Install the Pandoc command
mkdir -p /usr/local/pandoc/bin
curl --fail-with-body -L "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${BIN_ARCH}.tar.gz" -o /tmp/pandoc.tar.gz
pushd /tmp
tar zxf /tmp/pandoc.tar.gz
mv pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/pandoc/bin
popd

# Ensure the wrapper script is executable
chmod +x /usr/local/bin/mermaid

# Remove files
rm -rf /tmp/*
