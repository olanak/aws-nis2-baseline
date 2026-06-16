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