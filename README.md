# aws-nis2-baseline

[![CI](https://github.com/olanak/aws-nis2-baseline/actions/workflows/ci.yml/badge.svg)](https://github.com/olanak/aws-nis2-baseline/actions/workflows/ci.yml)
[![terraform-docs](https://github.com/olanak/aws-nis2-baseline/actions/workflows/docs.yml/badge.svg)](https://github.com/olanak/aws-nis2-baseline/actions/workflows/docs.yml)
![Terraform](https://img.shields.io/badge/terraform-%E2%89%A5%201.9-7B42BC?logo=terraform)
![LocalStack](https://img.shields.io/badge/tested%20on-LocalStack%20Pro-4D29B4)
![License](https://img.shields.io/badge/license-MIT-green)

> A modular Terraform AWS landing zone where every control maps to a specific **NIS2 Article 21(2)** measure and **ISO 27001:2022 Annex A** control. Developed and tested at zero cost on LocalStack Pro, with a single real-AWS validation run for final proof.

## Why this exists

EU regulated-industry teams (FinTech, consulting, cloud vendors) increasingly have to demonstrate NIS2 conformance in their infrastructure-as-code, not just in policy documents. This project is a working reference: a security baseline where the regulatory requirement, the Terraform that implements it, and the test that proves it all live together and travel together. Each module answers one question — *which NIS2 measure does this satisfy, and how would an auditor verify it?*

## NIS2 Article 21(2) coverage

| Measure | Topic | Status | Implemented by |
|---|---|---|---|
| (a) | Risk analysis & security policies | ✅ | aws-config |
| (b) | Incident handling | ✅ | cloudtrail, vpc, guardduty, alerting |
| (c) | Business continuity & backup | ✅ | s3-baseline |
| (d) | Supply chain security | ✅ | documentation ([docs/supply-chain.md](docs/supply-chain.md)) |
| (e) | Acquisition, development, vuln handling | ✅ | security-hub |
| (f) | Effectiveness assessment | ✅ | cloudtrail, aws-config |
| (g) | Basic cyber hygiene | ✅ | guardduty, security-hub |
| (h) | Cryptography & encryption | ✅ | kms, s3-baseline |
| (i) | Access control & asset management | ✅ | organizations, scp, identity-center |
| (j) | Multi-factor authentication | ✅ | identity-center |

**10 of 10 measures addressed** — 9 as deployed Terraform, (d) supply chain as documented architecture/posture ([docs/supply-chain.md](docs/supply-chain.md)).

## Modules

| Module | Purpose | Mode | NIS2 | ISO 27001:2022 |
|---|---|---|---|---|
| `kms` | Customer-managed CMK, rotation, alias | apply | (h) | A.8.24 |
| `s3-baseline` | Secure-by-default bucket (SSE-KMS, TLS-only, versioned, EventBridge) + policy-injection hook | apply | (c)(h) | A.8.13, A.8.24 |
| `cloudtrail` | Multi-region trail, log-file validation, KMS-encrypted, 365-day retention | apply | (b)(f) | A.8.15, A.8.34 |
| `aws-config` | Recorder + delivery channel + 6 NIS2-aligned managed rules | apply | (a)(f) | A.8.9 |
| `vpc` | Two-AZ VPC, public/private subnets, NAT, VPC Flow Logs | apply | (b) | A.8.16, A.8.22 |
| `organizations` | AWS Organization, feature-set ALL, 3 OUs | apply | (i) | A.5.15 |
| `scp` | 3 Service Control Policies (deny-root, region-lock, protect-logging) × 3 OUs | apply | (i) | A.5.15, A.8.22 |
| `identity-center` | SSO permission sets (short sessions), group + assignment | plan¹ | (i)(j) | A.5.15, A.8.5 |
| `guardduty` | Threat-detection detector + S3/malware features | plan² | (b)(g) | A.8.16, A.5.7 |
| `security-hub` | Security Hub + AWS FSBP standard + GuardDuty integration | plan² | (e)(g) | A.8.8, A.5.36 |
| `alerting` | KMS-encrypted SNS topic + EventBridge rules → centralized findings channel | apply | (b) | A.5.24–A.5.26 |

¹ *plan-mode:* LocalStack emulates SSO creation but not the provisioning-status endpoint the provider polls after a managed-policy attachment (ADR-021).
² *plan-mode:* LocalStack does not implement GuardDuty or Security Hub at all (ADR-022).
*Plan-mode modules are correct, validated Terraform; their `apply` is proven on real AWS in the Week 6 validation run rather than against the emulator.*

## Repository structure

```text
aws-nis2-baseline/
├── modules/                    # Reusable, single-purpose modules — each with its own tests/
│   ├── kms/ · s3-baseline/                       # Foundation
│   ├── cloudtrail/ · aws-config/ · vpc/          # Logging & audit
│   ├── organizations/ · scp/ · identity-center/  # Identity & governance
│   └── guardduty/ · security-hub/ · alerting/    # Detection & alerting
├── environments/
│   ├── _composition/           # Shared module wiring — provider-agnostic, the single
│   │                           #   source of truth for "what gets deployed"
│   ├── dev/                    # Thin wrapper → LocalStack provider + endpoints
│   └── prod/                   # Thin wrapper → real AWS provider + remote backend
├── tests/                      # Root integration test — applies the full composition
├── docs/                       # Architecture, NIS2 mapping, ISO crosswalk, supply chain, learning log
├── .github/workflows/          # CI: fmt · validate · tflint · tfsec · Checkov · test · Infracost
├── Makefile
└── docker-compose.yml
```

`dev` and `prod` are thin wrappers over the same `_composition`. The module wiring exists exactly once, so the environments cannot drift — the "identical infrastructure on LocalStack and real AWS" guarantee is structural, not maintained by hand.

## Architecture

KMS is the cryptographic root: its customer-managed key encrypts the S3 log bucket, CloudTrail, and the VPC flow logs. The S3 baseline bucket is the shared log sink — CloudTrail and AWS Config both deliver to it, with their delivery permissions injected through the bucket module's `additional_policy_statements` hook so the baseline guarantees (TLS-only, SSE-KMS-required) can be extended but never overridden.

AWS Organizations and SCPs wrap the account in governance guardrails — including one that forbids disabling CloudTrail or Config, so the audit layer can't be silently switched off. The detection layer (GuardDuty + Security Hub) feeds findings into a single KMS-encrypted SNS topic via EventBridge rules, giving one coherent alerting channel instead of per-service notifications.

See [docs/architecture.md](docs/architecture.md) for the full composition graph, data flows, and environment structure.

## Documentation

| Doc | Covers |
|---|---|
| [architecture.md](docs/architecture.md) | Composition, data flows, dev/prod structure |
| [nis2-control-mapping.md](docs/nis2-control-mapping.md) | Resource → NIS2 measure → ISO control → audit evidence |
| [iso27001-crosswalk.md](docs/iso27001-crosswalk.md) | NIS2 Article 21 → ISO 27001:2022 Annex A |
| [supply-chain.md](docs/supply-chain.md) | Supply-chain posture (measure d) |
| [learning-log.md](docs/learning-log.md) | Curated engineering decisions |

## Quick start

```bash
# Requires Docker + a LocalStack Pro auth token in LOCALSTACK_AUTH_TOKEN
make up                          # start LocalStack Pro
cd environments/dev
terraform init
terraform apply -auto-approve    # deploy the apply-mode composition to LocalStack
cd ../..
make test                        # all module test suites + the integration test
```

## Testing & validation

- **Native `terraform test`** — every module has its own suite (positive defaults, security-critical assertions, and a negative `expect_failures` case); a root integration test applies the full multi-module composition and asserts on its outputs.
- **Apply-mode vs plan-mode** — modules LocalStack fully supports are applied and asserted for real; modules it doesn't (SSO provisioning-status, GuardDuty, Security Hub) are validated by `terraform validate` + plan-mode tests and proven on real AWS in Week 6. Which is which, and why, is documented in the ADRs — distinguishing "the code is wrong" from "the emulator doesn't implement this" is treated as part of the work.
- **One paid validation run** — a single real-AWS deploy (under €15, budget-controlled, destroyed immediately) closes the "did it ever run on real AWS?" question for the plan-mode modules and the IAM/KMS policy chains LocalStack can't enforce.

## CI & engineering hygiene

Every pull request runs `terraform fmt`, `tflint`, `tfsec`, `Checkov`, `Infracost`, `terraform-docs`, and the full `terraform test` suite against a LocalStack Pro service container, behind branch protection on `main`.

Scanner findings are not chased to a misleading zero. They are triaged in a documented decision matrix — **Fixed / Deferred / Accepted / Suppressed-with-reason** — that lives alongside the code, so a reviewer can see what was flagged, what was decided, and why. Managing risk transparently is itself the GRC signal a regulated-industry reviewer is looking for.

## Development model

- **LocalStack Pro** (Student plan) for all development and CI — full service parity, zero cloud spend.
- **Provider-agnostic modules + composition**, with LocalStack vs AWS isolated to the thin environment wrappers.
- **Plan-mode honesty** — emulator gaps are documented as ADRs (021, 022), not hidden behind feature flags or pretended away.
- **Real-AWS validation** reserved for a single Week 6 run with budget alarms and immediate teardown.

## Status

🟢 **Build complete** — 11 modules across 4 layers, **10 of 10 NIS2 Article 21(2) measures** addressed (9 as deployed Terraform, 1 as documented architecture), shared-composition dev/prod layout, full documentation set, CI green end-to-end. All development and testing on LocalStack Pro at zero cost. The optional real-AWS validation run (Week 6) confirms the plan-mode modules and IAM/KMS policy chains against an enforcing cloud. See the build-journal blog series for the week-by-week story.

## License

MIT — see [LICENSE](LICENSE).