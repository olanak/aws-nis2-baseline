data "aws_region" "current" {}
data "aws_partition" "current" {}

# Account-level Security Hub enablement. enable_default_standards = false so we
# subscribe ONLY to FSBP explicitly (avoids pulling in CIS/PCI by default).
resource "aws_securityhub_account" "this" {
  enable_default_standards = var.enable_default_standards
}

# AWS Foundational Security Best Practices — the canonical AWS-native standard.
# Maps to NIS2 (e) vulnerability handling + (g) cyber hygiene.
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

# GuardDuty findings flow into Security Hub as a finding source.
# References the GuardDuty PRODUCT ARN (region-derived string), not the
# guardduty module — keeps this module independently validatable (plan-mode).
resource "aws_securityhub_product_subscription" "guardduty" {
  count       = var.enable_guardduty_integration ? 1 : 0
  product_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::product/aws/guardduty"

  depends_on = [aws_securityhub_account.this]
}