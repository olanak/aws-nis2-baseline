# cloudtrail module

A reusable Terraform module that provisions a multi-region CloudTrail trail with log file integrity validation, KMS-encrypted log delivery to both S3 and CloudWatch Logs, and a least-privilege IAM service role for CWL delivery.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 Annex A |
|---|---|---|
| Multi-region trail with log file validation | (b) incident handling, (f) effectiveness | A.8.15, A.8.34 |
| KMS-encrypted logs (S3 + CWL) | (h) cryptography | A.8.24 |
| CloudWatch Log Group, 365-day retention | (b), supports NIS2 Art.23 timelines | A.5.33, A.8.15 |
| IAM service role with minimal permissions | (i) access control | A.5.15 |

## Example

```hcl
module "cloudtrail_demo" {
  source = "../../modules/cloudtrail"

  trail_name     = "nis2-demo-trail"
  s3_bucket_name = module.s3_baseline_logs.bucket_id
  s3_key_prefix  = "cloudtrail/"
  kms_key_arn    = module.kms_s3_baseline.key_arn
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->