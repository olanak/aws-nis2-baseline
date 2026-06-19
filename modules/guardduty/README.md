# guardduty module

Enables Amazon GuardDuty threat detection: a regional detector plus S3 data-event and EBS malware-protection features. GuardDuty continuously analyzes CloudTrail management events, VPC Flow Logs, and DNS query logs for known-bad and anomalous behavior — no per-source wiring required.

**Plan-mode (ADR-022):** LocalStack does not implement GuardDuty, so this module is validated via `terraform validate` + plan-mode `terraform test` and applied for real only in the Week 6 AWS run.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| GuardDuty detector | (b) incident handling, (g) cyber hygiene | A.8.16 monitoring |
| S3 data-event protection | (g) cyber hygiene | A.8.16 |
| Malware protection | (g) cyber hygiene | A.8.7 malware protection |
| Finding publishing (15-min) | (b) incident handling | A.5.7 threat intelligence |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->