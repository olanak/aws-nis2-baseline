# guardduty module

Enables Amazon GuardDuty threat detection: a regional detector plus S3 data-event and EBS malware-protection features. GuardDuty continuously analyzes CloudTrail management events, VPC Flow Logs, and DNS query logs for known-bad and anomalous behavior — no per-source wiring required.

**Plan-mode (ADR-022):** LocalStack does not implement GuardDuty, so this module is validated via `terraform validate` + plan-mode `terraform test` and applied for real only in the Week 6 AWS run.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| GuardDuty detector | (b) incident handling, (g) cyber hygiene | A.8.16 monitoring |
| S3 data-event protection | (g) cyber hygiene | A.8.16 |
| Malware protection | (g) cyber hygiene | A.8.7 malware protection |
| Finding publishing (15-min) | (b) incident handling | A.5.7 threat intelligence |

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
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_detector_feature.malware_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.s3_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_malware_protection"></a> [enable\_malware\_protection](#input\_enable\_malware\_protection) | Enable GuardDuty EBS malware scanning on suspicious findings. | `bool` | `true` | no |
| <a name="input_enable_s3_protection"></a> [enable\_s3\_protection](#input\_enable\_s3\_protection) | Enable GuardDuty S3 data-event monitoring. | `bool` | `true` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | How often GuardDuty exports findings to EventBridge/Security Hub. FIFTEEN\_MINUTES gives the tightest detection-to-alert latency (NIS2 incident handling). | `string` | `"FIFTEEN_MINUTES"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the detector. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_detector_arn"></a> [detector\_arn](#output\_detector\_arn) | The GuardDuty detector ARN. |
| <a name="output_detector_id"></a> [detector\_id](#output\_detector\_id) | The GuardDuty detector ID (consumed by Security Hub product subscription). |
<!-- END_TF_DOCS -->