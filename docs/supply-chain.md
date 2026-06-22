# Supply Chain Security — aws-nis2-baseline

> **NIS2 Article 21(2)(d):** *"supply chain security, including security-related aspects concerning the relationships between each entity and its direct suppliers or service providers."*

This is the one NIS2 Article 21(2) measure addressed as documentation and architecture rather than as a deployed module — because supply-chain security for an infrastructure-as-code project is fundamentally about *how dependencies are sourced, pinned, verified, and trusted*, not about a resource you deploy. This document states that posture explicitly.

## What "supply chain" means for this repository

An IaC project's supply chain is the set of external things it pulls in and trusts to produce infrastructure:

1. **The Terraform provider** (`hashicorp/aws`) — the binary that translates HCL into AWS API calls.
2. **Terraform modules** — here, all first-party (`./modules/*`); no third-party module registry dependencies.
3. **The runtime/test platform** — the LocalStack Pro container image.
4. **CI tooling** — the GitHub Actions and scanners that run on every PR.
5. **The cloud service provider** — AWS itself, as the direct service provider in NIS2's sense.

Each is a supplier relationship. The controls below address them.

## Controls in place

### Provider pinning and provenance
The AWS provider is version-constrained in every module (`version = "~> 5.0"`) and **locked** in a committed `.terraform.lock.hcl` per deployable root (`environments/dev`, `environments/prod`), which records the exact provider version and its cryptographic checksums (`h1:`/`zh:` hashes). Terraform verifies these hashes on every `init`, so a tampered or substituted provider binary fails the integrity check. The lockfile is committed, so CI and every contributor resolve to the identical, verified provider build.

- **NIS2:** (d) supply chain — dependency integrity
- **ISO:** A.5.21 Managing information security in the ICT supply chain, A.8.28 Secure coding

### First-party modules only
Every module is sourced locally (`source = "../../modules/<name>"`). The project takes **no dependency on the public Terraform Registry or third-party modules**, which removes an entire class of supply-chain risk (typosquatting, abandoned modules, transitive module pulls). The trade-off — more code to maintain ourselves — is deliberate for a security baseline where provenance matters more than reuse velocity.

- **NIS2:** (d) supply chain — minimized external dependency surface
- **ISO:** A.5.19 Information security in supplier relationships

### Pinned platform image
The development/test platform is pinned to an exact image tag — `localstack/localstack-pro:4.4.0` — in `docker-compose.yml` and the CI service container, not a floating `:latest`. This makes the test environment reproducible and prevents an upstream image change from silently altering behavior between runs.

- **NIS2:** (d) supply chain — reproducible, pinned tooling
- **ISO:** A.8.31 Separation of development, test and production environments

### CI tooling provenance
GitHub Actions are referenced by tag, and the security scanners (tfsec, Checkov, tflint) run on every pull request — so a dependency or configuration change that introduces a known-insecure pattern is caught before merge. The scanner findings are triaged in a documented decision matrix rather than silently suppressed.

- **NIS2:** (d) supply chain + (e) secure development
- **ISO:** A.8.28 Secure coding, A.8.25 Secure development life cycle

### Cloud service provider relationship
AWS is the direct service provider. The baseline assumes the AWS **shared responsibility model**: AWS secures the cloud infrastructure; this project secures what's built on top (encryption, access control, logging, detection — the other nine measures). EU data residency is enforced architecturally via the `region-lock` SCP (eu-central-1), which is itself a supply-chain-relevant control: it constrains where the service provider processes data.

- **NIS2:** (d) supply chain — service-provider relationship & data residency
- **ISO:** A.5.23 Information security for use of cloud services

## Posture statements (stance, not yet automated)

These are honestly flagged as *posture* — a documented position the project takes, not a control it currently automates. Calling them out as such is itself part of (d): knowing the boundary of what's enforced.

- **SBOM:** This project does not currently generate a formal Software Bill of Materials (CycloneDX/SPDX). For a Terraform repo, the closest equivalent — a complete, checksum-verified inventory of what's pulled in — is the committed `.terraform.lock.hcl`. A formal SBOM step (e.g. generating a CycloneDX document in CI) is a reasonable future enhancement but is not claimed today.
- **Provider signature verification beyond hashes:** Terraform verifies provider checksums against the lockfile; HashiCorp's GPG signing of the registry is trusted transitively. No additional out-of-band signature verification is performed.
- **Dependency update cadence:** Provider and image versions are updated deliberately and manually, recorded via ADRs (e.g. the LocalStack Pro version decision). There is no automated dependency-bumping bot (Dependabot/Renovate) configured; that is a documented future option, weighed against the risk of unreviewed automated changes to a security baseline.

## Why this counts as covering measure (d)

NIS2 (d) does not require a specific tool — it requires that supply-chain risk in supplier and service-provider relationships is *identified and managed*. For this repository that means: dependencies are minimized (first-party modules), pinned and integrity-verified (lockfile, image tag), the CSP relationship and its data-residency implications are explicit (shared-responsibility, region-lock SCP), and the boundary between enforced controls and documented posture is stated honestly (the SBOM/automation gaps above). That is a defensible, auditable supply-chain posture — which is what (d) asks for.

See [ADR-023](#) in the project decision log for the rationale behind treating (d) as documentation rather than a module.

## Mapping

| Control | NIS2 | ISO 27001:2022 |
|---|---|---|
| Provider pinning + lockfile checksums | (d) | A.5.21, A.8.28 |
| First-party modules only | (d) | A.5.19 |
| Pinned LocalStack image | (d) | A.8.31 |
| CI scanner gates | (d)(e) | A.8.25, A.8.28 |
| CSP shared-responsibility + region-lock | (d) | A.5.23 |

With this measure documented, the project addresses **all 10 of NIS2 Article 21(2)'s measures** — nine as deployed Terraform, one (this) as architecture and posture.
