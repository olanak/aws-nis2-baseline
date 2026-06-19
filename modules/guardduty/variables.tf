variable "finding_publishing_frequency" {
  description = "How often GuardDuty exports findings to EventBridge/Security Hub. FIFTEEN_MINUTES gives the tightest detection-to-alert latency (NIS2 incident handling)."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "enable_s3_protection" {
  description = "Enable GuardDuty S3 data-event monitoring."
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Enable GuardDuty EBS malware scanning on suspicious findings."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the detector."
  type        = map(string)
  default     = {}
}