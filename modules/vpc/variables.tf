variable "vpc_name" {
  description = "Name prefix for the VPC and its child resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,64}$", var.vpc_name))
    error_message = "VPC name must be 3-64 chars, lowercase, hyphens only."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs to spread subnets across. Two recommended for HA."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "This module expects exactly 2 AZs."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "kms_key_arn" {
  description = "KMS CMK ARN to encrypt the flow-log CloudWatch Log Group."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/.+$", var.kms_key_arn))
    error_message = "Must be a full KMS key ARN."
  }
}

variable "flow_logs_retention_days" {
  description = "Retention for the flow-log CloudWatch Log Group. 365 for NIS2 Art.23."
  type        = number
  default     = 365

  validation {
    condition     = contains([1, 7, 14, 30, 60, 90, 120, 180, 365, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "Must be a CloudWatch-supported retention value."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private subnets reach the internet. Real cost on AWS."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}