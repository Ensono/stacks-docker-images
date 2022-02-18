# This image builds on the base image and installs .NET SDK
# for building applications

FROM amidostacks/runner-pwsh

ARG SONARSCANNER_VERSION=5.3.2
ARG REPORTGENERATOR_VERSION=5.0.0
ARG DOTNET_VERSION=3.1
ARG TOOLPATH="/usr/local/dotnet"

# Upate the PATH environment variable so that the tool can be found
ENV PATH="${TOOLPATH}:${PATH}"

# Install the dotnet framework
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb

RUN apt-get update && \
    apt-get install -y dotnet-sdk-${DOTNET_VERSION}

# Install necessary dotnet tools
RUN dotnet tool install dotnet-sonarscanner --version ${SONARSCANNER_VERSION} --tool-path ${TOOLPATH} && \
    dotnet tool install dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_VERSION} --tool-path ${TOOLPATH}
