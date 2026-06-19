# security-hub module

Enables AWS Security Hub with the AWS Foundational Security Best Practices (FSBP) standard and a GuardDuty product subscription, so GuardDuty findings aggregate into a single, scored compliance view.

FSBP is the AWS-native baseline; it overlaps heavily with CIS, so this module subscribes to FSBP only and leaves additional standards as a documented, one-line extension (`aws_securityhub_standards_subscription`).

**Plan-mode (ADR-022):** LocalStack does not implement Security Hub, so this module is validated via `terraform validate` + plan-mode `terraform test` and applied for real only in the Week 6 AWS run.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Security Hub account | (e) vuln handling, (g) cyber hygiene | A.8.8 technical vulnerabilities |
| FSBP standard subscription | (e)(g) | A.8.8, A.5.36 compliance |
| GuardDuty product subscription | (b) incident handling | A.5.7 threat intelligence |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->