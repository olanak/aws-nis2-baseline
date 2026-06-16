provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    sso           = "http://localhost:4566"
    ssoadmin      = "http://localhost:4566"
    identitystore = "http://localhost:4566"
    iam           = "http://localhost:4566"
    sts           = "http://localhost:4566"
  }
}

run "two_permission_sets_created" {
  command = plan

  assert {
    condition     = aws_ssoadmin_permission_set.admin.name == "AdministratorAccess"
    error_message = "Admin permission set must exist."
  }
  assert {
    condition     = aws_ssoadmin_permission_set.readonly.name == "ReadOnlyAccess"
    error_message = "ReadOnly permission set must exist."
  }
}

run "session_duration_is_short" {
  command = plan

  assert {
    condition     = aws_ssoadmin_permission_set.admin.session_duration == "PT1H"
    error_message = "Default session duration must be 1 hour (short window)."
  }
}

run "admin_attaches_administrator_policy" {
  command = plan

  assert {
    condition     = aws_ssoadmin_managed_policy_attachment.admin.managed_policy_arn == "arn:aws:iam::aws:policy/AdministratorAccess"
    error_message = "Admin permission set must attach AdministratorAccess."
  }
}

run "assignment_targets_group" {
  command = plan

  assert {
    condition     = aws_ssoadmin_account_assignment.admin.principal_type == "GROUP"
    error_message = "Assignment must bind a GROUP principal."
  }
}

run "rejects_invalid_session_duration" {
  command = plan

  variables {
    session_duration = "1hour"
  }

  expect_failures = [var.session_duration]
}