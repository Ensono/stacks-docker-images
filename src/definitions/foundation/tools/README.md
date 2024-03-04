# EIR Foundation Tools

The image is used as a library from which software tools can be copied into other images as required. The image is built from the `enonso/eir-foundation-powershell` image.

All applications are installed by copying and then running the `files/install.sh` script. By installing the applications in this way the number of `RUN` statements in the Dockerfile is reduced.

## Specs

**Platforms**: `linux/amd64`, `linux/arm64`

**Base Image**: ensono/eir-foundation-powershell

### Software

| Type | Name | Version | URL |
|---|---|---|---|
| Binary | Kubectl | 1.23.14 | https://dl.k8s.io/release/v1.23.14/bin/linux/amd64/kubectl |
| Binary | Helm | 3.12.03 | https://get.helm.sh/helm-v3.12.03-linux-amd64.tar.gz |
| Binary | Terraform | 1.5.1 | https://releases.hashicorp.com/terraform/1.5.1/terraform_1.5.1_linux_x86_54.zip |
| Binary | GitHub CLI | 2.40.1 | https://github.com/cli/cli/releases/download/v2.40.1/gh_2.40.1_linux_amd64.tar.gz |
| Binary | Kluctl | 2.22.1 | https://github.com/kluctl/kluctl/releases/download/2.22.1/kluctl_2.22.1_linux_amd64.tar.gz |
| Binary | Kustomize | 5.2.1 | https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.2.1/kustomize_v5.2.1_linux_amd64.tar.gz |
| Binary | Docker | 24.0.7 | https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz |
| Binary | Docker Buildx | 0.12.0 | https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.linux-amd64 |
| PS Module | Az | 10.0.0 | - |
| PS Module | Pester | 5.4.1 | - |
| PS Module | PowerShell-Yaml | 
| PS Module | Arm-ttk | 20231122 | - |
