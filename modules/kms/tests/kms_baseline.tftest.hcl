# Tests for the KMS module.
# These are plan-mode tests — fast, no resources created, validates module logic.
provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    kms = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

variables {
  key_alias   = "test-key-alias"
  description = "Test key for terraform test"
}

# ---------------------------------------------------------------------------
# Run 1: validate the default configuration produces a compliant CMK.
# ---------------------------------------------------------------------------
run "kms_defaults_are_compliant" {
  command = plan

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "Key rotation must be enabled (NIS2 Art.21(2)(h))."
  }

  assert {
    condition     = aws_kms_key.this.deletion_window_in_days == 30
    error_message = "Default deletion window must be 30 days to maximize accidental-deletion protection."
  }

  assert {
    condition     = aws_kms_key.this.key_usage == "ENCRYPT_DECRYPT"
    error_message = "Key usage must be ENCRYPT_DECRYPT for SSE-KMS compatibility."
  }

  assert {
    condition     = aws_kms_alias.this.name == "alias/test-key-alias"
    error_message = "Alias must be prefixed with 'alias/'."
  }
}

# ---------------------------------------------------------------------------
# Run 2: tags must carry regulatory traceability.
# ---------------------------------------------------------------------------
run "tags_include_regulatory_traceability" {
  command = plan

  assert {
    condition     = aws_kms_key.this.tags["NIS2Control"] == "Art.21(2)(h)"
    error_message = "Key must be tagged with the NIS2 control it satisfies."
  }

  assert {
    condition     = aws_kms_key.this.tags["ISO27001Control"] == "A.8.24"
    error_message = "Key must be tagged with the ISO 27001 control it satisfies."
  }

  assert {
    condition     = aws_kms_key.this.tags["ManagedBy"] == "Terraform"
    error_message = "Key must declare it's managed by IaC."
  }
}

# ---------------------------------------------------------------------------
# Run 3: deletion window validation rejects out-of-range values at plan time.
# ---------------------------------------------------------------------------
run "rejects_invalid_deletion_window" {
  command = plan

  variables {
    deletion_window_in_days = 3  # below minimum (7)
  }

  expect_failures = [
    var.deletion_window_in_days
  ]
}