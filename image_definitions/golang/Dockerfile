FROM golang:1

ARG POWERSHELL_VERSION=7.2.1

COPY files/unittests.sh /usr/local/bin

RUN go get github.com/jstemmer/go-junit-report && \
    go get github.com/t-yuki/gocover-cobertura && \
    go get github.com/axw/gocov/gocov && \
    go get github.com/AlekSi/gocov-xml && \
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

# Remove uncessary packages
RUN apt-get -y remove curl && \
    apt-get -y autoremove
