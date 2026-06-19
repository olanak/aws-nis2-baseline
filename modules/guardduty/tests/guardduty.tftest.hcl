provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    guardduty = "http://localhost:4566"
    sts       = "http://localhost:4566"
    iam       = "http://localhost:4566"
  }
}

run "detector_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_guardduty_detector.this.enable == true
    error_message = "Detector must be enabled."
  }
}

run "finding_frequency_is_tight" {
  command = plan

  assert {
    condition     = aws_guardduty_detector.this.finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "Default publishing frequency should be 15 minutes for low detection latency."
  }
}

run "s3_protection_enabled" {
  command = plan

  assert {
    condition     = aws_guardduty_detector_feature.s3_protection.status == "ENABLED"
    error_message = "S3 protection should be enabled by default."
  }
}

run "malware_protection_can_disable" {
  command = plan

  variables {
    enable_malware_protection = false
  }

  assert {
    condition     = aws_guardduty_detector_feature.malware_protection.status == "DISABLED"
    error_message = "Malware protection should respect the disable flag."
  }
}

run "rejects_invalid_frequency" {
  command = plan

  variables {
    finding_publishing_frequency = "DAILY"
  }

  expect_failures = [var.finding_publishing_frequency]
}