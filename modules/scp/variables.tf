variable "allowed_region" {
  description = "The only region operations are permitted in (EU data residency)."
  type        = string
  default     = "eu-central-1"
}

variable "targets" {
  description = "Map of target NAME -> OU/account ID to attach SCPs to. Keys must be known at plan time (names), values may be apply-time (IDs)."
  type        = map(string)

  validation {
    condition     = length(var.targets) > 0
    error_message = "At least one target is required."
  }
}

variable "global_service_exceptions" {
  description = "Global-service actions that must stay reachable even under a region lock (these services are region-agnostic)."
  type        = list(string)
  default = [
    "iam:*",
    "organizations:*",
    "sts:*",
    "cloudfront:*",
    "route53:*",
    "support:*",
    "waf:*",
  ]
}

variable "tags" {
  description = "Tags applied where supported."
  type        = map(string)
  default     = {}
}