variable "session_duration" {
  description = "ISO-8601 session duration for permission sets. Short sessions reduce credential-exposure window (NIS2 access control)."
  type        = string
  default     = "PT1H"

  validation {
    condition     = can(regex("^PT[0-9]+[HM]$", var.session_duration))
    error_message = "Must be an ISO-8601 duration like PT1H or PT30M."
  }
}

variable "demo_group_name" {
  description = "Name of the demo identity-store group to create and assign."
  type        = string
  default     = "nis2-platform-admins"
}

variable "assignment_account_id" {
  description = "Account ID to assign the admin permission set to (the management account in the demo)."
  type        = string
  default     = "000000000000"
}

variable "tags" {
  description = "Tags applied to permission sets."
  type        = map(string)
  default     = {}
}