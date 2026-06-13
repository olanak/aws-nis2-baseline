provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2  = "http://localhost:4566"
    logs = "http://localhost:4566"
    iam  = "http://localhost:4566"
    sts  = "http://localhost:4566"
    kms  = "http://localhost:4566"
  }
}

variables {
  vpc_name    = "test-vpc"
  kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
}

run "vpc_has_dns_support" {
  command = plan

  assert {
    condition     = aws_vpc.this.enable_dns_support == true && aws_vpc.this.enable_dns_hostnames == true
    error_message = "VPC must have DNS support and hostnames enabled."
  }
}

run "two_public_two_private_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "Must create 2 public and 2 private subnets."
  }
}

run "subnets_do_not_auto_assign_public_ip" {
  command = plan

  assert {
    condition     = alltrue([for s in aws_subnet.public : s.map_public_ip_on_launch == false])
    error_message = "Public subnets must not auto-assign public IPs (NIS2 hardening)."
  }
}

run "flow_logs_capture_all_traffic" {
  command = plan

  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "Flow logs must capture ALL traffic for full network visibility."
  }
}

run "flow_log_group_uses_kms_and_365_retention" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.flow_logs.kms_key_id == var.kms_key_arn
    error_message = "Flow-log group must be KMS-encrypted."
  }

  assert {
    condition     = aws_cloudwatch_log_group.flow_logs.retention_in_days == 365
    error_message = "Flow-log retention must default to 365 days (NIS2 Art.23)."
  }
}

run "flow_logs_trust_locks_to_service" {
  command = plan

  assert {
    condition     = strcontains(aws_iam_role.flow_logs.assume_role_policy, "vpc-flow-logs.amazonaws.com")
    error_message = "Flow-logs role trust must lock to vpc-flow-logs.amazonaws.com (NOT ec2)."
  }
}

run "rejects_wrong_az_count" {
  command = plan

  variables {
    availability_zones = ["eu-central-1a"]
  }

  expect_failures = [var.availability_zones]
}