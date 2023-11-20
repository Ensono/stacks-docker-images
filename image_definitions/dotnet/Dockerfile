ARG orgname=amidostacks
ARG IMAGE_REF=amidostacks/runner-pwsh-java
FROM $IMAGE_REF

ARG SONARSCANNER_VERSION=5.14
ARG REPORTGENERATOR_VERSION=5.1.26
ARG DOTNET_VERSION=6.0.300,8.0.100
ARG TOOLPATH="/usr/local/dotnet"

# Upate the PATH environment variable so that the tool can be found
ENV PATH="${TOOLPATH}:${PATH}"

# Set the DOTNET_ROOT env var so that the reportgenerator binary works properly
ENV DOTNET_ROOT="${TOOLPATH}"

COPY scripts/install-dotnet-sdk.ps1 /tmp/install-dotnet-sdk.ps1
RUN pwsh /tmp/install-dotnet-sdk.ps1 -list ${DOTNET_VERSION} -sonarscanner_version ${SONARSCANNER_VERSION} -reportgenerator_version ${REPORTGENERATOR_VERSION}

# Install the dotnet framework
#RUN curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
#    chmod +x /tmp/dotnet-install.sh && \
#    /tmp/dotnet-install.sh --install-dir ${TOOLPATH} --version ${DOTNET_VERSION}

# Install necessary dotnet tools
RUN dotnet tool install dotnet-sonarscanner --version ${SONARSCANNER_VERSION} --tool-path ${TOOLPATH} && \
    dotnet tool install dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_VERSION} --tool-path ${TOOLPATH}