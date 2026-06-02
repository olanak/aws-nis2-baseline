# kms module

A reusable Terraform module that provisions a KMS Customer Managed Key with rotation enabled, an alias, and regulatory traceability tags.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 Annex A |
|---|---|---|
| KMS CMK with rotation | (h) cryptography | A.8.24 use of cryptography |

## Example

```hcl
module "kms_logs" {
  source = "../../modules/kms"

  key_alias   = "nis2-logs"
  description = "CMK for log buckets"
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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Waiting period before key deletion (7-30 days). NIS2 favors longer windows to prevent accidental data loss. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of what this key encrypts. | `string` | n/a | yes |
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | Alias for the KMS key (without the 'alias/' prefix). Example: 'nis2-s3-baseline' | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the key. Recommended: nis2\_control, iso\_control, data\_classification. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | The ARN of the alias. |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | The full alias name (with 'alias/' prefix). |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The full ARN of the KMS key. Used by other modules (S3, CloudTrail, etc.) to reference this key. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique KMS key ID. |
<!-- END_TF_DOCS -->