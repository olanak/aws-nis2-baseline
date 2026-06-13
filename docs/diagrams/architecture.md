# Architecture — aws-nis2-baseline

## Module composition (end of Week 2)

```mermaid
graph TD
    KMS["modules/kms<br/>CMK + rotation<br/>NIS2 21(2)(h) / ISO A.8.24"]

    S3["modules/s3-baseline<br/>SSE-KMS, TLS-only, versioned<br/>+ additional_policy_statements hook<br/>NIS2 21(2)(c)(h) / ISO A.8.13"]

    CT["modules/cloudtrail<br/>multi-region trail<br/>log file validation<br/>NIS2 21(2)(b)(f) / ISO A.8.15 A.8.34"]

    CFG["modules/aws-config<br/>recorder + delivery channel<br/>6 managed rules<br/>NIS2 21(2)(a) / ISO A.8.9"]

    VPC["modules/vpc<br/>2-AZ, public/private subnets<br/>NAT + Flow Logs<br/>NIS2 21(2)(b) / ISO A.8.16 A.8.22"]

    KMS -->|key_arn| S3
    KMS -->|key_arn| CT
    KMS -->|key_arn| VPC

    S3 -->|bucket via DI hook| CT
    S3 -->|bucket via DI hook| CFG

    CT -.->|logs to| CWL["CloudWatch Logs"]
    VPC -.->|flow logs to| CWL
    CFG -.->|snapshots to| S3

    classDef crypto fill:#1a2332,stroke:#4a9eff,color:#cfe8ff
    classDef storage fill:#1a2b1f,stroke:#4ade80,color:#d1fae5
    classDef logging fill:#2b1a2e,stroke:#c084fc,color:#f3e8ff
    classDef network fill:#2b2419,stroke:#fbbf24,color:#fef3c7

    class KMS crypto
    class S3 storage
    class CT,CFG logging
    class VPC network
```

## Data flows

- **KMS is the crypto root.** Its CMK encrypts S3 objects, CloudTrail logs, the CloudTrail CloudWatch Log Group, and the VPC flow-log group.
- **The S3 baseline bucket is the shared log sink.** CloudTrail and AWS Config both deliver to it. Their delivery permissions are injected via the `additional_policy_statements` dependency-injection hook — the bucket module's baseline guarantees (TLS-only, SSE-KMS) are preserved while callers add what they need.
- **CloudWatch Logs is the real-time stream.** CloudTrail and VPC Flow Logs both publish there, setting up the Week 4 detection layer (EventBridge → SNS).
- **AWS Config continuously evaluates** the deployed resources against 6 NIS2-aligned managed rules.

## NIS2 Article 21 coverage (end of Week 2)

| Measure | Covered by |
|---|---|
| (a) Risk analysis policies | AWS Config rules |
| (b) Incident handling | CloudTrail, VPC Flow Logs |
| (c) Business continuity | S3 versioning |
| (f) Effectiveness assessment | CloudTrail log file validation |
| (h) Cryptography | KMS, SSE-KMS everywhere |
| (i) Access control | IAM service roles (least-privilege) |

Coming in Week 3 (Identity) and Week 4 (Detection): (d) supply chain, (e) secure acquisition, (g) hygiene, (j) MFA.