output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.this.arn
}

output "trail_name" {
  description = "Name of the CloudTrail trail."
  value       = aws_cloudtrail.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group receiving trail events. Used by Week 4 detection module."
  value       = aws_cloudwatch_log_group.trail.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.trail.name
}