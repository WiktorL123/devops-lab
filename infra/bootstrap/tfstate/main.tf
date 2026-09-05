resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  resource_group_name  = azurerm_resource_group.tfstate.name
  location             = azurerm_resource_group.tfstate.location
  storage_account_name = var.storage_account_name
  container_name       = var.container_name
  state_principals     = var.state_principals
  tags                 = local.common_tags
}
