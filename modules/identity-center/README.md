# identity-center module

Workforce access via IAM Identity Center: two permission sets (Administrator, ReadOnly) with short session durations, a demo identity-store group, and an account assignment binding the admin permission set to that group on the management account.

Permission sets are the production pattern for workforce access — short-lived, SSO-fronted, MFA-enforced — replacing long-lived IAM users.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Permission sets (short session) | (i) access control, (j) secure authentication | A.5.15, A.8.5 |
| ReadOnly least-privilege default | (i) access control | A.5.15 |
| Identity-store group | (i) access control | A.5.17 |
| Account assignment | (i) access control | A.5.15, A.5.18 |

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
| [aws_identitystore_group.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_ssoadmin_account_assignment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set.readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignment_account_id"></a> [assignment\_account\_id](#input\_assignment\_account\_id) | Account ID to assign the admin permission set to (the management account in the demo). | `string` | `"000000000000"` | no |
| <a name="input_demo_group_name"></a> [demo\_group\_name](#input\_demo\_group\_name) | Name of the demo identity-store group to create and assign. | `string` | `"nis2-platform-admins"` | no |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | ISO-8601 session duration for permission sets. Short sessions reduce credential-exposure window (NIS2 access control). | `string` | `"PT1H"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to permission sets. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assignment_count"></a> [assignment\_count](#output\_assignment\_count) | Number of account assignments created. |
| <a name="output_demo_group_id"></a> [demo\_group\_id](#output\_demo\_group\_id) | The demo admin group's ID in the identity store. |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | The Identity Center instance ARN (discovered). |
| <a name="output_permission_set_arns"></a> [permission\_set\_arns](#output\_permission\_set\_arns) | Map of permission set name -> ARN. |
<!-- END_TF_DOCS -->