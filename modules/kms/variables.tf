variable "key_alias" {
  description = "Alias for the KMS key (without the 'alias/' prefix). Example: 'nis2-s3-baseline'"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.key_alias))
    error_message = "Alias must contain only alphanumerics, hyphens, underscores, and forward slashes."
  }
}

variable "description" {
  description = "Human-readable description of what this key encrypts."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Waiting period before key deletion (7-30 days). NIS2 favors longer windows to prevent accidental data loss."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "tags" {
  description = "Tags applied to the key. Recommended: nis2_control, iso_control, data_classification."
  type        = map(string)
  default     = {}
}