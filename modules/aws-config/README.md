# aws-config module

Provisions AWS Config: a configuration recorder, delivery channel to S3, a service role, and a curated set of NIS2-aligned managed rules for continuous compliance evaluation.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Configuration recorder | (a) risk analysis | A.8.9 configuration management |
| Delivery channel to S3 | (b) incident handling | A.8.15 logging |
| IAM service role | (i) access control | A.5.15 |
| Managed rules (encryption, public access, MFA, CloudTrail) | (a)(f)(h)(i) | A.8.3, A.8.5, A.8.24, A.8.34 |

## Example

```hcl
module "aws_config_demo" {
  source = "../../modules/aws-config"

  recorder_name         = "nis2-demo-recorder"
  delivery_channel_name = "nis2-demo-delivery"
  role_name             = "nis2-demo-config-role"
  s3_bucket_name        = module.s3_baseline_logs.bucket_id
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->