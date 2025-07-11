#!/bin/bash

set -euxo pipefail

# Update Apt and install unzip
apt-get update
apt-get install -y unzip

BIN_LOCATION="/usr/local"

# Install Maven
curl --fail-with-body -L "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip
unzip /tmp/maven.zip -d "${BIN_LOCATION}"
rm /tmp/maven.zip

# Install Sonar Scanner CLI
SONAR_DIRECTORY="sonar-scanner-${SONAR_SCANNER_VERSION}"
ZIP_LOCATION="/tmp/${SONAR_DIRECTORY}.zip"
SONAR_BINARY_LOCATION="/${BIN_LOCATION}/${SONAR_DIRECTORY}/bin/sonar-scanner"

curl --fail-with-body -L "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip" -o "${ZIP_LOCATION}"
unzip "${ZIP_LOCATION}" -d "${BIN_LOCATION}"
chmod u+x "${SONAR_BINARY_LOCATION}"
ln -s ${SONAR_BINARY_LOCATION} "${BIN_LOCATION}/bin/sonar-scanner"

rm "${ZIP_LOCATION}"
