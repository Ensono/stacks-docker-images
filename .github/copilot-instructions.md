# Stacks Docker Images - AI Agent Guide

## Security and Compliance Requirements

⚠️ **CRITICAL**: Before making any changes to this repository, you MUST read and comply with the security guidelines in [copilot-security-instructions.md](./copilot-security-instructions.md). This includes requirements for GPG commit signing, branch protection policies, and security standards compliance.

## Project Overview

This repository builds a hierarchical set of Docker images for the Amido Stacks CI/CD pipeline. Images are layered from foundation to specialized tools, requiring careful build order and dependency management.

## Architecture & Build System

### Image Hierarchy

Images follow a strict dependency chain:

- **Foundation Layer**: `foundation/powershell` → `foundation/builder` → `foundation/azure-cli` → `foundation/tools`
- **Specialized Images**: `java`, `dotnet`, `golang`, `node`, `infrastructure`, `inspec`, `data`, `kong`, `asciidoctor`
- **Security Images**: `bottlerocket-cis-bootstrap`, `bottlerocket-cis-validation`

Each image inherits from a parent via ARG-based registry/tag system:

```dockerfile
ARG REGISTRY=docker.io
ARG IMAGE_TAG=0.0.1-workstation
ARG ORG=ensono
FROM ${REGISTRY}/${ORG}/eir-java:${IMAGE_TAG} AS base
```

### Build Workflow (Taskctl)

All builds use `taskctl` with YAML configuration. Key patterns:

- **Foundation images**: Built locally first (no container dependency)
- **Specialized images**: Built using `powershell_docker` context (inside `eir-foundation-builder`)
- **Multi-platform**: Supports `linux/amd64` and `linux/arm64` via `PLATFORM` env var

**Critical build order**: Foundation images MUST build before dependent images.

```bash
# Build foundation (local machine)
taskctl build:foundation:powershell
taskctl build:foundation:builder

# Build specialized (in container)
taskctl build:dotnet
taskctl build:java
```

## Key Configuration Files

### `taskctl.yaml` - Build Orchestration

- Defines pipelines for each image with proper dependencies
- Uses templated variables: `IMAGE_NAME`, `DOCKER_BUILD_ARGS`, `DOCKER_IMAGE_TAG`
- Context switching between local (`powershell`) and containerized (`powershell_docker`) builds

### `build/taskctl/contexts.yaml` - Execution Environments

- `powershell_docker`: Runs inside `ensono/eir-foundation-builder` container
- `powershell`: Runs on host machine with pwsh
- `docsenv`: Uses `ensono/eir-asciidoctor` for documentation builds

### `build/scripts/Build-DockerImage.ps1` - Core Build Logic

- Handles multi-arch builds with platform-specific tagging
- Registry authentication and image pushing
- Uses `Invoke-External` wrapper for command execution
- Tag format: `{registry}/{name}:{version}-{arch}`

## Development Patterns

### Adding New Images

1. Create `src/definitions/{name}/Dockerfile.ubuntu`
2. Add `files/` directory with install scripts
3. Update `taskctl.yaml` with new pipeline entry
4. Add Azure DevOps stage in `build/azDevOps/docker-images.yml`
5. Create documentation in `docs/docker-definitions/{name}.adoc`

**Security Note**: All changes must follow the branch protection workflow outlined in [copilot-security-instructions.md](./copilot-security-instructions.md). Never commit directly to protected branches or bypass GPG signing requirements.

### Version Management

- Image versions controlled by `DOCKER_IMAGE_TAG` environment variable
- Component versions set as Dockerfile ARGs (e.g., `SONARSCANNER_VERSION=11.0.0`)
- Foundation image versions referenced in dependent images via build args

### PowerShell Module Integration

Uses `EnsonoBuild` PowerShell module for:

- `Update-BuildNumber`: Sets `DOCKER_IMAGE_TAG`
- `Invoke-External`: Command execution with dry-run support
- `Invoke-Terraform`: Infrastructure management
- `Confirm-Environment`: Environment validation

## Infrastructure & Deployment

### Azure Container Registry (ACR)

- Terraform configuration in `deploy/terraform/azure/acr/`
- Environment variables prefixed with `TF_VAR_`
- Required variables: `name_company`, `name_component`, `name_project`

### CI/CD Pipeline (Azure DevOps)

- Multi-stage pipeline with dependency management
- Each image has dedicated stage with `dependsOn` relationships
- Supports multi-platform builds and manifest creation
- Documentation generation integrated into build process

## Dogfooding

- This repository attempts to use its own Docker images for builds and documentation generation wherever possible, ensuring that the images are robust and fit for purpose.

```powershell
## Replace registry and tag
$yqCommand = '.contexts.powershell_docker.executable.args[] |= select(contains("ensono/eir-foundation-builder")) = "{0}/ensono/eir-foundation-builder:{1}"' -f $DockerContainerRegistryName, $BuildNumber
Write-Information ("Executing yq with '{0}'" -f $yqCommand)
yq -i $yqCommand build/taskctl/contexts.yaml
```

## Documentation System

- AsciiDoc-based using custom `ensono/eir-asciidoctor` image
- Configuration in `docs.json` with PDF/HTML output
- Auto-generates Docker Hub README files from AsciiDoc sources
- Custom glob-include processor for dynamic content inclusion

## Common Debugging Commands

```bash
# Check image dependencies
taskctl build:foundation:powershell --dry-run

# Debug build in container context
docker run --rm -v ${PWD}:/app -w /app ensono/eir-foundation-builder:latest pwsh

# Generate docs locally
taskctl docs

# Validate Terraform configuration
taskctl infrastructure_variables
taskctl infra:plan
```

## Environment Variables

- `DOCKER_IMAGE_TAG`: Version for all images (set by `Update-BuildNumber`)
- `DOCKER_CONTAINER_REGISTRY_NAME`: Target registry (default: docker.io)
- `PLATFORM`: Build architecture (linux/amd64, linux/arm64)
- `TF_VAR_*`: Terraform variables for ACR deployment
