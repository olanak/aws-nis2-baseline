# s3-baseline module

A hardened S3 bucket module: SSE-KMS encryption, all-four public-access dimensions blocked, TLS-only bucket policy, SSE enforcement on uploads, versioning, lifecycle rules, conditional access logging.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 Annex A |
|---|---|---|
| SSE-KMS encryption | (h) cryptography | A.8.24 |
| Public access block | (e) network security | A.8.22 |
| TLS-only policy | (h) cryptography in transit | A.8.21, A.8.24 |
| Versioning | (c) business continuity | A.8.13 |
| Access logging (optional) | (b) incident handling, (f) effectiveness | A.8.15, A.8.16 |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->