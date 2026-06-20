provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    sns    = "http://localhost:4566"
    events = "http://localhost:4566"
    kms    = "http://localhost:4566"
    sts    = "http://localhost:4566"
    iam    = "http://localhost:4566"
  }
}

run "topic_is_kms_encrypted" {
  command = apply

  assert {
    condition     = aws_sns_topic.alerts.kms_master_key_id != ""
    error_message = "SNS topic must be KMS-encrypted."
  }
}

run "topic_policy_allows_eventbridge" {
  command = apply

  assert {
    condition     = can(regex("events.amazonaws.com", aws_sns_topic_policy.alerts.policy))
    error_message = "Topic policy must allow EventBridge to publish."
  }
}

run "key_policy_grants_eventbridge" {
  command = apply

  assert {
    condition     = can(regex("events.amazonaws.com", aws_kms_key.alerts.policy))
    error_message = "KMS key policy must grant EventBridge decrypt/generate-data-key."
  }
}

run "guardduty_rule_filters_severity" {
  command = apply

  assert {
    condition     = can(regex("aws.guardduty", aws_cloudwatch_event_rule.guardduty.event_pattern))
    error_message = "GuardDuty rule must match the guardduty source."
  }
}

run "both_rules_target_the_topic" {
  command = apply

  assert {
    condition     = aws_cloudwatch_event_target.guardduty_to_sns.arn == aws_sns_topic.alerts.arn && aws_cloudwatch_event_target.securityhub_to_sns.arn == aws_sns_topic.alerts.arn
    error_message = "Both EventBridge rules must target the SNS topic."
  }
}

run "rejects_invalid_severity" {
  command = plan

  variables {
    min_severity_label = 99
  }

  expect_failures = [var.min_severity_label]
}