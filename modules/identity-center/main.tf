locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/identity-center"
    NIS2Controls     = "Art21-2-i_j"
    ISO27001Controls = "A5.15_A5.17_A8.5"
  })
}

# ---------------------------------------------------------------------------
# Discover the Identity Center instance (created with the org, not by us).
# Reading it dynamically is essential — the ARN/store ID are generated.
# ---------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# ---------------------------------------------------------------------------
# Permission set 1: Administrator — short session, MFA-relevant settings.
# ---------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  description      = "Full administrator access. Short session window (NIS2 21(2)(i))."
  instance_arn     = local.instance_arn
  session_duration = var.session_duration
  tags             = merge(local.base_tags, { Name = "AdministratorAccess" })
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ---------------------------------------------------------------------------
# Permission set 2: ReadOnly — least-privilege default for most workforce.
# ---------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnlyAccess"
  description      = "Read-only access. Least-privilege default (NIS2 21(2)(i))."
  instance_arn     = local.instance_arn
  session_duration = var.session_duration
  tags             = merge(local.base_tags, { Name = "ReadOnlyAccess" })
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ---------------------------------------------------------------------------
# Demo group in the identity store + assignment (end-to-end "who can do what").
# ---------------------------------------------------------------------------
resource "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id
  display_name      = var.demo_group_name
  description       = "Demo platform-admins group (NIS2 access control demonstration)."
}

resource "aws_ssoadmin_account_assignment" "admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_group.admins.group_id
  principal_type = "GROUP"

  target_id   = var.assignment_account_id
  target_type = "AWS_ACCOUNT"
}