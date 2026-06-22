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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_config_config_rule.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.s3_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.config_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.s3_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delivery_channel_name"></a> [delivery\_channel\_name](#input\_delivery\_channel\_name) | Name of the AWS Config delivery channel. | `string` | n/a | yes |
| <a name="input_enable_rules"></a> [enable\_rules](#input\_enable\_rules) | Whether to deploy the curated set of NIS2-aligned managed Config rules. | `bool` | `true` | no |
| <a name="input_include_global_resource_types"></a> [include\_global\_resource\_types](#input\_include\_global\_resource\_types) | Record global resources (IAM users, roles, policies). Should be true on exactly one region in a multi-region setup. | `bool` | `true` | no |
| <a name="input_recorder_name"></a> [recorder\_name](#input\_recorder\_name) | Name of the AWS Config configuration recorder. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM service role AWS Config assumes. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket where Config delivers configuration snapshots/history. Typically the shared logs bucket. | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | Optional S3 key prefix for Config deliverables. | `string` | `"config"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to Config resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delivery_channel_id"></a> [delivery\_channel\_id](#output\_delivery\_channel\_id) | ID of the Config delivery channel. |
| <a name="output_recorder_name"></a> [recorder\_name](#output\_recorder\_name) | Name of the Config configuration recorder. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the Config service role. |
| <a name="output_rule_names"></a> [rule\_names](#output\_rule\_names) | Names of the deployed managed Config rules. |
<!-- END_TF_DOCS -->