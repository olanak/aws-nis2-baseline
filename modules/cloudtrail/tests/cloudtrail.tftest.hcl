# Tests for the cloudtrail module.
# Plan-mode for static logic checks; one apply-mode for the full deployment.

provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudtrail = "http://localhost:4566"
    logs       = "http://localhost:4566"
    iam        = "http://localhost:4566"
    sts        = "http://localhost:4566"
    kms        = "http://localhost:4566"
  }
}


variables {
  trail_name     = "test-trail"
  s3_bucket_name = "test-bucket"
  kms_key_arn    = "arn:aws:kms:eu-central-1:000000000000:key/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
}

# ---------------------------------------------------------------------------
# Run 1: all resources are planned with default config.
# ---------------------------------------------------------------------------
run "default_config_plans_all_resources" {
  command = plan

  assert {
    condition     = aws_cloudtrail.this.name == "test-trail"
    error_message = "Trail must inherit the trail_name input."
  }

  assert {
    condition     = aws_cloudwatch_log_group.trail.name == "/aws/cloudtrail/test-trail"
    error_message = "Log group must be namespaced under /aws/cloudtrail/."
  }

  assert {
    condition     = aws_iam_role.cloudtrail_to_cwl.name == "test-trail-to-cwl"
    error_message = "IAM role must follow the <trail>-to-cwl naming convention."
  }
}

# ---------------------------------------------------------------------------
# Run 2: log file validation MUST be on. NIS2 Art. 21(2)(f).
# ---------------------------------------------------------------------------
run "log_file_validation_enabled" {
  command = plan

  assert {
    condition     = aws_cloudtrail.this.enable_log_file_validation == true
    error_message = "Log file validation must be enabled (NIS2 Art.21(2)(f) tamper detection)."
  }
}

# ---------------------------------------------------------------------------
# Run 3: multi-region trail by default.
# ---------------------------------------------------------------------------
run "multi_region_by_default" {
  command = plan

  assert {
    condition     = aws_cloudtrail.this.is_multi_region_trail == true
    error_message = "Multi-region trail must be the default (NIS2 effectiveness across regions)."
  }
}

# ---------------------------------------------------------------------------
# Run 4: global service events captured (IAM, STS).
# ---------------------------------------------------------------------------
run "global_service_events_captured" {
  command = plan

  assert {
    condition     = aws_cloudtrail.this.include_global_service_events == true
    error_message = "include_global_service_events must be true to capture IAM/STS actions."
  }
}

# ---------------------------------------------------------------------------
# Run 5: trust policy locks role assumption to the CloudTrail service.
# ---------------------------------------------------------------------------
run "trust_policy_locks_to_cloudtrail_service" {
  command = plan

  assert {
    condition     = strcontains(aws_iam_role.cloudtrail_to_cwl.assume_role_policy, "cloudtrail.amazonaws.com")
    error_message = "Trust policy must restrict assumption to the CloudTrail service principal."
  }
}

# ---------------------------------------------------------------------------
# Run 6: KMS encryption referenced on both the trail and the log group.
# ---------------------------------------------------------------------------
run "kms_encryption_applied" {
  command = plan

  assert {
    condition     = aws_cloudtrail.this.kms_key_id == var.kms_key_arn
    error_message = "Trail must use the provided KMS CMK."
  }

  assert {
    condition     = aws_cloudwatch_log_group.trail.kms_key_id == var.kms_key_arn
    error_message = "Log group must use the provided KMS CMK."
  }
}

# ---------------------------------------------------------------------------
# Run 7: retention default = 365 days (NIS2 Art.23 timelines).
# ---------------------------------------------------------------------------
run "retention_default_365_days" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.trail.retention_in_days == 365
    error_message = "Default retention must be 365 days (NIS2 Art.23 incident report window)."
  }
}

# ---------------------------------------------------------------------------
# Run 8: validation block rejects an invalid trail_name.
# ---------------------------------------------------------------------------
run "rejects_invalid_trail_name" {
  command = plan

  variables {
    trail_name = "Has Spaces And UPPERCASE"
  }

  expect_failures = [
    var.trail_name
  ]
}