resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = var.sku
  retention_in_days = var.retention_in_days
  daily_quota_gb    = var.daily_quota_gb

  local_authentication_enabled   = var.local_authentication_enabled
  internet_ingestion_access_type = var.internet_ingestion_access_type
  internet_query_access_type     = var.internet_query_access_type

  tags = var.tags
}
