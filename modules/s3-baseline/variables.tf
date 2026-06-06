variable "bucket_name" {
  description = "Globally-unique S3 bucket name. Lowercase, 3-63 chars, no underscores."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 chars, lowercase, start/end with alphanumeric. No underscores."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK to use for SSE-KMS encryption. Pass from the kms module's output."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/.+$", var.kms_key_arn))
    error_message = "Must be a full KMS key ARN."
  }
}

variable "versioning_enabled" {
  description = "Enable S3 versioning. Required for NIS2 (c) business continuity. Default: true."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to destroy a non-empty bucket. KEEP FALSE in production. True only for ephemeral demos."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the bucket and related resources."
  type        = map(string)
  default     = {}
}

variable "logging_target_bucket" {
  description = "Bucket to send access logs to. If null, logging is disabled (e.g. for the log bucket itself)."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Object key prefix for delivered access logs."
  type        = string
  default     = "access-logs/"
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle rules. Disable on LocalStack (timeout issue). Always true on real AWS."
  type        = bool
  default     = false
}

variable "additional_policy_statements" {
  description = <<-EOT
    Additional IAM policy statements to merge into the bucket policy.
    Each statement is a fully-formed object (Sid, Effect, Principal, Action,
    Resource, optional Condition). The module's baseline statements
    (DenyInsecureTransport, DenyUnencryptedObjectUploads) are always included
    and cannot be removed. Callers can only ADD statements.
  EOT
  type        = any
  default     = []
}