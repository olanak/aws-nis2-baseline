# The KMS Customer Managed Key (CMK).
# Rotation is enabled to satisfy NIS2 Art. 21(2)(h) "state of the art" cryptography.
resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  # The key policy: the resource-level authorization layer.
  # We grant the AWS account root full administrative control. IAM policies
  # for individual users/roles layer on top of this.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountAdministration"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name            = var.key_alias
      ManagedBy       = "Terraform"
      Module          = "modules/kms"
      NIS2Control     = "Art.21(2)(h)"
      ISO27001Control = "A.8.24"
    }
  )
}

# Human-readable alias pointing at the key. Aliases are stable;
# key IDs change if a key is recreated.
resource "aws_kms_alias" "this" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.this.key_id
}

# Look up the current AWS account ID dynamically so the policy adapts
# to wherever this module is applied.
data "aws_caller_identity" "current" {}