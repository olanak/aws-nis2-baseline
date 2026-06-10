variable "recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,256}$", var.recorder_name))
    error_message = "Recorder name must be 1-256 chars, alphanumeric plus hyphen/underscore."
  }
}

variable "delivery_channel_name" {
  description = "Name of the AWS Config delivery channel."
  type        = string
}

variable "role_name" {
  description = "Name of the IAM service role AWS Config assumes."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket where Config delivers configuration snapshots/history. Typically the shared logs bucket."
  type        = string
}

variable "s3_key_prefix" {
  description = "Optional S3 key prefix for Config deliverables."
  type        = string
  default     = "config"
}

variable "include_global_resource_types" {
  description = "Record global resources (IAM users, roles, policies). Should be true on exactly one region in a multi-region setup."
  type        = bool
  default     = true
}

variable "enable_rules" {
  description = "Whether to deploy the curated set of NIS2-aligned managed Config rules."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Config resources."
  type        = map(string)
  default     = {}
}