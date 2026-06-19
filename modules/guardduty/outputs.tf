output "detector_id" {
  description = "The GuardDuty detector ID (consumed by Security Hub product subscription)."
  value       = aws_guardduty_detector.this.id
}

output "detector_arn" {
  description = "The GuardDuty detector ARN."
  value       = aws_guardduty_detector.this.arn
}