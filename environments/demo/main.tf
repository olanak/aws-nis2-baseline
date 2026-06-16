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


# Pass CloudTrail-required statements into the s3-baseline module's bucket policy.
# This is the clean dependency-injection pattern: the bucket module owns its
# baseline security guarantees; the caller adds what's specific to its use.
locals {
  cloudtrail_bucket_policy_additions = [
    {
      Sid       = "AWSCloudTrailAclCheck"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = module.s3_baseline_logs.bucket_arn
    },
    {
      Sid       = "AWSCloudTrailWrite"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${module.s3_baseline_logs.bucket_arn}/cloudtrail/AWSLogs/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }
  ]
  config_bucket_policy_additions = [
    {
      Sid       = "AWSConfigBucketPermissionsCheck"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = module.s3_baseline_logs.bucket_arn
    },
    {
      Sid       = "AWSConfigBucketDelivery"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${module.s3_baseline_logs.bucket_arn}/AWSLogs/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }
  ]
}

module "s3_baseline_logs" {
  source = "../../modules/s3-baseline"

  bucket_name   = "nis2-demo-logs-bucket"
  kms_key_arn   = module.kms_s3_baseline.key_arn
  force_destroy = true

  # Additional statements injected for CloudTrail compatibility.
  # The module's baseline (TLS-only + SSE enforcement) is preserved.
  additional_policy_statements = concat(
    local.cloudtrail_bucket_policy_additions,
    local.config_bucket_policy_additions
  )

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "log-storage-demo"
  }
}

module "cloudtrail_demo" {
  source = "../../modules/cloudtrail"

  trail_name     = "nis2-demo-trail"
  s3_bucket_name = module.s3_baseline_logs.bucket_id
  s3_key_prefix  = "cloudtrail/"
  kms_key_arn    = module.kms_s3_baseline.key_arn

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "audit-log-trail"
  }
}

module "aws_config_demo" {
  source = "../../modules/aws-config"

  recorder_name         = "nis2-demo-recorder"
  delivery_channel_name = "nis2-demo-delivery"
  role_name             = "nis2-demo-config-role"
  s3_bucket_name        = module.s3_baseline_logs.bucket_id

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "continuous-compliance"
  }

  depends_on = [module.s3_baseline_logs]
}

module "vpc_demo" {
  source = "../../modules/vpc"

  vpc_name    = "nis2-demo-vpc"
  kms_key_arn = module.kms_s3_baseline.key_arn

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "network-audit"
  }
}

module "organizations" {
  source = "../../modules/organizations"

  organizational_units = ["Workloads", "Security", "Sandbox"]

  tags = {
    Project            = "aws-nis2-baseline"
    Environment        = "demo"
    DataClassification = "internal"
    Purpose            = "identity-foundation"
  }
}

output "organization_id" {
  value = module.organizations.organization_id
}

output "organization_root_id" {
  value = module.organizations.root_id
}

output "organization_ou_ids" {
  value = module.organizations.ou_ids
}


output "vpc_id" {
  value = module.vpc_demo.vpc_id
}

output "vpc_flow_log_group_arn" {
  value = module.vpc_demo.flow_log_group_arn
}

output "config_recorder_name" {
  value = module.aws_config_demo.recorder_name
}

output "config_rule_names" {
  value = module.aws_config_demo.rule_names
}

output "trail_arn" {
  value = module.cloudtrail_demo.trail_arn
}

output "trail_log_group_arn" {
  value = module.cloudtrail_demo.log_group_arn
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