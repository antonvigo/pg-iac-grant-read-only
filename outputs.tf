output "grants_to_group" {
  description = "Name of read-only role"
  value       = var.group_role
}

output "sql_script" {
  description = "Applied SQL script"
  value       = local.sql_script
}
