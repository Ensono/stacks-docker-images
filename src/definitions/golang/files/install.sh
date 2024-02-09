#/bin/bash

# Determine the architecture of the image
export PROPER_ARCH="$(uname -m)"
if [ "$PROPER_ARCH" = "x86_64" ]
then 
    export ARCH="amd64"
elif [ "$PROPER_ARCH" = "aarch64" ]
then 
    export ARCH="arm64"
fi

# Update APT and install nessary packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl
unlink /etc/localtime
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Download the specified version of GO
curl -L https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCH}.tar.gz -o /tmp/golang.tar.gz
tar zxf /tmp/golang.tar.gz -C /usr/local

# Remove downloaded
rm -rf /tmp/*

# Install the necssary pacakges to run unitests for Stacks projects
/usr/local/go/bin/go install github.com/jstemmer/go-junit-report@latest
/usr/local/go/bin/go install github.com/t-yuki/gocover-cobertura@latest
/usr/local/go/bin/go install github.com/axw/gocov/gocov@latest
/usr/local/go/bin/go install github.com/AlekSi/gocov-xml@latest
