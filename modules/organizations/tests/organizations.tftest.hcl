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

run "feature_set_is_all_for_scps" {
  command = plan

  assert {
    condition     = aws_organizations_organization.this.feature_set == "ALL"
    error_message = "feature_set must be ALL — SCPs require it."
  }
}

run "scp_policy_type_enabled" {
  command = plan

  assert {
    condition     = contains(aws_organizations_organization.this.enabled_policy_types, "SERVICE_CONTROL_POLICY")
    error_message = "SERVICE_CONTROL_POLICY must be enabled at the root."
  }
}

run "creates_expected_ous" {
  command = plan

  assert {
    condition     = length(aws_organizations_organizational_unit.this) == 3
    error_message = "Expected 3 OUs by default (Workloads, Security, Sandbox)."
  }
}

run "rejects_invalid_feature_set" {
  command = plan

  variables {
    org_feature_set = "PARTIAL"
  }

  expect_failures = [var.org_feature_set]
}