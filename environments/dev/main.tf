# dev environment — targets LocalStack.
# Thin wrapper: provider config + a single call to the shared composition.

terraform {
  required_version = ">= 1.5.0"

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
    kms           = "http://localhost:4566"
    sts           = "http://localhost:4566"
    iam           = "http://localhost:4566"
    s3            = "http://s3.localhost.localstack.cloud:4566"
    cloudtrail    = "http://localhost:4566"
    logs          = "http://localhost:4566"
    config        = "http://localhost:4566"
    ec2           = "http://localhost:4566"
    organizations = "http://localhost:4566"
    sns           = "http://localhost:4566"
    events        = "http://localhost:4566"
  }
}

module "baseline" {
  source = "../_composition"
}

output "s3_baseline_key_arn" {
  value = module.baseline.s3_baseline_key_arn
}

output "logs_bucket_arn" {
  value = module.baseline.logs_bucket_arn
}

output "logs_bucket_id" {
  value = module.baseline.logs_bucket_id
}

output "trail_arn" {
  value = module.baseline.trail_arn
}

output "trail_log_group_arn" {
  value = module.baseline.trail_log_group_arn
}

output "config_recorder_name" {
  value = module.baseline.config_recorder_name
}

output "config_rule_names" {
  value = module.baseline.config_rule_names
}

output "vpc_id" {
  value = module.baseline.vpc_id
}

output "vpc_flow_log_group_arn" {
  value = module.baseline.vpc_flow_log_group_arn
}

output "organization_id" {
  value = module.baseline.organization_id
}

output "organization_root_id" {
  value = module.baseline.organization_root_id
}

output "organization_ou_ids" {
  value = module.baseline.organization_ou_ids
}

output "scp_policy_ids" {
  value = module.baseline.scp_policy_ids
}

output "scp_attachment_count" {
  value = module.baseline.scp_attachment_count
}
