output "id" {
  description = "Resource ID of the Container App."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Name of the Container App."
  value       = azurerm_container_app.this.name
}

output "latest_revision_fqdn" {
  description = "FQDN of the latest Container App revision."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "deployment_role_assignment_id" {
  description = "ID of the deployment identity role assignment."
  value       = azurerm_role_assignment.deployment.id
}
