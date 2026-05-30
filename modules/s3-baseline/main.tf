# ---------------------------------------------------------------------------
# The bucket itself. Everything else attaches to it.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name             = var.bucket_name
      ManagedBy        = "Terraform"
      Module           = "modules/s3-baseline"
      NIS2Controls     = "Art21-2-b_c_e_h"
      ISO27001Controls = "A8.13_A8.15_A8.22_A8.24"
    }
  )
}

# ---------------------------------------------------------------------------
# Block ALL FOUR dimensions of public access at the bucket level.
# NIS2 Art. 21(2)(e) — network/information system security.
# ISO 27001:2022 A.8.22 — segregation of networks.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# Server-side encryption with the KMS CMK (SSE-KMS).
# NIS2 Art. 21(2)(h) — cryptographic measures.
# ISO 27001:2022 A.8.24 — use of cryptography.
# bucket_key_enabled reduces KMS API calls and cost ~99% in production.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# ---------------------------------------------------------------------------
# Versioning. NIS2 Art. 21(2)(c) — business continuity and backup.
# ISO 27001:2022 A.8.13 — information backup.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# ---------------------------------------------------------------------------
# TLS-only bucket policy. Denies any request that isn't over HTTPS.
# Plus: denies unencrypted-at-rest uploads (forces SSE-KMS).
# NIS2 Art. 21(2)(h) — cryptography in transit AND at rest.
# ISO 27001:2022 A.8.21 — security of network services, A.8.24.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })



  # Must run AFTER the public access block, or AWS rejects the policy
  # because the policy itself could grant public access (we're not, but AWS checks).
  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ---------------------------------------------------------------------------
# Server access logging.
# NIS2 Art. 21(2)(b) incident handling + (f) effectiveness assessment.
# ISO 27001:2022 A.8.15 logging, A.8.16 monitoring.
# Conditional: only attaches if logging_target_bucket is set (avoids logging-to-self loop).
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_logging" "this" {
  count = var.logging_target_bucket == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# ---------------------------------------------------------------------------
# Lifecycle: expire noncurrent versions, abort incomplete multipart uploads.
# NIS2 Art. 21(2)(c) business continuity (controlled retention).
# Cost discipline: prevents unbounded storage growth from versioned buckets.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}