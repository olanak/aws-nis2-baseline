# NIS2 → ISO 27001:2022 Crosswalk — aws-nis2-baseline

NIS2 Article 21(2) lists *what* a security program must address; ISO 27001:2022 Annex A lists *controls* that implement those obligations. The two are complementary, and an organization already running an ISO 27001 ISMS can reuse most of its control evidence to demonstrate NIS2 conformance. This document is that bridge: for each NIS2 Article 21(2) measure, the corresponding ISO 27001:2022 Annex A controls, and where this repository implements them.

This crosswalk is interpretive, not official — NIS2 does not mandate ISO 27001, and the mapping reflects a defensible reading rather than a certified equivalence. It is meant to show how the two frameworks reinforce each other in practice.

## Crosswalk

### (a) Risk analysis and information system security policies
- **ISO:** A.5.1 Policies for information security · A.8.9 Configuration management
- **Here:** AWS Config continuously evaluates deployed resources against 6 managed rules; the decision matrix records risk acceptance/treatment per finding.

### (b) Incident handling
- **ISO:** A.5.24 Incident management planning & preparation · A.5.25 Assessment & decision on events · A.5.26 Response to incidents · A.8.15 Logging · A.8.16 Monitoring activities
- **Here:** CloudTrail + VPC Flow Logs (logging), GuardDuty (detection), Alerting module (EventBridge → SNS response routing).

### (c) Business continuity, backup management, crisis management
- **ISO:** A.5.29 Information security during disruption · A.5.30 ICT readiness for business continuity · A.8.13 Information backup
- **Here:** S3 versioning on the log bucket; KMS key rotation preserves access to historical encrypted data.

### (d) Supply chain security
- **ISO:** A.5.19 Information security in supplier relationships · A.5.20 Addressing security within supplier agreements · A.5.21 Managing security in the ICT supply chain · A.5.23 Information security for use of cloud services
- **Here:** Documented in [supply-chain.md](supply-chain.md) — provider/module version pinning, `.terraform.lock.hcl` provenance, pinned LocalStack image, and the cloud-service (AWS) relationship posture.

### (e) Security in acquisition, development and maintenance, vulnerability handling and disclosure
- **ISO:** A.8.8 Management of technical vulnerabilities · A.8.25 Secure development life cycle · A.8.28 Secure coding · A.5.36 Compliance with policies & standards
- **Here:** Security Hub with the AWS FSBP standard (vulnerability/posture scoring); the CI pipeline (fmt, tflint, tfsec, Checkov) enforces secure-development practice on every PR.

### (f) Policies and procedures to assess effectiveness
- **ISO:** A.5.35 Independent review of information security · A.5.36 Compliance with policies · A.8.34 Protection of information systems during audit testing
- **Here:** CloudTrail log file validation (tamper-evidence), AWS Config rules (continuous compliance), the `terraform test` suites + integration test (the controls are tested, not just declared).

### (g) Basic cyber hygiene practices and security training
- **ISO:** A.5.7 Threat intelligence · A.8.7 Protection against malware · A.8.16 Monitoring activities
- **Here:** GuardDuty (threat detection + malware protection), Security Hub (baseline hygiene scoring). *Training is organizational, outside an IaC repo's scope.*

### (h) Cryptography and, where appropriate, encryption
- **ISO:** A.8.24 Use of cryptography
- **Here:** KMS customer-managed keys with rotation; SSE-KMS on S3, CloudTrail, flow logs, and the alerting SNS topic; TLS-only and SSE-KMS-required bucket policies.

### (i) Human resources security, access control policies, asset management
- **ISO:** A.5.15 Access control · A.5.17 Authentication information · A.5.18 Access rights · A.8.2 Privileged access rights · A.8.3 Information access restriction
- **Here:** AWS Organizations + 3 SCPs (deny-root, region-lock, protect-logging), IAM Identity Center permission sets with short sessions.

### (j) Use of multi-factor authentication and secured communications
- **ISO:** A.5.16 Identity management · A.8.5 Secure authentication
- **Here:** IAM Identity Center (SSO-fronted, MFA-enforced workforce access, short-lived sessions) replacing long-lived IAM users.

## Summary table

| NIS2 21(2) | Primary ISO 27001:2022 Annex A controls | Implemented by |
|---|---|---|
| (a) Risk analysis & policies | A.5.1, A.8.9 | aws-config |
| (b) Incident handling | A.5.24–A.5.26, A.8.15, A.8.16 | cloudtrail, vpc, guardduty, alerting |
| (c) Business continuity | A.5.29, A.5.30, A.8.13 | s3-baseline, kms |
| (d) Supply chain | A.5.19–A.5.21, A.5.23 | supply-chain.md |
| (e) Acquisition, dev, vuln handling | A.8.8, A.8.25, A.8.28, A.5.36 | security-hub, CI pipeline |
| (f) Effectiveness assessment | A.5.35, A.5.36, A.8.34 | cloudtrail, aws-config, tests |
| (g) Cyber hygiene | A.5.7, A.8.7, A.8.16 | guardduty, security-hub |
| (h) Cryptography | A.8.24 | kms, s3-baseline |
| (i) Access control | A.5.15, A.5.17, A.5.18, A.8.2, A.8.3 | organizations, scp, identity-center |
| (j) MFA & secure comms | A.5.16, A.8.5 | identity-center |

## How to use this crosswalk

- **For a NIS2 audit:** start from the Article 21(2) measure, follow to the implementing module, then to that module's evidence output in [nis2-control-mapping.md](nis2-control-mapping.md).
- **For an ISO 27001 ISMS:** the Annex A controls above are partially evidenced by this infrastructure; the same Terraform + test artifacts serve as control evidence for both frameworks.
- **Scope note:** some ISO controls (training, HR vetting, physical security, supplier contracts) are organizational and fall outside an infrastructure repository. Those are noted inline rather than claimed.
