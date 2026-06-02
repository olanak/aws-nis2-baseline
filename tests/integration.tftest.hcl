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
}