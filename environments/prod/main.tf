# prod environment — targets real AWS. Week 6 validation run.
# Same shared composition as dev; only the provider/backend differ.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment in Week 6 once the state bucket + lock table exist:
  # backend "s3" {
  #   bucket         = "nis2-baseline-tfstate"
  #   key            = "prod/terraform.tfstate"
  #   region         = "eu-central-1"
  #   dynamodb_table = "nis2-baseline-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = "eu-central-1"
  # Real credentials via environment / OIDC. No endpoints, no skip_* flags.
}

module "baseline" {
  source = "../_composition"
}

# Week 6: identity-center applies on real AWS (the provisioning-status endpoint
# that 501s on LocalStack exists here), so it gets wired in prod:
# module "identity_center" {
#   source = "../../modules/identity-center"
#   tags   = { Project = "aws-nis2-baseline", Environment = "prod" }
# }

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
