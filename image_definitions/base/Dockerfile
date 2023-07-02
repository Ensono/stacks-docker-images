ARG IMAGE_TAG=7.3-alpine-3.14

# Pull the base image to use
FROM mcr.microsoft.com/powershell:${IMAGE_TAG}

# Add the arguments for the apps to install in the base image
ARG TERRAFORM_VERSION=1.5.1
ARG AMIDOBUILD=v0.0.221
ARG TASKCTL_VERSION=1.4.2
ARG KUBE_VERSION=v1.23.14
ARG AZURE_CLI_VERSION=2.48.1
ARG AZURE_AZ_MODULE_VERSON=10.0.0
ARG AWS_CLI_VERSION=2.12.4
ARG PESTER_VERSION=5.4.1
ARG HELM_VERSION=3.12.0
ARG ARM_TTK_VERSION="20221215"

# Configure environment variables
ENV TZ="Europe/London"

# Install the necessary OS packages
RUN apk add --update --no-cache ca-certificates \
 && apk add -t deps \
 && apk add --no-cache --update tzdata \
    bash \
    curl \
    unzip \
    git \
    tar \
    python3 \
    python3-dev \
    py3-pip \
    build-base \
    linux-headers \
    docker-cli \
 && apk del --purge deps

# Install other required packages
# -- Kubectl
# -- Install ref: https://github.com/lachie83/k8s-kubectl/blob/v1.23.14/Dockerfile
RUN export ARCH="$(uname -m)" \
 && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
 && curl -L https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/bin/kubectl \
 && chmod +x /usr/bin/kubectl

# -- Helm
RUN export ARCH="$(uname -m)" \
    && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -o /tmp/helm.tar.gz \
    && tar zxf /tmp/helm.tar.gz \
    && mv linux-${ARCH}/helm /usr/bin/helm \
    && chmod +x /usr/bin/helm \
    && rm -rf /tmp/helm.tar.gz linux-${ARCH}

# -- Terraform
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# -- Taskctl runner
RUN export ARCH="$(uname -m)" \
 && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
 && curl -L "https://github.com/taskctl/taskctl/releases/download/${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/taskctl.tar.gz \
 && tar zxf /tmp/taskctl.tar.gz -C /usr/bin taskctl \
 && chmod +x /usr/bin/taskctl

# -- PowerShell AZ module
RUN pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${AZURE_AZ_MODULE_VERSON}"

# -- AWSCLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

# -- AZ CLI
# https://github.com/Azure/azure-cli/issues/8863dockerfile c
COPY files/az /usr/bin
COPY ./requirements.txt .
RUN pip3 install --ignore-installed virtualenv \
 && python3 -m virtualenv /azure-cli \
 && /azure-cli/bin/python -m pip --no-cache-dir install azure-cli==${AZURE_CLI_VERSION} \
 && chmod +x /usr/bin/az \
 && pip3 install -r ./requirements.txt

# -- Pester for Unit testing
RUN pwsh -NoProfile -Command "Install-Module -Name Pester -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${PESTER_VERSION}"

# -- PowerShell-Yaml for parsing YAML in PowerShell
RUN pwsh -NoProfile -Command "Install-Module -Name Powershell-Yaml -Scope AllUsers -Repository PSGallery -Force"

# -- Install ARM Template syntax checker
RUN curl -L https://github.com/Azure/arm-ttk/releases/download/${ARM_TTK_VERSION}/arm-ttk.zip -o arm-ttk.zip && \
    unzip -d /modules ./arm-ttk.zip && \
    rm -rf arm-ttk.zip

# -- AmidoBuild module
RUN echo "Downloading AmidoBuild version - ${AMIDBUILD}" && \
    mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1

# Remove packages that are no longer required
RUN apk del --no-cache build-base linux-headers