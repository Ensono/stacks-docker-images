# Copy PowerShell from the relevant powershell image
FROM mcr.microsoft.com/powershell:7.2-ubuntu-20.04 as posh

FROM ubuntu:20.04

ARG AMIDOBUILD=v0.0.196
ARG INSPEC_VERSION=4.3.2

RUN apt-get update && \
    apt-get install -y curl libicu-dev

# Install the AmidoBuild module
RUN echo "Downloading AmidoBuild version - ${AMIDBUILD}" && \
    mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1

COPY --from=posh /opt/microsoft/powershell/7 /opt/microsoft/powershell/7
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# -- Inspec for infrastructure testing
RUN curl "https://omnitruck.chef.io/install.sh" -o "install.sh" && \
    chmod +x ./install.sh && \
    ./install.sh -P inspec -v ${INSPEC_VERSION} && \
    rm install.sh



