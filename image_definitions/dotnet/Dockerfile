ARG orgname=amidostacks

FROM ${orgname}/runner-pwsh-java

ARG SONARSCANNER_VERSION=5.11
ARG REPORTGENERATOR_VERSION=5.1.16
ARG DOTNET_VERSION=6.0.405
ARG TOOLPATH="/usr/local/dotnet"

# Upate the PATH environment variable so that the tool can be found
ENV PATH="${TOOLPATH}:${PATH}"

# Set the DOTNET_ROOT env var so that the reportgenerator binary works properly
ENV DOTNET_ROOT="${TOOLPATH}"

# Install the dotnet framework
RUN curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh --install-dir ${TOOLPATH} --version ${DOTNET_VERSION}

# Install necessary dotnet tools
RUN dotnet tool install dotnet-sonarscanner --version ${SONARSCANNER_VERSION} --tool-path ${TOOLPATH} && \
    dotnet tool install dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_VERSION} --tool-path ${TOOLPATH}