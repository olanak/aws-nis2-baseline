# organizations module

Creates an AWS Organization with `feature_set = ALL` (required for SCPs), enables the Service Control Policy type at the root, grants trusted access to the services the landing zone uses, and creates a set of Organizational Units.

This is the foundation of the identity layer: SCPs (guardrails) and Identity Center (workforce access) both attach to the structure created here.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Organization (feature_set ALL) | (i) access control | A.5.15 |
| Organizational Units | (i) access control | A.5.15, A.5.18 |
| Trusted service access | (i) access control | A.5.15 |

## Example

```hcl
module "organizations" {
  source = "../../modules/organizations"
  organizational_units = ["Workloads", "Security", "Sandbox"]
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
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | AWS services granted trusted access in the org (e.g., for delegated admin). | `list(string)` | <pre>[<br/>  "cloudtrail.amazonaws.com",<br/>  "config.amazonaws.com",<br/>  "sso.amazonaws.com"<br/>]</pre> | no |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | Org policy types to enable at the root. SERVICE\_CONTROL\_POLICY required for SCPs. | `list(string)` | <pre>[<br/>  "SERVICE_CONTROL_POLICY"<br/>]</pre> | no |
| <a name="input_org_feature_set"></a> [org\_feature\_set](#input\_org\_feature\_set) | ALL enables SCPs; CONSOLIDATED\_BILLING does not. NIS2 guardrails need ALL. | `string` | `"ALL"` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | OUs to create under the root, by name. | `list(string)` | <pre>[<br/>  "Workloads",<br/>  "Security",<br/>  "Sandbox"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied where the resource supports them. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | The organization ARN. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The organization ID. |
| <a name="output_ou_arns"></a> [ou\_arns](#output\_ou\_arns) | Map of OU name -> OU arn. |
| <a name="output_ou_ids"></a> [ou\_ids](#output\_ou\_ids) | Map of OU name -> OU id. SCPs attach to these in W3-2. |
| <a name="output_root_id"></a> [root\_id](#output\_root\_id) | The root ID — SCPs and OUs attach here. |
<!-- END_TF_DOCS -->