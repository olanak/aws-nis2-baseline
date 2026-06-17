# Wiring file: lets `terraform init` discover and prepare the shared
# composition that integration.tftest.hcl references. No resources are
# created from this directly. Provider lives here per the locked convention
# (composition is provider-agnostic; the test supplies the provider).
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
    kms           = "http://localhost:4566"
    sts           = "http://localhost:4566"
    iam           = "http://localhost:4566"
    s3            = "http://s3.localhost.localstack.cloud:4566"
    cloudtrail    = "http://localhost:4566"
    logs          = "http://localhost:4566"
    config        = "http://localhost:4566"
    ec2           = "http://localhost:4566"
    organizations = "http://localhost:4566"
  }
}

# Suppressions:
#   - aws-s3-enable-bucket-logging: wiring stub for `terraform init` discovery,
#     not deployed infrastructure.
#   - aws-iam-no-policy-wildcards: transitively flags wildcards from the shared
#     composition. Reviewed — all wildcards are in Deny statements or KMS key
#     policies (Resource = "*" refers to the policy's own key). Not a real
#     least-privilege violation.
# tfsec:ignore:aws-s3-enable-bucket-logging
# tfsec:ignore:aws-iam-no-policy-wildcards
module "composition" {
  source = "../environments/_composition"
}

output "s3_baseline_key_arn" {
  value = module.composition.s3_baseline_key_arn
}

output "logs_bucket_arn" {
  value = module.composition.logs_bucket_arn
}

output "logs_bucket_id" {
  value = module.composition.logs_bucket_id
}

output "trail_arn" {
  value = module.composition.trail_arn
}

output "trail_log_group_arn" {
  value = module.composition.trail_log_group_arn
}

output "config_recorder_name" {
  value = module.composition.config_recorder_name
}

output "config_rule_names" {
  value = module.composition.config_rule_names
}

output "vpc_id" {
  value = module.composition.vpc_id
}

output "vpc_flow_log_group_arn" {
  value = module.composition.vpc_flow_log_group_arn
}

output "organization_id" {
  value = module.composition.organization_id
}

output "organization_root_id" {
  value = module.composition.organization_root_id
}

output "organization_ou_ids" {
  value = module.composition.organization_ou_ids
}

output "scp_policy_ids" {
  value = module.composition.scp_policy_ids
}

output "scp_attachment_count" {
  value = module.composition.scp_attachment_count
}
