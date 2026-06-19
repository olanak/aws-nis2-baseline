variable "enable_default_standards" {
  description = "Whether Security Hub auto-enables its default standards on activation. Set false so we control standards explicitly (only FSBP)."
  type        = bool
  default     = false
}

variable "enable_guardduty_integration" {
  description = "Subscribe to GuardDuty as a finding product so its findings flow into Security Hub."
  type        = bool
  default     = true
}

