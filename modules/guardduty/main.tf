locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/guardduty"
    NIS2Controls     = "Art21-2-b_g"
    ISO27001Controls = "A8.16_A5.7"
  })
}

# Threat detection across CloudTrail management events, VPC Flow Logs, and DNS logs.
# GuardDuty consumes these automatically once enabled — no per-source wiring needed.
resource "aws_guardduty_detector" "this" {
  # checkov:skip=CKV2_AWS_3:GuardDuty is enabled here (enable=true). The rule's org-wide enablement (delegated-admin auto-enrollment across member accounts) is deliberately out of scope for this single-account baseline, consistent with ADR-001. Region is supplied by the provider; modules are region-agnostic by design. See decision matrix.
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = local.base_tags
}

# S3 protection: data-plane monitoring (GetObject/PutObject anomalies, NIS2 (g) hygiene).
resource "aws_guardduty_detector_feature" "s3_protection" {
  detector_id = aws_guardduty_detector.this.id
  name        = "S3_DATA_EVENTS"
  status      = var.enable_s3_protection ? "ENABLED" : "DISABLED"
}

# Malware protection: EBS volume scanning triggered by suspicious findings.
resource "aws_guardduty_detector_feature" "malware_protection" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = var.enable_malware_protection ? "ENABLED" : "DISABLED"
}