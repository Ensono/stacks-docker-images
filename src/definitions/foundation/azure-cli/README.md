# EIR Foundation Azure CLI

The Azure CLI is a large application that is used to manipulate resource sin Azure. It is is its own image so that it can be used as a base image for other container images, such as `data`.

The CLI can be added to, for example the `databricks` extension.

The image is built from the Ensono PowerShell image.

## Specs

**Platforms**: `linux/amd64`, `linux/arm64`

**Base Image**: ensno/eir-foundation-image

### Software

| Name | Version | URL |
|---|---|---|
| Azure CLI | 2.48.1 | https://github.com/PowerShell/PowerShell |