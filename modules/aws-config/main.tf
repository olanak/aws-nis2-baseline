# ---------------------------------------------------------------------------
# IAM service role assumed by AWS Config.
# Trust policy locked to config.amazonaws.com. NIS2 Art.21(2)(i). ISO A.5.15.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AllowConfigAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = merge(var.tags, {
    Name             = var.role_name
    ManagedBy        = "Terraform"
    Module           = "modules/aws-config"
    NIS2Controls     = "Art21-2-i"
    ISO27001Controls = "A5.15"
  })
}

# AWS-managed policy granting Config read access across services to record them.
resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Inline policy: permission to deliver snapshots to the S3 bucket.
data "aws_iam_policy_document" "s3_delivery" {
  statement {
    sid       = "ConfigS3GetBucketAcl"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
  }

  statement {
    sid       = "ConfigS3PutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/AWSLogs/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_iam_role_policy" "s3_delivery" {
  name   = "${var.role_name}-s3-delivery"
  role   = aws_iam_role.config.id
  policy = data.aws_iam_policy_document.s3_delivery.json
}

# ---------------------------------------------------------------------------
# Configuration recorder — captures resource configuration changes.
# NIS2 Art.21(2)(a) risk analysis. ISO A.8.9 configuration management.
# ---------------------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  name     = var.recorder_name
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }

  depends_on = [aws_iam_role_policy.s3_delivery]
}

# ---------------------------------------------------------------------------
# Delivery channel — ships snapshots/history to S3.
# ---------------------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  name           = var.delivery_channel_name
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix

  depends_on = [aws_config_configuration_recorder.this]
}

# ---------------------------------------------------------------------------
# Recorder status — turns recording on.
# ---------------------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

# ---------------------------------------------------------------------------
# Curated NIS2-aligned managed Config rules.
# Each rule continuously evaluates compliance of deployed resources.
# ---------------------------------------------------------------------------
locals {
  managed_rules = {
    s3-bucket-sse-enabled = {
      source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
      nis2              = "Art21-2-h"
      iso               = "A.8.24"
    }
    s3-bucket-public-read-prohibited = {
      source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
      nis2              = "Art21-2-i"
      iso               = "A.8.3"
    }
    cloudtrail-enabled = {
      source_identifier = "CLOUD_TRAIL_ENABLED"
      nis2              = "Art21-2-b"
      iso               = "A.8.15"
    }
    cloudtrail-log-validation = {
      source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
      nis2              = "Art21-2-f"
      iso               = "A.8.34"
    }
    encrypted-volumes = {
      source_identifier = "ENCRYPTED_VOLUMES"
      nis2              = "Art21-2-h"
      iso               = "A.8.24"
    }
    iam-user-mfa-enabled = {
      source_identifier = "IAM_USER_MFA_ENABLED"
      nis2              = "Art21-2-i"
      iso               = "A.8.5"
    }
  }
}

resource "aws_config_config_rule" "managed" {
  for_each = var.enable_rules ? local.managed_rules : {}

  name = each.key

  source {
    owner             = "AWS"
    source_identifier = each.value.source_identifier
  }

  tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/aws-config"
    NIS2Controls     = each.value.nis2
    ISO27001Controls = each.value.iso
  })

  depends_on = [aws_config_configuration_recorder_status.this]
}