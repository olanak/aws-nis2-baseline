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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
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
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.cloudtrail_to_cwl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudtrail_to_cwl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Retention period for the CloudWatch Log Group. NIS2 Art. 23 requires retention to support 1-month incident reporting. | `number` | `365` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Capture events across ALL regions. Default true (NIS2 effectiveness requires global visibility). | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS CMK ARN to encrypt CloudTrail logs at rest. Pass from modules/kms output. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket where CloudTrail will deliver logs. Must already exist (typically the logs bucket from modules/s3-baseline). | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | Optional S3 key prefix for CloudTrail logs within the bucket. | `string` | `"cloudtrail/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the trail and related resources. | `map(string)` | `{}` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Name of the CloudTrail trail. Lowercase, hyphens allowed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch Log Group receiving trail events. Used by Week 4 detection module. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch Log Group. |
| <a name="output_trail_arn"></a> [trail\_arn](#output\_trail\_arn) | ARN of the CloudTrail trail. |
| <a name="output_trail_name"></a> [trail\_name](#output\_trail\_name) | Name of the CloudTrail trail. |
<!-- END_TF_DOCS -->