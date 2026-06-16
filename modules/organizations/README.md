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
<!-- END_TF_DOCS -->