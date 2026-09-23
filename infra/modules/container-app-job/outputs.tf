output "id" {
  description = "Resource ID of the Container Apps Job."
  value       = azurerm_container_app_job.this.id
}

output "name" {
  description = "Name of the Container Apps Job."
  value       = azurerm_container_app_job.this.name
}

output "operator_role_assignment_id" {
  description = "ID of the job operator role assignment."
  value       = azurerm_role_assignment.operator.id
}
