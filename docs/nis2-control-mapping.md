# NIS2 Control Mapping — aws-nis2-baseline

Every Terraform resource in this repository maps to a specific **NIS2 Article 21(2)** measure and **ISO 27001:2022 Annex A** control. This document is the auditable bridge between the regulation and the code: for each control, the *evidence output* column names what an auditor would inspect to confirm it.

Mode key: **apply** = deployed and asserted on LocalStack + real AWS; **plan** = validated via `terraform validate` + plan-mode tests, applied on real AWS in the Week 6 validation run (see ADR-021, ADR-022).

## Foundation

| Module | Resource | NIS2 21(2) | ISO 27001:2022 | Evidence | Mode |
|---|---|---|---|---|---|
| kms | `aws_kms_key` + rotation | (h) Cryptography | A.8.24 | Key ARN, `rotation_enabled = true` | apply |
| s3-baseline | `aws_s3_bucket_public_access_block` (4 dimensions) | (i) Access control | A.8.3, A.8.22 | All four block settings = true | apply |
| s3-baseline | `aws_s3_bucket_server_side_encryption_configuration` | (h) Cryptography | A.8.24 | SSE-KMS with CMK ARN | apply |
| s3-baseline | TLS-only bucket policy (deny non-TLS) | (h) Cryptography | A.8.24 | Deny on `aws:SecureTransport = false` | apply |
| s3-baseline | SSE-KMS-required bucket policy | (h) Cryptography | A.8.24 | Deny on uploads without SSE-KMS header | apply |
| s3-baseline | `aws_s3_bucket_versioning` | (c) Business continuity | A.8.13 Information backup | Versioning = Enabled | apply |
| s3-baseline | `additional_policy_statements` injection hook | (a) Risk mgmt — module invariants | A.8.28 Secure coding | Baseline statements always present; callers append, never replace | apply |

## Logging & audit

| Module | Resource | NIS2 21(2) | ISO 27001:2022 | Evidence | Mode |
|---|---|---|---|---|---|
| cloudtrail | `aws_cloudtrail` multi-region | (b) Incident handling, (f) Effectiveness | A.8.15 Logging | `is_multi_region_trail = true` | apply |
| cloudtrail | Log file validation | (f) Effectiveness assessment | A.8.34 Protection of audit info | `LogFileValidationEnabled = true` | apply |
| cloudtrail | KMS-encrypted delivery | (h) Cryptography | A.8.24 | Trail + log group reference the CMK | apply |
| cloudtrail | CloudWatch log group, 365-day retention | (b) Incident handling (NIS2 Art.23) | A.5.33 Records retention, A.8.15 | `retentionInDays: 365` | apply |
| cloudtrail | IAM service role, trust-locked, least-privilege | (i) Access control | A.5.15, A.8.2 | Trust policy principal `cloudtrail.amazonaws.com` | apply |
| aws-config | `aws_config_configuration_recorder` (all + global) | (a) Risk analysis | A.8.9 Configuration mgmt | `allSupported: true` | apply |
| aws-config | `aws_config_delivery_channel` → S3 | (b) Incident handling | A.8.15 | Target bucket in delivery channel | apply |
| aws-config | 6 managed rules (SSE, public-read, CloudTrail, log-validation, encrypted-volumes, MFA) | (a)(f)(h)(i) | A.8.9, A.8.24, A.8.5 | Rules in `describe-config-rules` | apply |
| vpc | `aws_flow_log` (ALL traffic) → CloudWatch | (b) Incident handling | A.8.15, A.8.16 Monitoring | `TrafficType: ALL`, ACTIVE | apply |
| vpc | Public/private subnet split across 2 AZs | (b) Network security | A.8.22 Segregation of networks | 2 public + 2 private subnets | apply |
| vpc | KMS-encrypted flow-log group (365d) | (h) Cryptography | A.8.24, A.5.33 | `kmsKeyId` + `retentionInDays: 365` | apply |
| vpc | `aws_default_security_group` deny-all | (b) Network security | A.8.22 | Default SG has no ingress/egress | apply |

