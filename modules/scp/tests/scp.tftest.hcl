provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    organizations = "http://localhost:4566"
    iam           = "http://localhost:4566"
    sts           = "http://localhost:4566"
  }
}

variables {
  targets = {
    "TestOU1" = "ou-test-1111"
    "TestOU2" = "ou-test-2222"
  }
}

run "creates_three_scps" {
  command = plan

  assert {
    condition     = aws_organizations_policy.deny_root.type == "SERVICE_CONTROL_POLICY"
    error_message = "deny_root must be an SCP."
  }
  assert {
    condition     = aws_organizations_policy.region_lock.type == "SERVICE_CONTROL_POLICY"
    error_message = "region_lock must be an SCP."
  }
  assert {
    condition     = aws_organizations_policy.protect_logging.type == "SERVICE_CONTROL_POLICY"
    error_message = "protect_logging must be an SCP."
  }
}

run "region_lock_targets_allowed_region" {
  command = plan
  assert {
    condition     = strcontains(aws_organizations_policy.region_lock.content, "eu-central-1")
    error_message = "region_lock must reference the allowed region."
  }
}

run "protect_logging_denies_stop_logging" {
  command = plan
  assert {
    condition     = strcontains(aws_organizations_policy.protect_logging.content, "cloudtrail:StopLogging")
    error_message = "protect_logging must deny cloudtrail:StopLogging."
  }
}

run "attaches_to_all_targets" {
  command = plan
  assert {
    condition     = length(aws_organizations_policy_attachment.this) == 6
    error_message = "Expected 6 attachments (3 SCPs x 2 targets)."
  }
}

run "rejects_empty_targets" {
  command = plan
  variables {
    targets = {}
  }
  expect_failures = [var.targets]
}