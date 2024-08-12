#!/bin/bash

set -euxo pipefail

# Update Apt and install unzup
apt-get update
apt-get install -y unzip

# Install Maven
curl --fail-with-body -L "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip
unzip /tmp/maven.zip -d /usr/local
rm /tmp/maven.zip
