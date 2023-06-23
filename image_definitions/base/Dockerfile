FROM mcr.microsoft.com/powershell:7.2-ubuntu-20.04

ARG PWSH_VERSION=7.2.1
ARG TERRAFORM_VERSION=1.5.1
ARG AMIDOBUILD=v0.0.221
ARG TASKCTL_VERSION=1.4.2
ARG INSPEC_VERSION=5.14.0

ENV TZ="Europe/London"

# Configure Timezone for the image
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Update the package repository and install wget and libraries
# That are required for powershell
RUN apt-get update --fix-missing && \
    apt-get install -y curl \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        git

# Install KubeCTL
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && \
    apt-cache policy docker-ce && \
    apt-get install -y docker-ce-cli

# Install Terraform
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# Install the Taskctl runner
RUN curl -L "https://github.com/taskctl/taskctl/releases/download/${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_amd64.deb" -o /tmp/taskctl.deb && \
    dpkg -i /tmp/taskctl.deb && \
    rm /tmp/taskctl.deb

# Install the PowerShell AZ module
RUN pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force"

# Install AWSCLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# Install AZ CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Pester for Unit testing
RUN pwsh -NoProfile -Command "Install-Module -Name Pester -Scope AllUsers -Repository PSGallery -Force"

# Install PowerShell-Yaml for parsing YAML in PowerShell
RUN pwsh -NoProfile -Command "Install-Module -Name Powershell-Yaml -Scope AllUsers -Repository PSGallery -Force"

# Install Inspec for infrastructure testing
RUN curl "https://omnitruck.chef.io/install.sh" -o "install.sh" && \
    bash -s ./install.sh -P inspec -v ${INSPEC_VERSION} && \
    rm install.sh

# Install Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update --fix-missing && apt-get install helm

# Install the Independent Runner module
RUN echo "Downloading AmidoBuild version - ${AMIDBUILD}" && \
    mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1

# Remove uncessary packages
RUN apt-get -y remove curl unzip software-properties-common apt-transport-https ca-certificates && \
    apt-get -y autoremove

