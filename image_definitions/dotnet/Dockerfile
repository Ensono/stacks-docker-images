# This image builds on the base image and installs .NET SDK
# for building applications

# FROM amidostacks/runner-pwsh
FROM amidostacks/runner-pwsh

# This image builds on the base image and installs .NET SDK
# for building applications

ARG SONARSCANNER_VERSION=5.4.1
ARG REPORTGENERATOR_VERSION=5.0.2
ARG DOTNET_VERSION=6.0.200
ARG TOOLPATH="/usr/local/dotnet"

# Upate the PATH environment variable so that the tool can be found
ENV PATH="${TOOLPATH}:${PATH}"

RUN apt-get -y install curl

# Install the dotnet framework
RUN curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh --install-dir /usr/bin --version ${DOTNET_VERSION}

# Install necessary dotnet tools
RUN dotnet tool install dotnet-sonarscanner --version ${SONARSCANNER_VERSION} --tool-path ${TOOLPATH} && \
    dotnet tool install dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_VERSION} --tool-path ${TOOLPATH}

RUN apt-get update && \
    apt-get install -y \
    openjdk-11-jdk

RUN apt-get -y remove curl && \
    apt-get -y autoremove
