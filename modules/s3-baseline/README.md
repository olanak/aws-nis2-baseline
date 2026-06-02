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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Globally-unique S3 bucket name. Lowercase, 3-63 chars, no underscores. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow Terraform to destroy a non-empty bucket. KEEP FALSE in production. True only for ephemeral demos. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS CMK to use for SSE-KMS encryption. Pass from the kms module's output. | `string` | n/a | yes |
| <a name="input_lifecycle_enabled"></a> [lifecycle\_enabled](#input\_lifecycle\_enabled) | Enable lifecycle rules. Disable on LocalStack (timeout issue). Always true on real AWS. | `bool` | `false` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | Bucket to send access logs to. If null, logging is disabled (e.g. for the log bucket itself). | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Object key prefix for delivered access logs. | `string` | `"access-logs/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the bucket and related resources. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable S3 versioning. Required for NIS2 (c) business continuity. Default: true. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Full ARN of the bucket. Used by other modules (CloudTrail, log destinations, etc.). |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket name (S3 bucket IDs == bucket names). |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Regional domain name. Use this in CloudFront / cross-region replication. |
<!-- END_TF_DOCS -->