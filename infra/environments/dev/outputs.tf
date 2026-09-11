output "virtual_network_id" {
  description = "Resource ID of the dev virtual network."
  value       = module.network.virtual_network_id
}

output "container_apps_subnet_id" {
  description = "Resource ID of the dev Container Apps infrastructure subnet."
  value       = module.network.container_apps_subnet_id
}

output "postgres_subnet_id" {
  description = "Resource ID of the dev PostgreSQL Flexible Server subnet."
  value       = module.network.postgres_subnet_id
}

output "postgres_private_dns_zone_id" {
  description = "Resource ID of the dev PostgreSQL private DNS zone."
  value       = module.network.postgres_private_dns_zone_id
}

output "postgres_private_dns_zone_name" {
  description = "Name of the dev PostgreSQL private DNS zone."
  value       = module.network.postgres_private_dns_zone_name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the dev Log Analytics workspace."
  value       = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  description = "Name of the dev Log Analytics workspace."
  value       = module.log_analytics.name
}

output "log_analytics_workspace_customer_id" {
  description = "Non-secret workspace ID used by services that send logs to Log Analytics."
  value       = module.log_analytics.workspace_id
}

output "container_registry_id" {
  description = "Resource ID of the dev Azure Container Registry."
  value       = module.acr.id
}

output "container_registry_name" {
  description = "Name of the dev Azure Container Registry."
  value       = module.acr.name
}

output "container_registry_login_server" {
  description = "Login server of the dev Azure Container Registry."
  value       = module.acr.login_server
}
