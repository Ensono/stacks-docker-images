#!/bin/bash

# Update Apt and install unzup
apt-get update
apt-get install -y unzip

# Install Maven
curl -L "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip
unzip /tmp/maven.zip -d /usr/local
rm /tmp/maven.zip