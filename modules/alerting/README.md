# alerting module

Centralized detection alerting: a KMS-encrypted SNS topic fed by EventBridge rules that match GuardDuty and Security Hub findings. All detection sources route through this single channel rather than each wiring its own notifications — the deferred per-trail SNS notification (CloudTrail) resolves here.

Rules match on event **pattern** (`source`, `detail-type`), not on the detection modules' resource ARNs, so this apply-mode module stays decoupled from the plan-mode GuardDuty/Security Hub modules.

## The KMS<->SNS<->EventBridge permission chain
An encrypted SNS topic that EventBridge publishes to needs two grants, both included here: the SNS topic policy allows `events.amazonaws.com` to `sns:Publish`, and the KMS key policy allows that principal `kms:GenerateDataKey*` + `kms:Decrypt`. LocalStack does not enforce KMS key policies, so this is correct-but-unverified locally; the Week 6 real-AWS run confirms it.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Encrypted SNS topic | (b) incident handling | A.5.24 incident planning, A.8.24 crypto |
| EventBridge GuardDuty rule | (b) incident handling | A.5.25 assessment of events |
| EventBridge Security Hub rule | (b) incident handling | A.5.25, A.5.26 response |

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
| [aws_cloudwatch_event_rule.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.guardduty_to_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.securityhub_to_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_kms_alias.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sns_topic.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_email"></a> [alert\_email](#input\_alert\_email) | Optional email to subscribe to alerts. Empty = no subscription (real subscriptions need out-of-band confirmation; left off for LocalStack/CI). | `string` | `""` | no |
| <a name="input_min_severity_label"></a> [min\_severity\_label](#input\_min\_severity\_label) | Minimum GuardDuty severity label to alert on (LOW/MEDIUM/HIGH). GuardDuty numeric: LOW>=1, MEDIUM>=4, HIGH>=7. | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the topic and key. | `map(string)` | `{}` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the SNS topic that receives detection alerts. | `string` | `"nis2-security-alerts"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_rule_arn"></a> [guardduty\_rule\_arn](#output\_guardduty\_rule\_arn) | ARN of the GuardDuty-finding EventBridge rule. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the CMK encrypting the alerts topic. |
| <a name="output_securityhub_rule_arn"></a> [securityhub\_rule\_arn](#output\_securityhub\_rule\_arn) | ARN of the Security Hub-finding EventBridge rule. |
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | ARN of the security-alerts SNS topic. |
<!-- END_TF_DOCS -->