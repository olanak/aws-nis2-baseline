output "organization_id" {
  description = "The organization ID."
  value       = aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "The organization ARN."
  value       = aws_organizations_organization.this.arn
}

output "root_id" {
  description = "The root ID — SCPs and OUs attach here."
  value       = aws_organizations_organization.this.roots[0].id
}

output "ou_ids" {
  description = "Map of OU name -> OU id. SCPs attach to these in W3-2."
  value       = { for k, ou in aws_organizations_organizational_unit.this : k => ou.id }
}

output "ou_arns" {
  description = "Map of OU name -> OU arn."
  value       = { for k, ou in aws_organizations_organizational_unit.this : k => ou.arn }
}