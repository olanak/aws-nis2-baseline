# scp module

Three Service Control Policies attached to OUs (or the org root) as guardrails:

1. **deny-root-user** — denies all actions by the root user
2. **region-lock** — denies operations outside the allowed region (EU data residency), excepting global services
3. **protect-logging-layer** — denies disabling CloudTrail and Config

SCPs are guardrails, not grants: they only restrict what IAM otherwise allows.

## NIS2 & ISO 27001 mapping

| SCP | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| deny-root-user | (i) access control | A.5.15, A.8.2 |
| region-lock | (i) access control | A.5.15, A.8.22 |
| protect-logging-layer | (b) incident handling, (f) effectiveness | A.8.15, A.8.34 |

## Example

```hcl
module "scp" {
  source     = "../../modules/scp"
  target_ids = values(module.organizations.ou_ids)
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
| [aws_organizations_policy.deny_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.protect_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.region_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_iam_policy_document.deny_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.protect_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.region_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_region"></a> [allowed\_region](#input\_allowed\_region) | The only region operations are permitted in (EU data residency). | `string` | `"eu-central-1"` | no |
| <a name="input_global_service_exceptions"></a> [global\_service\_exceptions](#input\_global\_service\_exceptions) | Global-service actions that must stay reachable even under a region lock (these services are region-agnostic). | `list(string)` | <pre>[<br/>  "iam:*",<br/>  "organizations:*",<br/>  "sts:*",<br/>  "cloudfront:*",<br/>  "route53:*",<br/>  "support:*",<br/>  "waf:*"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied where supported. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | Map of target NAME -> OU/account ID to attach SCPs to. Keys must be known at plan time (names), values may be apply-time (IDs). | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attachment_count"></a> [attachment\_count](#output\_attachment\_count) | Number of policy-to-target attachments created. |
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | Map of SCP name -> policy id. |
<!-- END_TF_DOCS -->