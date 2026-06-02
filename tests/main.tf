# This file exists so `terraform init` in this directory discovers
# and downloads any modules referenced by .tftest.hcl files.
# It is intentionally empty of resources — assertions live in the .tftest.hcl.

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}