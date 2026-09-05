output "storage_account_id" {
  description = "Resource ID of the Terraform state Storage Account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the Terraform state Storage Account."
  value       = azurerm_storage_account.this.name
}

output "container_id" {
  description = "Resource ID of the private Terraform state container."
  value       = azurerm_storage_container.this.id
}

output "container_name" {
  description = "Name of the private Terraform state container."
  value       = azurerm_storage_container.this.name
}
