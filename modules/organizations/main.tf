locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/organizations"
    NIS2Controls     = "Art21-2-i"
    ISO27001Controls = "A5.15_A5.18"
  })
}

# ---------------------------------------------------------------------------
# The organization itself.
# feature_set = ALL is required for SCPs (the whole point of the identity layer).
# ---------------------------------------------------------------------------
resource "aws_organizations_organization" "this" {
  feature_set                   = var.org_feature_set
  enabled_policy_types          = var.enabled_policy_types
  aws_service_access_principals = var.aws_service_access_principals
}

# ---------------------------------------------------------------------------
# Organizational Units under the root, created from the name list.
# ---------------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "this" {
  for_each = toset(var.organizational_units)

  name      = each.value
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = merge(local.base_tags, { Name = each.value })
}