output "id" {
  description = "Resource ID of the Azure Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Azure Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI used by applications to access the Azure Key Vault data plane."
  value       = azurerm_key_vault.this.vault_uri
}
