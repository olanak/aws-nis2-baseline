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
| [aws_securityhub_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_product_subscription.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | resource |
| [aws_securityhub_standards_subscription.fsbp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_default_standards"></a> [enable\_default\_standards](#input\_enable\_default\_standards) | Whether Security Hub auto-enables its default standards on activation. Set false so we control standards explicitly (only FSBP). | `bool` | `false` | no |
| <a name="input_enable_guardduty_integration"></a> [enable\_guardduty\_integration](#input\_enable\_guardduty\_integration) | Subscribe to GuardDuty as a finding product so its findings flow into Security Hub. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The Security Hub account resource ID. |
| <a name="output_fsbp_standard_arn"></a> [fsbp\_standard\_arn](#output\_fsbp\_standard\_arn) | The subscribed FSBP standard ARN. |
| <a name="output_guardduty_integration_enabled"></a> [guardduty\_integration\_enabled](#output\_guardduty\_integration\_enabled) | Whether the GuardDuty product subscription is active. |
<!-- END_TF_DOCS -->