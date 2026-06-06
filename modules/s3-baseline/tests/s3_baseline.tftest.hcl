# Tests for the s3-baseline module.
provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    kms = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
  }
}

variables {
  bucket_name = "tf-test-bucket-baseline"
  kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/test-key-id"
}

# ---------------------------------------------------------------------------
# Run 1: all four public-access dimensions are blocked.
# ---------------------------------------------------------------------------
run "blocks_all_four_public_access_dimensions" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "block_public_acls must be true (one of four S3 public-access dimensions)."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "block_public_policy must be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "ignore_public_acls must be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "restrict_public_buckets must be true."
  }
}

# ---------------------------------------------------------------------------
# Run 2: encryption uses SSE-KMS with the provided CMK.
# ---------------------------------------------------------------------------
run "encryption_uses_sse_kms_with_provided_cmk" {
  command = plan

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      r.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
    ])
    error_message = "SSE algorithm must be aws:kms (NIS2 Art.21(2)(h) — org-controlled keys)."
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      r.apply_server_side_encryption_by_default[0].kms_master_key_id == var.kms_key_arn
    ])
    error_message = "Encryption must use the CMK passed in by the caller."
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      r.bucket_key_enabled == true
    ])
    error_message = "bucket_key_enabled must be true to reduce KMS API calls + cost."
  }
}

# ---------------------------------------------------------------------------
# Run 3: versioning enabled by default.
# ---------------------------------------------------------------------------
run "versioning_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be Enabled by default (NIS2 Art.21(2)(c) business continuity)."
  }
}

# ---------------------------------------------------------------------------
# Run 4: bucket policy contains the TLS-only deny statement.
# ---------------------------------------------------------------------------
run "bucket_policy_denies_insecure_transport" {
  command = apply

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "aws:SecureTransport")
    error_message = "Bucket policy must include a Deny statement for non-TLS transport."
  }

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "DenyInsecureTransport")
    error_message = "Policy must include the DenyInsecureTransport Sid."
  }
}

# ---------------------------------------------------------------------------
# Run: caller-provided statements merge correctly with baseline.
# ---------------------------------------------------------------------------
run "additional_policy_statements_merge_with_baseline" {
  command = apply

  variables {
    additional_policy_statements = [
      {
        Sid       = "TestAdditionalStatement"
        Effect    = "Allow"
        Principal = { Service = "test-service.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::tf-test-bucket-baseline/test/*"
      }
    ]
  }

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "DenyInsecureTransport")
    error_message = "Baseline DenyInsecureTransport must persist when additional statements are added."
  }

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "DenyUnencryptedObjectUploads")
    error_message = "Baseline DenyUnencryptedObjectUploads must persist."
  }

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "TestAdditionalStatement")
    error_message = "Caller-provided statement must be merged into the policy."
  }
}

# ---------------------------------------------------------------------------
# Run 5: bucket policy enforces SSE-KMS on uploads.
# ---------------------------------------------------------------------------
run "bucket_policy_enforces_sse_kms_uploads" {
  command = apply

  assert {
    condition     = strcontains(aws_s3_bucket_policy.this.policy, "DenyUnencryptedObjectUploads")
    error_message = "Policy must reject PutObject without aws:kms encryption."
  }
}

# ---------------------------------------------------------------------------
# Run 6: negative test — rejects bucket names with underscores.
# ---------------------------------------------------------------------------
run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "INVALID_BUCKET_WITH_UNDERSCORES"
  }

  expect_failures = [
    var.bucket_name
  ]
}