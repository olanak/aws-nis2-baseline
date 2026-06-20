data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/alerting"
    NIS2Controls     = "Art21-2-b"
    ISO27001Controls = "A5.24_A5.25_A5.26"
  })
}

# ---------------------------------------------------------------------------
# KMS key for the SNS topic. Key policy grants EventBridge the encrypt/decrypt
# actions it needs to publish to an encrypted topic (the KMS<->SNS<->EventBridge
# chain). LocalStack won't ENFORCE this, but it must be correct for real AWS.
# ---------------------------------------------------------------------------
resource "aws_kms_key" "alerts" {
  description             = "CMK for encrypting the NIS2 security-alerts SNS topic."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.base_tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowEventBridgeUseOfKey"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = ["kms:GenerateDataKey*", "kms:Decrypt"]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "alerts" {
  name          = "alias/${var.topic_name}"
  target_key_id = aws_kms_key.alerts.key_id
}

# ---------------------------------------------------------------------------
# Encrypted SNS topic + policy allowing EventBridge to publish.
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name              = var.topic_name
  kms_master_key_id = aws_kms_key.alerts.id
  tags              = local.base_tags
}

resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgePublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ---------------------------------------------------------------------------
# EventBridge rules: GuardDuty findings + Security Hub findings -> SNS.
# Match on event PATTERN (source/detail-type), not on the detection modules'
# ARNs — so alerting stays decoupled and apply-able even though those modules
# are plan-mode.
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "${var.topic_name}-guardduty"
  description = "Route GuardDuty findings at/above the severity threshold to SNS."

  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", var.min_severity_label] }]
    }
  })

  tags = local.base_tags
}

resource "aws_cloudwatch_event_rule" "securityhub" {
  name        = "${var.topic_name}-securityhub"
  description = "Route Security Hub imported findings to SNS."

  event_pattern = jsonencode({
    source        = ["aws.securityhub"]
    "detail-type" = ["Security Hub Findings - Imported"]
  })

  tags = local.base_tags
}

resource "aws_cloudwatch_event_target" "guardduty_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.alerts.arn
}

resource "aws_cloudwatch_event_target" "securityhub_to_sns" {
  rule      = aws_cloudwatch_event_rule.securityhub.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.alerts.arn
}