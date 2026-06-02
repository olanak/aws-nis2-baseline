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