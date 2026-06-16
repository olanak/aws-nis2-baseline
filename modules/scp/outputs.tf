output "policy_ids" {
  description = "Map of SCP name -> policy id."
  value = {
    deny_root       = aws_organizations_policy.deny_root.id
    region_lock     = aws_organizations_policy.region_lock.id
    protect_logging = aws_organizations_policy.protect_logging.id
  }
}

output "attachment_count" {
  description = "Number of policy-to-target attachments created."
  value       = length(aws_organizations_policy_attachment.this)
}