output "resource_group_name" {
  description = "Name of the dedicated Terraform state resource group."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_id" {
  description = "Resource ID of the Terraform state Storage Account."
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Name of the Terraform state Storage Account."
  value       = module.storage.storage_account_name
}

output "container_id" {
  description = "Resource ID of the private Terraform state container."
  value       = module.storage.container_id
}

output "container_name" {
  description = "Name of the private Terraform state container."
  value       = module.storage.container_name
}
