output "topic_arn" {
  description = "ARN of the security-alerts SNS topic."
  value       = aws_sns_topic.alerts.arn
}

output "kms_key_arn" {
  description = "ARN of the CMK encrypting the alerts topic."
  value       = aws_kms_key.alerts.arn
}

output "guardduty_rule_arn" {
  description = "ARN of the GuardDuty-finding EventBridge rule."
  value       = aws_cloudwatch_event_rule.guardduty.arn
}

output "securityhub_rule_arn" {
  description = "ARN of the Security Hub-finding EventBridge rule."
  value       = aws_cloudwatch_event_rule.securityhub.arn
}