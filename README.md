cd ~/projects/aws-nis2-baseline
cat > README.md << 'EOF'
# Aws-nis2-baseline

[![CI](https://github.com/olanak/aws-nis2-baseline/actions/workflows/ci.yml/badge.svg)](https://github.com/olanak/aws-nis2-baseline/actions/workflows/ci.yml)
[![terraform-docs](https://github.com/olanak/aws-nis2-baseline/actions/workflows/docs.yml/badge.svg)](https://github.com/olanak/aws-nis2-baseline/actions/workflows/docs.yml)
![Terraform](https://img.shields.io/badge/terraform-%E2%89%A5%201.9-7B42BC?logo=terraform)
![License](https://img.shields.io/badge/license-MIT-green)

> A Terraform-based AWS landing zone aligned to **NIS2 Article 21** and **ISO 27001:2022 Annex A**. Built for zero-cost development on LocalStack with one paid AWS validation run.

## What this is

A Terraform-based AWS landing zone where every module maps to a specific **NIS2 Article 21** measure and **ISO 27001:2022 Annex A** control. Built and tested on LocalStack Pro for zero-cost development, with a single real-AWS validation run for final proof.

## Modules (current)

| Module | Purpose | NIS2 Art. 21(2) | ISO 27001:2022 |
|---|---|---|---|
| `modules/kms` | Customer-managed CMK with rotation | (h) Cryptography | A.8.24 |
| `modules/s3-baseline` | Secure-by-default bucket (SSE-KMS, TLS-only, versioned) + policy-injection hook | (c)(h) | A.8.13, A.8.24 |
| `modules/cloudtrail` | Multi-region trail, log file validation, KMS-encrypted | (b)(f) | A.8.15, A.8.34 |
| `modules/aws-config` | Configuration recorder + delivery channel + 6 NIS2-aligned managed rules | (a) | A.8.9 |
| `modules/vpc` | Two-AZ VPC, public/private subnets, NAT, VPC Flow Logs | (b) | A.8.16, A.8.22 |
| `modules/organizations` | AWS Organization, feature-set ALL, 3 OUs (Workloads/Security/Sandbox) | (i) | A.5.15 |
| `modules/scp` | 3 Service Control Policies (deny-root, region-lock, protect-logging) × 3 OUs | (i) | A.5.15, A.8.22 |
| `modules/identity-center` | SSO permission sets (short sessions), group + assignment — plan-mode (see ADR-021) | (i)(j) | A.5.15, A.8.5 |

## Repository structure
```text
aws-nis2-baseline/
├── modules/                 # Reusable, single-purpose Terraform modules (each with its own tests/)
│   ├── kms/
│   ├── s3-baseline/
│   ├── cloudtrail/
│   ├── aws-config/
│   ├── vpc/
│   ├── organizations/
│   ├── scp/
│   ├── identity-center/
│   └── detection/           # Week 4 (GuardDuty, Security Hub, EventBridge → SNS)
├── environments/
│   ├── _composition/        # Shared module wiring — provider-agnostic, single source of "what gets deployed"
│   ├── dev/                 # Thin wrapper → LocalStack provider + endpoints
│   └── prod/                # Thin wrapper → real AWS provider + remote backend (Week 6)
├── tests/                   # Root integration test composing the modules together
├── docs/                    # Architecture, NIS2 mapping, ISO crosswalk, learning log (filled in Week 5)
├── Makefile
├── docker-compose.yml
└── .github/workflows/       # CI: fmt, validate matrix, tflint, tfsec, Checkov, terraform test, Infracost
```

Both `dev` and `prod` are thin wrappers that call the same `_composition`. The module wiring exists once, so the two environments can't drift — the "identical infrastructure on LocalStack and real AWS" guarantee is structural, not maintained by hand.

## Architecture

See [docs/diagrams/architecture.md](docs/diagrams/architecture.md) for the module composition graph and data flows.

In brief: KMS is the cryptographic root (its CMK encrypts S3, CloudTrail, and flow logs). The S3 baseline bucket is the shared log sink — CloudTrail and AWS Config both deliver to it, with their permissions injected through the bucket module's `additional_policy_statements` hook so the baseline security guarantees are never overridden. CloudTrail and VPC Flow Logs publish to CloudWatch Logs, setting up the detection layer in Week 4. AWS Organizations + SCPs wrap the whole account in governance guardrails — including one that forbids disabling CloudTrail or Config.

## Quick start

```bash
# Requires Docker + LocalStack Pro auth token in LOCALSTACK_AUTH_TOKEN
make up                       # start LocalStack
cd environments/dev
terraform init
terraform apply -auto-approve # deploy the full composition to LocalStack
cd ../..
make test                     # run all module tests + integration test
```

## Development model

- **LocalStack Pro** (Student plan) for all development and CI — full service parity, zero spend.
- **Real AWS** for a single Week 6 validation run, under €15, with budget controls and immediate destroy.
- **CI on every PR:** terraform fmt, tflint, tfsec, Checkov, Infracost, terraform-docs, and `terraform test` (module + integration). Branch protection enforced.
- **Scanner findings** are triaged in a documented decision matrix (managed risk, not zero-findings theater), not silently suppressed.
- **Per-resource emulation honesty:** most services apply on LocalStack; where one doesn't (Identity Center's provisioning-status endpoint returns 501), the module is kept correct but marked plan-mode and verified on real AWS in Week 6 (ADR-021).

## Compliance mapping

Every resource is tagged with its NIS2 measure and ISO control. NIS2 Article 21 coverage so far: measures (a), (b), (c), (f), (h), (i), (j) — 7 of 10. Remaining: (d) supply chain, (e) secure development, (g) cybersecurity hygiene [(g) arrives in Week 4].

## Status

🟢 Weeks 1–3 complete — 8 modules shipped, all tested and mapped, refactored to a shared-composition dev/prod layout. See commit history for the week-by-week build journal.
EOF
