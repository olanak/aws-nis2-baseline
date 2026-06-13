output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "flow_log_group_arn" {
  description = "ARN of the flow-log CloudWatch Log Group. Used by the Week 4 detection module."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_log_id" {
  description = "ID of the VPC flow log."
  value       = aws_flow_log.this.id
}