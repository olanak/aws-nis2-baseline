output "account_id" {
  description = "The Security Hub account resource ID."
  value       = aws_securityhub_account.this.id
}

output "fsbp_standard_arn" {
  description = "The subscribed FSBP standard ARN."
  value       = aws_securityhub_standards_subscription.fsbp.standards_arn
}

output "guardduty_integration_enabled" {
  description = "Whether the GuardDuty product subscription is active."
  value       = var.enable_guardduty_integration
}