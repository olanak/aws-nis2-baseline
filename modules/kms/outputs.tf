output "key_id" {
  description = "The globally unique KMS key ID."
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "The full ARN of the KMS key. Used by other modules (S3, CloudTrail, etc.) to reference this key."
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "The full alias name (with 'alias/' prefix)."
  value       = aws_kms_alias.this.name
}

output "alias_arn" {
  description = "The ARN of the alias."
  value       = aws_kms_alias.this.arn
}