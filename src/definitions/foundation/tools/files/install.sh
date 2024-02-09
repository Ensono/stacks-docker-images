#!/bin/bash

# Script that installs tools that are not in the Linux distro package list, or
# the versions required are not available

# Install necessary linux packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl git
unlink /etc/localtime
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Get the architecture of the container
export PROPER_ARCH="$(uname -m)"
if [ "$PROPER_ARCH" = "x86_64" ]
then 
    export ARCH="amd64"
elif [ "$PROPER_ARCH" = "aarch64" ]
then 
    export ARCH="arm64"
fi

# Kubectl -------------------------------------------------------------------
echo "Installing: Kubectl"
mkdir -p /usr/local/kubectl/bin 
curl -L https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/local/kubectl/bin/kubectl 
chmod +x /usr/local/kubectl/bin/kubectl
# ---------------------------------------------------------------------------

# Helm ----------------------------------------------------------------------
echo "Installing: Helm"
mkdir -p /usr/local/helm 
curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -o /tmp/helm.tar.gz 
tar zxf /tmp/helm.tar.gz 
mkdir -p /usr/local/helm/bin 
mv linux-${ARCH}/helm /usr/local/helm/bin 
chmod +x /usr/local/helm/bin/helm 
# ---------------------------------------------------------------------------

# Terraform -----------------------------------------------------------------
echo "Installing: Terraform"
mkdir -p /usr/local/terraform/bin 
curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o /tmp/terraform.zip 
unzip /tmp/terraform.zip -d /usr/local/terraform/bin 
chmod +x /usr/local/terraform/bin/terraform
# ---------------------------------------------------------------------------

# GH CLI --------------------------------------------------------------------
echo "Installing: GitHub CLI"
curl -L "https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/ghcli.tar.gz 
tar zxf /tmp/ghcli.tar.gz -C /tmp 
mv /tmp/gh_${GHCLI_VERSION}_linux_${ARCH} /usr/local/ghcli
# ---------------------------------------------------------------------------

# Kluctl --------------------------------------------------------------------
echo "Installing: Kluctl"
mkdir -p /usr/local/kluctl/bin 
curl -L "https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/kluctl.tar.gz 
tar zxf /tmp/kluctl.tar.gz -C /usr/local/kluctl/bin kluctl 
chmod +x /usr/local/kluctl/bin/kluctl
# ---------------------------------------------------------------------------

# Kustomize -----------------------------------------------------------------
echo "Installing: Kustomize"
mkdir -p /usr/local/kustomize/bin 
curl -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" -o /tmp/kustomize.tar.gz 
tar zxf /tmp/kustomize.tar.gz -C /usr/local/kustomize/bin kustomize 
chmod +x /usr/local/kustomize/bin/kustomize
# ---------------------------------------------------------------------------

# Docker --------------------------------------------------------------------
echo "Installing: Docker"
mkdir -p /usr/local/docker/bin 
curl -L "https://download.docker.com/linux/static/stable/${PROPER_ARCH}/docker-${DOCKER_VERSION}.tgz" -o /tmp/docker.tgz 
tar zxf /tmp/docker.tgz -C /tmp 
mv /tmp/docker/* /usr/local/docker/bin
# ---------------------------------------------------------------------------

# Docker Buildx -------------------------------------------------------------
# Used to extend Docker so that builds for other platforms can be created
echo "Installing: Docker Buildx"
mkdir -p /usr/libexec/docker/cli-plugins 
curl -L "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${ARCH}" -o /usr/libexec/docker/cli-plugins/docker-buildx 
chmod +x /usr/libexec/docker/cli-plugins/docker-buildx
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
curl -L https://github.com/Azure/arm-ttk/releases/download/${ARM_TTK_VERSION}/arm-ttk.zip -o /tmp/arm-ttk.zip 
unzip -d /usr/local/share/powershell/Modules /tmp/arm-ttk.zip
# ***************************************************************************

# Clean Up ******************************************************************
# Remove everything from the temp directory
rm -rf /tmp/*
# ***************************************************************************