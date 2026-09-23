output "domain_name" {
  description = "Custom domain name assigned to the Container App."
  value       = azurerm_container_app_custom_domain.this.name
}

output "custom_domain_id" {
  description = "Resource ID of the Container App custom-domain binding."
  value       = azurerm_container_app_custom_domain.this.id
}

output "managed_certificate_id" {
  description = "Resource ID of the Container Apps managed certificate."
  value       = azurerm_container_app_environment_managed_certificate.this.id
}
