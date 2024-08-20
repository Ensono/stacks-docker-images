#!/bin/bash

set -euxo pipefail

# Script that installs tools that are not in the Linux distro package list, or
# the versions required are not available

# Install necessary linux packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata unzip curl git
unlink /etc/localtime
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Get the architecture of the container
. /usr/local/bin/platform.bash

# Update the arch to fit in with the pattern for binaries that are do not fit the pattern
if [ "${UNAME_ARCH}" == "aarch64" ]; then
    NONCONFORM_ARCH="arm64"
else
    NONCONFORM_ARCH="${UNAME_ARCH}"
fi

# Kubectl -------------------------------------------------------------------
echo "Installing: Kubectl"
mkdir -p /usr/local/kubectl/bin
curl --fail-with-body -L https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${BIN_ARCH}/kubectl -o /usr/local/kubectl/bin/kubectl
chmod +x /usr/local/kubectl/bin/kubectl
# ---------------------------------------------------------------------------

# Helm ----------------------------------------------------------------------
echo "Installing: Helm"
mkdir -p /usr/local/helm
curl --fail-with-body -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${BIN_ARCH}.tar.gz -o /tmp/helm.tar.gz
tar zxf /tmp/helm.tar.gz
mkdir -p /usr/local/helm/bin
mv linux-${BIN_ARCH}/helm /usr/local/helm/bin
chmod +x /usr/local/helm/bin/helm
# ---------------------------------------------------------------------------

# TEnv ----------------------------------------------------------------------
# Used to install and different versions of Terraform
echo "Installing: TEnv"
mkdir -p /usr/local/tenv/bin
curl --fail-with-body -L https://github.com/tofuutils/tenv/releases/download/v${TENV_VERSION}/tenv_v${TENV_VERSION}_Linux_${BIN_ARCH}.tar.gz -o /tmp/tenv.tar.gz
tar zxf /tmp/tenv.tar.gz -C /usr/local/tenv/bin
export PATH="${PATH}:/usr/local/tenv/bin"
# ---------------------------------------------------------------------------

# Terraform -----------------------------------------------------------------
# Install the required versions of Terraform using the TEnv tool
IFS=","
for TFVERSION in ${TERRAFORM_VERSION}; do
    echo "Installing: Terraform [${TFVERSION})]"
    
    tenv tf install ${TFVERSION}
done

# Set the version of Terraform to use
echo "\tSetting default Terraform version to ${DEFAULT_TF_VERSION}"
tenv tf use ${DEFAULT_TF_VERSION}
# ---------------------------------------------------------------------------


# Terrascan -----------------------------------------------------------------
echo "Installing: TerraScan"
mkdir -p /usr/local/terrascan/bin
curl --fail-with-body -L "https://github.com/tenable/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_${NONCONFORM_ARCH}.tar.gz" -o /tmp/terrascan.tar.gz
tar zxf /tmp/terrascan.tar.gz -C /tmp
mv /tmp/terrascan /usr/local/terrascan/bin
chmod +x /usr/local/terrascan/bin/terrascan
# ---------------------------------------------------------------------------

# GH CLI --------------------------------------------------------------------
echo "Installing: GitHub CLI"
curl --fail-with-body -L "https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_${BIN_ARCH}.tar.gz" -o /tmp/ghcli.tar.gz
tar zxf /tmp/ghcli.tar.gz -C /tmp
mv /tmp/gh_${GHCLI_VERSION}_linux_${BIN_ARCH} /usr/local/ghcli
# ---------------------------------------------------------------------------

# Kluctl --------------------------------------------------------------------
echo "Installing: Kluctl"
mkdir -p /usr/local/kluctl/bin
curl --fail-with-body -L "https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_linux_${BIN_ARCH}.tar.gz" -o /tmp/kluctl.tar.gz
tar zxf /tmp/kluctl.tar.gz -C /usr/local/kluctl/bin kluctl
chmod +x /usr/local/kluctl/bin/kluctl
# ---------------------------------------------------------------------------

# Kustomize -----------------------------------------------------------------
echo "Installing: Kustomize"
mkdir -p /usr/local/kustomize/bin
curl --fail-with-body -L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${BIN_ARCH}.tar.gz" -o /tmp/kustomize.tar.gz
tar zxf /tmp/kustomize.tar.gz -C /usr/local/kustomize/bin kustomize
chmod +x /usr/local/kustomize/bin/kustomize
# ---------------------------------------------------------------------------

# Install JQ ----------------------------------------------------------------
echo "Installing: JQ"
mkdir -p /usr/local/jq/bin
curl --fail-with-body -L "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${BIN_ARCH}" -o /usr/local/jq/bin/jq
chmod +x /usr/local/jq/bin/jq
# ---------------------------------------------------------------------------

# Install Snyk Tools --------------------------------------------------------
echo "Installing: Snyk"
mkdir -p /usr/local/snyk/bin

# As the package does not have an ARCH in the filename, the filename needs to be set correctly
if [ "${BIN_ARCH}" == "amd64" ]; then
    FILENAME="snyk-linux"
else
    FILENAME="snyk-linux-arm64"
fi

curl --fail-with-body -L "https://github.com/snyk/cli/releases/download/v${SNYK_VERSION}/${FILENAME}" -o /usr/local/snyk/bin/snyk

# ---------------------------------------------------------------------------

# Install envsubst ----------------------------------------------------------------
echo "Installing: envsubst"
mkdir -p /usr/local/envsubst/bin
curl --fail-with-body -L "https://github.com/a8m/envsubst/releases/download/${ENVSUBST_VERSION}/envsubst-Linux-${NONCONFORM_ARCH}" -o /usr/local/envsubst/bin/envsubst
chmod +x /usr/local/envsubst/bin/envsubst
# ---------------------------------------------------------------------------

# PowerShell Modules --------------------------------------------------------
# PowerShell Azure **********************************************************
pwsh -NoProfile -Command "Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${AZURE_AZ_MODULE_VERSON}"
# ***************************************************************************

# Pester ********************************************************************
pwsh -NoProfile -Command "Install-Module -Name Pester -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${PESTER_VERSION}"
# ***************************************************************************

# Yaml **********************************************************************
pwsh -NoProfile -Command "Install-Module -Name Powershell-Yaml -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${POWERSHELL_YAML_VERSION}"
# ***************************************************************************

# PSScriptAnalyzer **********************************************************
pwsh -NoProfile -Command "Install-Module -Name PSScriptAnalyzer -Scope AllUsers -Repository PSGallery -Force -RequiredVersion ${PSSCRIPTANALYZER_VERSION}"
# ***************************************************************************

# ARM Template Checker ******************************************************
# Install this into the global Modules directory as this is not likely to need
# to be overridden (/usr/local/share/powershell/Modules)
curl --fail-with-body -L https://github.com/Azure/arm-ttk/releases/download/${ARM_TTK_VERSION}/arm-ttk.zip -o /tmp/arm-ttk.zip
unzip -d /usr/local/share/powershell/Modules /tmp/arm-ttk.zip
# ***************************************************************************

# Clean Up ******************************************************************
# Remove everything from the temp directory
rm -rf /tmp/*
# ***************************************************************************
