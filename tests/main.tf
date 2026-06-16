# This file exists so `terraform init` discovers and prepares the demo
# composition that the integration tests reference via module { source = "..." }.
# It is a wiring file only — no resources are created from this directly.
# tests/main.tf  (final version)
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    kms = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://s3.localhost.localstack.cloud:4566"
  }


}

# Register the demo composition so `terraform init` downloads/prepares it.
# Actual test logic + assertions live in integration.tftest.hcl.
#
# Suppressions:
#   - aws-s3-enable-bucket-logging: This file is a wiring stub for
#     `terraform init` to discover the integration test module. It does
#     not represent deployed infrastructure.
#   - aws-iam-no-policy-wildcards: Transitively flags wildcards from the
#     demo composition. Reviewed — all wildcards are in Deny statements
#     (s3-baseline bucket policy) or KMS key policies (where Resource = "*"
#     refers to the policy's own key — AWS documented pattern). Not a real
#     least-privilege violation.
# tfsec:ignore:aws-s3-enable-bucket-logging
# tfsec:ignore:aws-iam-no-policy-wildcards
module "demo" {
  source = "../environments/demo"
}

output "s3_baseline_key_arn" {
  value = module.demo.s3_baseline_key_arn
}

output "logs_bucket_arn" {
  value = module.demo.logs_bucket_arn
}

output "logs_bucket_id" {
  value = module.demo.logs_bucket_id
}

output "trail_arn" {
  value = module.demo.trail_arn
}

output "trail_log_group_arn" {
  value = module.demo.trail_log_group_arn
}
output "config_recorder_name" {
  value = module.demo.config_recorder_name
}

output "config_rule_names" {
  value = module.demo.config_rule_names
}

output "vpc_id" {
  value = module.demo.vpc_id
}

output "vpc_flow_log_group_arn" {
  value = module.demo.vpc_flow_log_group_arn
}

output "organization_id" {
  value = module.demo.organization_id
}

output "organization_root_id" {
  value = module.demo.organization_root_id
}

output "organization_ou_ids" {
  value = module.demo.organization_ou_ids
}