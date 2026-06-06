# ---------------------------------------------------------------------------
# CloudWatch Log Group — destination for real-time trail events.
# NIS2 Art. 21(2)(b) + (f). ISO 27001:2022 A.8.15, A.8.16.
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws/cloudtrail/${var.trail_name}"
  retention_in_days = var.cloudwatch_logs_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name             = "/aws/cloudtrail/${var.trail_name}"
      ManagedBy        = "Terraform"
      Module           = "modules/cloudtrail"
      NIS2Controls     = "Art21-2-b_f"
      ISO27001Controls = "A8.15_A8.16"
    }
  )
}

# ---------------------------------------------------------------------------
# IAM role that CloudTrail assumes to write to CloudWatch Logs.
# Demonstrates the service-role pattern: trust policy + permissions policy.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "cloudtrail_to_cwl" {
  name               = "${var.trail_name}-to-cwl"
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = merge(
    var.tags,
    {
      Name             = "${var.trail_name}-to-cwl"
      ManagedBy        = "Terraform"
      Module           = "modules/cloudtrail"
      NIS2Controls     = "Art21-2-i"
      ISO27001Controls = "A5.15"
    }
  )
}

# Trust policy — only the CloudTrail service can assume this role.
data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AllowCloudTrailAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# Permissions policy — minimal: only what CloudTrail needs.
data "aws_iam_policy_document" "permissions" {
  statement {
    sid    = "AllowWriteToTrailLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.trail.arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail_to_cwl" {
  name   = "${var.trail_name}-to-cwl"
  role   = aws_iam_role.cloudtrail_to_cwl.id
  policy = data.aws_iam_policy_document.permissions.json
}

# ---------------------------------------------------------------------------
# The CloudTrail trail itself.
# Five NIS2 controls expressed as resource attributes:
#   include_global_service_events     -> IAM, STS events (org-wide visibility)
#   is_multi_region_trail              -> events from ALL regions
#   enable_log_file_validation         -> SHA-256 + RSA tamper detection
#   kms_key_id                          -> envelope encryption with our CMK
#   cloud_watch_logs_group_arn          -> real-time stream for Week 4 alerting
# ---------------------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  name           = var.trail_name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix

  include_global_service_events = true
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_to_cwl.arn

  # Management events: control-plane actions. Free for the first trail.
  # We're explicit even though this is the default — clarity beats brevity.
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(
    var.tags,
    {
      Name             = var.trail_name
      ManagedBy        = "Terraform"
      Module           = "modules/cloudtrail"
      NIS2Controls     = "Art21-2-b_f_h"
      ISO27001Controls = "A8.15_A8.16_A8.24_A8.34"
    }
  )

  # Trail creation fails if the role isn't ready first.
  depends_on = [aws_iam_role_policy.cloudtrail_to_cwl]
}