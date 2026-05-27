terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configured for LocalStack.
# In production you'd remove the endpoints and skip_* flags.
provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    kms = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

module "kms_s3_baseline" {
  source = "../../modules/kms"

  key_alias   = "nis2-s3-baseline"
  description = "CMK for encrypting S3 baseline buckets (NIS2 Art. 21(2)(h))."

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
  }
}

output "s3_baseline_key_arn" {
  value = module.kms_s3_baseline.key_arn
}