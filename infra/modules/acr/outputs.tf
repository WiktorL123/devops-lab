output "id" {
  description = "Resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server used to push and pull container images."
  value       = azurerm_container_registry.this.login_server
}
