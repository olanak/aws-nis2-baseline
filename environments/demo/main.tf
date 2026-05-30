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
  s3_use_path_style           = true

  endpoints {
    kms = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
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

module "s3_baseline_logs" {
  source = "../../modules/s3-baseline"

  bucket_name   = "nis2-demo-logs-bucket"
  kms_key_arn   = module.kms_s3_baseline.key_arn
  force_destroy = true # demo only — destroy with terraform destroy possible

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "log-storage-demo"
  }
}

output "logs_bucket_arn" {
  value = module.s3_baseline_logs.bucket_arn
}

output "logs_bucket_id" {
  value = module.s3_baseline_logs.bucket_id
}

output "s3_baseline_key_arn" {
  value = module.kms_s3_baseline.key_arn
}