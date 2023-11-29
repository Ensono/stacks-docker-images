#!/bin/sh

# Script that installs tools that are not in the Linux distro package list, or
# the versions required are not available

# Kubectl -------------------------------------------------------------------
RUN mkdir -p /usr/local/kubectl/bin && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/local/kubectl/bin/kubectl && \
    chmod +x /usr/local/kubectl/bin/kubectl
# ---------------------------------------------------------------------------

# Helm ----------------------------------------------------------------------
RUN mkdir -p /usr/local/helm && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -o /tmp/helm.tar.gz && \
    tar zxf /tmp/helm.tar.gz && \
    mkdir -p /usr/local/helm/bin && \
    mv linux-${ARCH}/helm /usr/local/helm/bin && \
    rm -rf /tmp/helm.tar.gz linux-${ARCH} && \
    chmod +x /usr/local/helm/bin/helm 
# ---------------------------------------------------------------------------

# Terraform -----------------------------------------------------------------
mkdir -p /usr/local/terraform/bin && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/terraform/bin && \
    rm /tmp/terraform.zip && \
    chmod +x /usr/local/terraform/bin/terraform
# ---------------------------------------------------------------------------

# Taskctl Runner ------------------------------------------------------------
mkdir -p /usr/local/taskctl/bin && \
    export ARCH="$(uname -m)" && \
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://github.com/russellseymour/taskctl/releases/download/v${TASKCTL_VERSION}/taskctl_${TASKCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/taskctl.tar.gz && \
    tar zxf /tmp/taskctl.tar.gz -C /usr/local/taskctl/bin taskctl && \
    rm -f /tmp/taskctl.tar.gz && \
    chmod +x /usr/local/taskctl/bin/taskctl
# ---------------------------------------------------------------------------

# Kluctl --------------------------------------------------------------------
mkdir -p /usr/local/kluctl/bin && \
    export ARCH="$(uname -m)" && \ 
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/kluctl.tar.gz && \
    tar zxf /tmp/kluctl.tar.gz -C /usr/local/kluctl/bin kluctl && \
    rm -rf /tmp/kluctl.tar.gz && \
    chmod +x /usr/local/kluctl/bin/kluctl
# ---------------------------------------------------------------------------

# Kustomize -----------------------------------------------------------------
mkdir -p /usr/local/kustomize/bin && \
    export ARCH="$(uname -m)" && \ 
    if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi && \
    curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" -o /tmp/kustomize.tar.gz && \
    tar zxf /tmp/kustomize.tar.gz -C /usr/local/kustomize/bin kustomize && \
    rm -rf /tmp/kluctl.tar.gz && \
    chmod +x /usr/local/kustomize/bin/kustomize
# ---------------------------------------------------------------------------

# PowerShell Modules --------------------------------------------------------
# PowerShell Azure **********************************************************
pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${AZURE_AZ_MODULE_VERSON}"
# ***************************************************************************

# Pester ********************************************************************
pwsh -NoProfile -Command "Install-Module -Name Pester -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${PESTER_VERSION}"
# ***************************************************************************

# Yaml **********************************************************************
pwsh -NoProfile -Command "Install-Module -Name Powershell-Yaml -Scope AllUsers -Repository PSGallery -Force"
# ***************************************************************************

# ARM Template Checker ******************************************************
# Install this into the global Modules directory as this is not likely to need
# to be overridden (/usr/local/share/powershell/Modules)
curl -L https://github.com/Azure/arm-ttk/releases/download/${ARM_TTK_VERSION}/arm-ttk.zip -o /tmp/arm-ttk.zip && \
    unzip -d /usr/local/share/powershell/Modules /tmp/arm-ttk.zip && \
    rm -rf /tmp/arm-ttk.zip
# ***************************************************************************

# Independent Runner module *************************************************
mkdir -p /modules/AmidoBuild && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psd1" -o /modules/AmidoBuild/AmidoBuild.psd1 && \
    curl -L "https://github.com/Ensono/independent-runner/releases/download/${AMIDOBUILD}/AmidoBuild.psm1" -o /modules/AmidoBuild/AmidoBuild.psm1
# ***************************************************************************