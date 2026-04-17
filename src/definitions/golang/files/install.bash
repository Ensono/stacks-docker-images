#!/bin/bash

set -euxo pipefail

retry_command() {
	local retries="$1"
	local delay_seconds="$2"
	shift 2

	local attempt=1
	while [ "$attempt" -le "$retries" ]
	do
		if "$@"
		then
			return 0
		fi

		if [ "$attempt" -eq "$retries" ]
		then
			return 1
		fi

		echo "Command failed on attempt ${attempt}/${retries}. Retrying in ${delay_seconds}s: $*"
		sleep "$delay_seconds"
		attempt=$((attempt + 1))
	done
}

install_go_tool() {
	local module="$1"

	# Prefer the default Go module resolution first.
	if retry_command 4 5 /usr/local/go/bin/go install "${module}"
	then
		return 0
	fi

	# Fallback for environments where the default module proxy is unavailable.
	retry_command 4 5 env GOPROXY=direct GOSUMDB=off /usr/local/go/bin/go install "${module}"
}

# Determine the architecture of the image
. /usr/local/bin/platform.bash

# Update APT and install necessary packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl ca-certificates
unlink /etc/localtime
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Download the specified version of GO
retry_command 4 5 curl --fail-with-body -L https://go.dev/dl/go${GOLANG_VERSION}.linux-${BIN_ARCH}.tar.gz -o /tmp/golang.tar.gz
tar zxf /tmp/golang.tar.gz -C /usr/local

# Remove downloaded
rm -rf /tmp/*

# Install the necessary packages to run unit tests for Stacks projects
install_go_tool github.com/jstemmer/go-junit-report@latest
install_go_tool github.com/t-yuki/gocover-cobertura@latest
install_go_tool github.com/AlekSi/gocov-xml@latest

# Install gocyclo for code complexity analysis
install_go_tool github.com/fzipp/gocyclo/cmd/gocyclo@latest
