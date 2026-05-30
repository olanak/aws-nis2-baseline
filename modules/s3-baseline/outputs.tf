output "bucket_id" {
  description = "Bucket name (S3 bucket IDs == bucket names)."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "Full ARN of the bucket. Used by other modules (CloudTrail, log destinations, etc.)."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name. Use this in CloudFront / cross-region replication."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}