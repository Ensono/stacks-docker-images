# This image builds on the base image and installs Java SDK
# for building applications

FROM amidostacks/runner-pwsh

ARG JAVA_VERSION=11.0.13
ARG MAVEN_VERSION=3.8.8


# Install dependencies
RUN apt-get update && \
    apt-get install -y java-common \
        libasound2 \
        libx11-6 \
        libxcb1 \
        libxdmcp6 \
        libxext6 \
        libxi6 \
        libxrender1 \
        libxtst6 \
        libfontconfig1 \
        gnupg \
        gnupg-agent \
        unzip \
        curl

RUN curl "https://cdn.azul.com/zulu/bin/zulu11.52.13-ca-jdk${JAVA_VERSION}-linux_amd64.deb" -o /tmp/java.deb && \
    dpkg -i /tmp/java.deb && \
    rm /tmp/java.deb

# Install Maven
RUN curl "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip && \
    unzip /tmp/maven.zip -d /usr/local && \
    rm /tmp/maven.zip

# Update the path so maven can be found
ENV PATH="/usr/local/apache-maven-${MAVEN_VERSION}/bin:$PATH"

# Remove uncessary packages
RUN apt-get -y remove curl unzip && \
    apt-get -y autoremove
