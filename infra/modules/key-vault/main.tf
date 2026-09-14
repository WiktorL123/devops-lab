resource "azurerm_key_vault" "this" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  rbac_authorization_enabled      = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  public_network_access_enabled   = true
  purge_protection_enabled        = false
  soft_delete_retention_days      = var.soft_delete_retention_days

  tags = var.tags
}
