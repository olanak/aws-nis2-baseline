variable "trail_name" {
  description = "Name of the CloudTrail trail. Lowercase, hyphens allowed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,128}$", var.trail_name))
    error_message = "Trail name must be 3-128 chars, lowercase, hyphens only."
  }
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket where CloudTrail will deliver logs. Must already exist (typically the logs bucket from modules/s3-baseline)."
  type        = string
}

variable "s3_key_prefix" {
  description = "Optional S3 key prefix for CloudTrail logs within the bucket."
  type        = string
  default     = "cloudtrail/"
}

variable "kms_key_arn" {
  description = "KMS CMK ARN to encrypt CloudTrail logs at rest. Pass from modules/kms output."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/.+$", var.kms_key_arn))
    error_message = "Must be a full KMS key ARN."
  }
}

variable "cloudwatch_logs_retention_days" {
  description = "Retention period for the CloudWatch Log Group. NIS2 Art. 23 requires retention to support 1-month incident reporting."
  type        = number
  default     = 365

  validation {
    condition     = contains([1, 7, 14, 30, 60, 90, 120, 180, 365, 731, 1827, 3653], var.cloudwatch_logs_retention_days)
    error_message = "Must be a CloudWatch-supported retention value."
  }
}

variable "is_multi_region_trail" {
  description = "Capture events across ALL regions. Default true (NIS2 effectiveness requires global visibility)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the trail and related resources."
  type        = map(string)
  default     = {}
}