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

## Architecture

See [docs/diagrams/architecture.md](docs/diagrams/architecture.md) for the module composition graph and data flows.

In brief: KMS is the cryptographic root (its CMK encrypts S3, CloudTrail, and flow logs). The S3 baseline bucket is the shared log sink — CloudTrail and AWS Config both deliver to it, with their permissions injected through the bucket module's `additional_policy_statements` hook so the baseline security guarantees are never overridden. CloudTrail and VPC Flow Logs publish to CloudWatch Logs, setting up the detection layer in Week 4.

## Quick start

```bash
# Requires Docker + LocalStack Pro auth token in LOCALSTACK_AUTH_TOKEN
make up                       # start LocalStack
cd environments/demo
terraform init
terraform apply -auto-approve # deploy the full composition
cd ../..
make test                     # run all module tests + integration test
```

## Development model

- **LocalStack Pro** (Student plan) for all development and CI — full service parity, zero spend.
- **Real AWS** for a single Week 6 validation run, under €15, with budget controls and immediate destroy.
- **CI on every PR:** terraform fmt, tflint, tfsec, Checkov, Infracost, terraform-docs, and `terraform test` (module + integration). Branch protection enforced.
- **Scanner findings** are triaged in a documented decision matrix (managed risk, not zero-findings theater), not silently suppressed.

## Compliance mapping

Every resource is tagged with its NIS2 measure and ISO control. The full mapping lives in the project's control-mapping documentation. NIS2 Article 21 coverage after Week 2: measures (a), (b), (c), (f), (h), (i). Weeks 3–4 add (d), (e), (g), (j).

## Status

🟢 Weeks 1–2 complete — 5 modules shipped, all tested and mapped. See commit history for the week-by-week build journal.