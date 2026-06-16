output "instance_arn" {
  description = "The Identity Center instance ARN (discovered)."
  value       = local.instance_arn
}

output "permission_set_arns" {
  description = "Map of permission set name -> ARN."
  value = {
    admin    = aws_ssoadmin_permission_set.admin.arn
    readonly = aws_ssoadmin_permission_set.readonly.arn
  }
}

output "demo_group_id" {
  description = "The demo admin group's ID in the identity store."
  value       = aws_identitystore_group.admins.group_id
}

output "assignment_count" {
  description = "Number of account assignments created."
  value       = 1
}