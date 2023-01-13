FROM golang:1.20rc3

ARG POWERSHELL_VERSION=7.2.6
ARG AMIDOBUILD=v0.0.188

COPY files/unittests.sh /usr/local/bin

RUN go install github.com/jstemmer/go-junit-report@latest && \
    go install github.com/t-yuki/gocover-cobertura@latest && \
    go install github.com/axw/gocov/gocov@latest && \
    go install github.com/AlekSi/gocov-xml@latest && \
    chmod +x /usr/local/bin/unittests.sh
    
RUN apt-get update && \
    apt-get install -y libicu67 \
    curl

# Install PowerShell
RUN apt-get update && \
    apt-get install -y libicu67 && \
    curl -L "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-lts_${POWERSHELL_VERSION}-1.deb_amd64.deb" -o /tmp/powershell.deb && \
    dpkg -i /tmp/powershell.deb && \
    rm /tmp/powershell.deb 

# Install the AmidoBuild module
RUN mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1

# Remove uncessary packages
RUN apt-get -y remove curl && \
    apt-get -y autoremove

