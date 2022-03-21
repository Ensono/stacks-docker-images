# This image builds on the base image and installs .NET SDK
# for building applications

FROM amidostacks/runner-pwsh

# This image builds on the base image and installs .NET SDK
# for building applications

ARG SONARSCANNER_VERSION=5.4.1
ARG REPORTGENERATOR_VERSION=5.0.2
ARG DOTNET_VERSION=6.0
ARG TOOLPATH="/usr/local/dotnet"

# Upate the PATH environment variable so that the tool can be found
ENV PATH="${TOOLPATH}:${PATH}"

RUN apt-get -y install curl

# Install the dotnet framework
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb

RUN apt-get update && \
    apt-get install -y \
    dotnet-sdk-${DOTNET_VERSION} \
    openjdk-11-jdk

# Install necessary dotnet tools
RUN dotnet tool install dotnet-sonarscanner --version ${SONARSCANNER_VERSION} --tool-path ${TOOLPATH} && \
    dotnet tool install dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_VERSION} --tool-path ${TOOLPATH}

RUN apt-get -y remove curl && \
    apt-get -y autoremove
