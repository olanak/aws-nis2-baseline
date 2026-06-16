locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/scp"
    NIS2Controls     = "Art21-2-i"
    ISO27001Controls = "A5.15_A8.22"
  })
}

# --- Guardrail 1: deny root user -------------------------------------------
data "aws_iam_policy_document" "deny_root" {
  statement {
    sid       = "DenyRootUser"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "deny_root" {
  name        = "deny-root-user"
  description = "Deny all actions by the root user (NIS2 21(2)(i))."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_root.json
  tags        = merge(local.base_tags, { Name = "deny-root-user" })
}

# --- Guardrail 2: region lock (EU data residency) --------------------------
data "aws_iam_policy_document" "region_lock" {
  statement {
    sid         = "DenyOutsideAllowedRegion"
    effect      = "Deny"
    not_actions = var.global_service_exceptions
    resources   = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [var.allowed_region]
    }
  }
}

resource "aws_organizations_policy" "region_lock" {
  name        = "region-lock-${var.allowed_region}"
  description = "Deny operations outside ${var.allowed_region} (EU data residency)."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_lock.json
  tags        = merge(local.base_tags, { Name = "region-lock" })
}

# --- Guardrail 3: protect the logging layer --------------------------------
data "aws_iam_policy_document" "protect_logging" {
  statement {
    sid    = "DenyDisablingLogging"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "cloudtrail:UpdateTrail",
      "config:DeleteConfigurationRecorder",
      "config:StopConfigurationRecorder",
      "config:DeleteDeliveryChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "protect_logging" {
  name        = "protect-logging-layer"
  description = "Deny disabling CloudTrail/Config (NIS2 21(2)(b)(f))."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.protect_logging.json
  tags        = merge(local.base_tags, { Name = "protect-logging-layer" })
}

# --- Attach every policy to every target -----------------------------------
locals {
  policies = {
    deny_root       = aws_organizations_policy.deny_root.id
    region_lock     = aws_organizations_policy.region_lock.id
    protect_logging = aws_organizations_policy.protect_logging.id
  }
  # Keys are built from STATIC strings (policy name + target name),
  # so the full key set is known at plan time. Only the values (IDs) are apply-time.
  attachments = {
    for pair in setproduct(keys(local.policies), keys(var.targets)) :
    "${pair[0]}:${pair[1]}" => {
      policy_id = local.policies[pair[0]]
      target_id = var.targets[pair[1]]
    }
  }
}

resource "aws_organizations_policy_attachment" "this" {
  for_each  = local.attachments
  policy_id = each.value.policy_id
  target_id = each.value.target_id
}