## Identity & governance

| Module | Resource | NIS2 21(2) | ISO 27001:2022 | Evidence | Mode |
|---|---|---|---|---|---|
| organizations | `aws_organizations_organization` feature_set ALL | (i) Access control | A.5.15 | FeatureSet ALL + SCP type ENABLED | apply |
| organizations | 3 OUs (Workloads/Security/Sandbox) | (i) Access control | A.5.15, A.5.18 | 3 OUs under root | apply |
| organizations | Trusted service access (cloudtrail/config/sso) | (i) Access control | A.5.15 | `aws_service_access_principals` | apply |
| scp | SCP `deny-root-user` | (i) Access control | A.5.15, A.8.2 | Denies on `aws:PrincipalArn` :root | apply |
| scp | SCP `region-lock` (eu-central-1 + global exceptions) | (i) Access control + EU residency | A.5.15, A.8.22 | `StringNotEquals aws:RequestedRegion` | apply |
| scp | SCP `protect-logging-layer` | (b) Incident handling, (f) Effectiveness | A.8.15, A.8.34 | Denies CloudTrail/Config disable | apply |
| scp | 9 attachments (3 SCPs × 3 OUs) | (i) Access control org-wide | A.5.15 | `list-policies-for-target` per OU | apply |
| identity-center | Permission sets Administrator + ReadOnly (PT1H) | (i) Access control, (j) Secure auth | A.5.15, A.8.5 | Short `session_duration` | plan |
| identity-center | `aws_identitystore_group` + account assignment | (i) Access control, (j) MFA/SSO | A.5.17, A.5.18 | Group bound to admin permission set | plan |

## Detection & alerting

| Module | Resource | NIS2 21(2) | ISO 27001:2022 | Evidence | Mode |
|---|---|---|---|---|---|
| guardduty | `aws_guardduty_detector` (15-min publishing) | (b) Incident handling, (g) Cyber hygiene | A.8.16, A.5.7 Threat intel | Detector + finding cadence | plan |
| guardduty | S3 data-event + EBS malware features | (g) Cyber hygiene | A.8.16, A.8.7 Malware protection | `detector_feature` (provider v5) | plan |
| security-hub | `aws_securityhub_account` + FSBP standard | (e) Vuln handling, (g) Cyber hygiene | A.8.8, A.5.36 | FSBP subscription | plan |
| security-hub | GuardDuty product subscription | (b) Incident handling | A.5.7 | References product ARN (decoupled) | plan |
| alerting | KMS-encrypted `aws_sns_topic` + policies | (b) Incident handling | A.5.24, A.8.24 | Topic + key policy grant EventBridge | apply |
| alerting | EventBridge rules (GuardDuty + Security Hub findings) | (b) Incident handling | A.5.25, A.5.26 | Match event pattern, not producer ARN | apply |
| s3-baseline | `aws_s3_bucket_notification` eventbridge=true | (b) Incident handling | A.8.16 | Object events → EventBridge | apply |

## Coverage summary

| Measure | Topic | Covered by |
|---|---|---|
| (a) | Risk analysis & security policies | aws-config |
| (b) | Incident handling | cloudtrail, vpc, guardduty, alerting |
| (c) | Business continuity & backup | s3-baseline |
| (d) | **Supply chain security** | documentation — see [supply-chain.md](supply-chain.md) |
| (e) | Acquisition, development, vuln handling | security-hub |
| (f) | Effectiveness assessment | cloudtrail, aws-config |
| (g) | Basic cyber hygiene | guardduty, security-hub |
| (h) | Cryptography & encryption | kms, s3-baseline (SSE-KMS throughout) |
| (i) | Access control | organizations, scp, identity-center |
| (j) | Multi-factor authentication | identity-center |

**10 of 10 measures** once (d) is counted (closed as documentation in [supply-chain.md](supply-chain.md)). 9 of 10 are implemented as deployed Terraform.

> Engineering evidence (CI pipeline, test suites, scanner SARIF uploads) also supports measures (a), (e), and (f) — see the CI workflows and each module's `tests/` directory.
