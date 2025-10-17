# Add AI Agent Guidance and Update SonarScanner Version

## 📲 What

This PR introduces comprehensive AI agent guidance documentation and updates the SonarScanner version in the .NET Docker image:

1. **Added AI Agent Instructions** (`copilot-instructions.md`):

   - Comprehensive guide for AI coding agents working with this Docker images repository
   - Covers project architecture, build workflows, configuration patterns, and development procedures
   - Documents the hierarchical image dependency system and critical build order requirements

2. **Added Security Compliance Guidelines** (`copilot-security-instructions.md`):

   - Detailed security and compliance requirements for AI agents
   - Enforces GPG commit signing, branch protection policies, and SDLC processes
   - Implements security standards compliance (ISO 27001, NIST, FIPS, PCI DSS, etc.)
   - Provides specific examples of prohibited and compliant code patterns

3. **Updated .NET Docker Image Dependencies**:
   - SonarScanner version: `5.14` → `11.0.0` (major version upgrade)
   - ReportGenerator version: `5.1.26` → `5.4.17` (maintenance update)

## 🤔 Why

**AI Agent Documentation**:

- Enables AI coding assistants to be immediately productive in this codebase without extensive context gathering
- Prevents common mistakes by documenting critical build order dependencies and project-specific patterns
- Establishes clear security guardrails to maintain compliance and prevent policy violations

**SonarScanner Update**:

- Brings the .NET image up to the latest SonarScanner version for improved code quality analysis
- Addresses potential security vulnerabilities and bugs in older versions
- Ensures compatibility with modern .NET projects and SonarQube instances

**Security Compliance**:

- Enforces mandatory security controls that must never be bypassed
- Implements audit trails and change management processes
- Ensures all AI-generated code meets enterprise security standards

## 🛠 How

**Documentation Implementation**:

- Created `.github/copilot-instructions.md` with project-specific guidance covering:

  - Image hierarchy and dependency chain (`foundation/powershell` → `foundation/builder` → specialized images)
  - Taskctl-based build system with context switching (local vs containerized builds)
  - PowerShell module integration and environment variable management
  - Critical debugging commands and development workflows

- Created `.github/copilot-security-instructions.md` with enterprise security requirements:

  - GPG commit signing enforcement with specific error handling procedures
  - Branch protection workflow requiring feature branches and PR approvals
  - Production change control processes with audit documentation
  - Security standards compliance scanning (FIPS, PCI DSS, ISO 27001, OWASP)

- Cross-referenced security guidelines in main instructions with prominent warnings

**Version Updates**:

- Modified `src/definitions/dotnet/Dockerfile.ubuntu`:
  - Updated `SONARSCANNER_VERSION` ARG from `5.14` to `11.0.0`
  - Updated `REPORTGENERATOR_VERSION` ARG from `5.1.26` to `5.4.17`
- Maintained backward compatibility through ARG-based versioning system

## 👀 Evidence

- **Documentation**: Both guidance files follow established patterns and reference existing project structure
- **Security**: All security examples are based on industry standards (ISO 27001, NIST SP 800-53, OWASP Top 10)
- **Dockerfile Changes**: Version bumps are straightforward ARG updates with no breaking changes
- **Integration**: Security instructions are properly referenced from main instructions file

## 🕵️ How to test

**AI Agent Documentation**:

1. Validate that AI agents can understand project structure from the instructions
2. Verify that all referenced files and commands exist and are accurate
3. Test that build order dependencies are clearly documented and correct

**Security Compliance**:

1. Confirm that security guidelines cover all critical scenarios
2. Verify GPG signing requirements are properly enforced
3. Test branch protection workflow documentation matches actual repository settings

**Docker Image Updates**:

1. Build the updated .NET image locally: `taskctl build:dotnet`
2. Verify SonarScanner 11.0.0 is properly installed in the container
3. Test ReportGenerator 5.4.17 functionality with sample .NET projects
4. Confirm no breaking changes in the tool interface or output formats

**Integration Testing**:

1. Validate that the entire build pipeline still works with updated versions
2. Test multi-platform builds (`linux/amd64`, `linux/arm64`)
3. Verify Azure DevOps pipeline compatibility with updated tools
4. Confirm documentation generation processes remain functional

**Security Validation**:

1. Ensure branch protection rules are active and documented procedures match reality
2. Verify GPG signing is enforced for all commits on protected branches
3. Test that AI agents following the security guidelines cannot bypass established controls
