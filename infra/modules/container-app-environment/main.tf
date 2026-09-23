resource "azurerm_container_app_environment" "this" {
  name                = var.environment_name
  resource_group_name = var.resource_group_name
  location            = var.location

  infrastructure_subnet_id       = var.infrastructure_subnet_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  logs_destination               = "log-analytics"
  internal_load_balancer_enabled = false
  zone_redundancy_enabled        = false

  tags = var.tags
}
