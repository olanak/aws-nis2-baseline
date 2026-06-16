variable "org_feature_set" {
  description = "ALL enables SCPs; CONSOLIDATED_BILLING does not. NIS2 guardrails need ALL."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "CONSOLIDATED_BILLING"], var.org_feature_set)
    error_message = "Must be ALL or CONSOLIDATED_BILLING."
  }
}

variable "enabled_policy_types" {
  description = "Org policy types to enable at the root. SERVICE_CONTROL_POLICY required for SCPs."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "OUs to create under the root, by name."
  type        = list(string)
  default     = ["Workloads", "Security", "Sandbox"]
}

variable "aws_service_access_principals" {
  description = "AWS services granted trusted access in the org (e.g., for delegated admin)."
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
  ]
}

variable "tags" {
  description = "Tags applied where the resource supports them."
  type        = map(string)
  default     = {}
}