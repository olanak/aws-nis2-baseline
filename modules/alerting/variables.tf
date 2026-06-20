variable "topic_name" {
  description = "Name of the SNS topic that receives detection alerts."
  type        = string
  default     = "nis2-security-alerts"
}

variable "alert_email" {
  description = "Optional email to subscribe to alerts. Empty = no subscription (real subscriptions need out-of-band confirmation; left off for LocalStack/CI)."
  type        = string
  default     = ""
}

variable "min_severity_label" {
  description = "Minimum GuardDuty severity label to alert on (LOW/MEDIUM/HIGH). GuardDuty numeric: LOW>=1, MEDIUM>=4, HIGH>=7."
  type        = number
  default     = 7

  validation {
    condition     = var.min_severity_label >= 1 && var.min_severity_label <= 8
    error_message = "Severity must be between 1 and 8."
  }
}

variable "tags" {
  description = "Tags applied to the topic and key."
  type        = map(string)
  default     = {}
}