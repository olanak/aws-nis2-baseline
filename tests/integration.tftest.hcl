# Integration test: verify KMS + S3 baseline compose correctly.
# This test ACTUALLY DEPLOYS to LocalStack (apply mode), then asserts on outputs.
# Integration test: verifies KMS + S3 baseline compose correctly when
# deployed together via the demo composition.

run "kms_and_s3_compose_correctly" {
  command = apply

  assert {
    condition     = can(regex("^arn:aws:kms:eu-central-1:", output.s3_baseline_key_arn))
    error_message = "KMS key ARN must be in eu-central-1 (EU data residency)."
  }

  assert {
    condition     = output.logs_bucket_id == "nis2-demo-logs-bucket"
    error_message = "Logs bucket ID must match expected name."
  }

  assert {
    condition     = can(regex("^arn:aws:s3:::nis2-demo-logs-bucket$", output.logs_bucket_arn))
    error_message = "Logs bucket ARN must follow expected pattern."
  }

  assert {
    condition     = can(regex("^arn:aws:cloudtrail:eu-central-1:", output.trail_arn))
    error_message = "Trail ARN must be in eu-central-1."
  }

  assert {
    condition     = can(regex("^arn:aws:logs:eu-central-1:", output.trail_log_group_arn))
    error_message = "CloudTrail log group ARN must be in eu-central-1."
  }
  assert {
    condition     = output.config_recorder_name == "nis2-demo-recorder"
    error_message = "Config recorder must be present in the composition."
  }

  assert {
    condition     = length(output.config_rule_names) == 6
    error_message = "All 6 managed Config rules must be deployed in the composition."
  }

  assert {
    condition     = can(regex("^vpc-", output.vpc_id))
    error_message = "VPC must be created with a valid vpc- ID."
  }

  assert {
    condition     = can(regex("^arn:aws:logs:eu-central-1:.*:/aws/vpc/", output.vpc_flow_log_group_arn))
    error_message = "VPC flow-log group ARN must be in eu-central-1 under /aws/vpc/."
  }
  assert {
    condition     = can(regex("^o-", output.organization_id))
    error_message = "Organization must be created with a valid o- ID."
  }

  assert {
    condition     = can(regex("^r-", output.organization_root_id))
    error_message = "Organization root must have a valid r- ID."
  }

  assert {
    condition     = length(output.organization_ou_ids) == 3
    error_message = "All 3 OUs (Workloads, Security, Sandbox) must be present in the composition."
  }
}