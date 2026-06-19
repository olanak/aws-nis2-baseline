provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    securityhub = "http://localhost:4566"
    sts         = "http://localhost:4566"
    iam         = "http://localhost:4566"
  }
}

run "account_does_not_autoenable_standards" {
  command = plan

  assert {
    condition     = aws_securityhub_account.this.enable_default_standards == false
    error_message = "Default standards must be off so we control standards explicitly."
  }
}

run "fsbp_standard_subscribed" {
  command = plan

  assert {
    condition     = can(regex("aws-foundational-security-best-practices", aws_securityhub_standards_subscription.fsbp.standards_arn))
    error_message = "FSBP standard must be subscribed."
  }
}

run "fsbp_arn_is_region_correct" {
  command = plan

  assert {
    condition     = can(regex("eu-central-1", aws_securityhub_standards_subscription.fsbp.standards_arn))
    error_message = "Standard ARN must reflect the provider region."
  }
}

run "guardduty_integration_on_by_default" {
  command = plan

  assert {
    condition     = length(aws_securityhub_product_subscription.guardduty) == 1
    error_message = "GuardDuty product subscription should be enabled by default."
  }
}

run "guardduty_integration_can_disable" {
  command = plan

  variables {
    enable_guardduty_integration = false
  }

  assert {
    condition     = length(aws_securityhub_product_subscription.guardduty) == 0
    error_message = "Disabling the integration should remove the product subscription."
  }
}