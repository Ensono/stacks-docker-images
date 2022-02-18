FROM ubuntu:20.04

ARG PWSH_VERSION=7.1.5
ARG TASKFILE_VERSION=3.9.0
ARG TASKCTL_VERSION=1.4.2
ARG TERRAFORM_VERSION=1.0.10
ARG AMIDOBUILD=v0.0.47

ENV TZ="Europe/London"

# Configure Timezone for the image
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Update the package repository and install wget and libraries
# That are required for powershell
RUN apt-get update && \
    apt-get install -y curl \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        python3 \
        python3-pip \
        libgssapi-krb5-2 \
        liblttng-ust0 \
        libicu66

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && \
    apt-cache policy docker-ce && \
    apt-get install -y docker-ce-cli

# Install PowerShell
RUN curl -L "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell_${PWSH_VERSION}-1.ubuntu.20.04_amd64.deb" -o /tmp/pwsh.deb && \
    dpkg -i /tmp/pwsh.deb && \
    rm /tmp/pwsh.deb

# Install Terraform
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# Install the AmidoBuild module
RUN mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/amido/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1

# Install the Taskctl runner
RUN curl -L "https://github.com/taskctl/taskctl/releases/download/${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_amd64.deb" -o /tmp/taskctl.deb && \
    dpkg -i /tmp/taskctl.deb && \
    rm /tmp/taskctl.deb

# Install the necessary python modules
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt

# Install the PowerShell AZ module
RUN pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force"
