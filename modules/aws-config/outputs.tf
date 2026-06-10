output "recorder_name" {
  description = "Name of the Config configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "delivery_channel_id" {
  description = "ID of the Config delivery channel."
  value       = aws_config_delivery_channel.this.id
}

output "role_arn" {
  description = "ARN of the Config service role."
  value       = aws_iam_role.config.arn
}

output "rule_names" {
  description = "Names of the deployed managed Config rules."
  value       = [for r in aws_config_config_rule.managed : r.name]
}