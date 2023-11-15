ARG orgname=amidostacks
ARG IMAGE_REF=amidostacks/runner-pwsh-java
FROM $IMAGE_REF

ARG SONARSCANNER_CLI_VERSION=5.0.1.3006
ARG SONARSCANNER_VERSION=5.14
ARG REPORTGENERATOR_VERSION=5.1.26
ARG DOTNET_VERSION=6.0.300
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

# Install SonarScanner CLI
RUN curl --insecure -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARSCANNER_CLI_VERSION}-linux.zip -o /opt/sonarscanner.zip && \
    cd /opt && \
    unzip sonarscanner.zip && \
    rm sonarscanner.zip && \
    rm -rf sonar-scanner-${SONARSCANNER_CLI_VERSION}-linux/jre && \
    sed -i 's/use_embedded_jre=true/use_emebdded_jre=false/g' sonar-scanner-${SONARSCANNER_CLI_VERSION}-linux/bin/sonar-scanner && \
    chmod -R 777 * && \
    ln -sf /opt/sonar-scanner-${SONARSCANNER_CLI_VERSION}-linux/bin/sonar-scanner /usr/local/bin
