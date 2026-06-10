provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    config = "http://localhost:4566"
    iam    = "http://localhost:4566"
    sts    = "http://localhost:4566"
    s3     = "http://s3.localhost.localstack.cloud:4566"
  }
}

variables {
  recorder_name         = "test-recorder"
  delivery_channel_name = "test-delivery"
  role_name             = "test-config-role"
  s3_bucket_name        = "test-bucket"
}

run "recorder_records_all_supported_types" {
  command = plan

  assert {
    condition     = aws_config_configuration_recorder.this.recording_group[0].all_supported == true
    error_message = "Recorder must record all supported resource types."
  }
}

run "recorder_includes_global_resources_by_default" {
  command = plan

  assert {
    condition     = aws_config_configuration_recorder.this.recording_group[0].include_global_resource_types == true
    error_message = "Global resource types must be recorded by default."
  }
}

run "trust_policy_locks_to_config_service" {
  command = plan

  assert {
    condition     = strcontains(aws_iam_role.config.assume_role_policy, "config.amazonaws.com")
    error_message = "Trust policy must restrict assumption to the Config service principal."
  }
}

run "delivery_channel_targets_bucket" {
  command = plan

  assert {
    condition     = aws_config_delivery_channel.this.s3_bucket_name == "test-bucket"
    error_message = "Delivery channel must target the provided bucket."
  }
}

run "rules_created_when_enabled" {
  command = plan

  variables {
    enable_rules = true
  }

  assert {
    condition     = length(aws_config_config_rule.managed) == 6
    error_message = "All 6 curated rules must be planned when enable_rules = true."
  }
}

run "rules_skipped_when_disabled" {
  command = plan

  variables {
    enable_rules = false
  }

  assert {
    condition     = length(aws_config_config_rule.managed) == 0
    error_message = "No rules should be planned when enable_rules = false."
  }
}

run "rejects_invalid_recorder_name" {
  command = plan

  variables {
    recorder_name = "has spaces!"
  }

  expect_failures = [var.recorder_name]
}