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

output "key_vault_id" {
  description = "Resource ID of the dev Azure Key Vault."
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Name of the dev Azure Key Vault."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Data-plane URI of the dev Azure Key Vault."
  value       = module.key_vault.vault_uri
}

output "postgres_server_id" {
  description = "Resource ID of the dev PostgreSQL Flexible Server."
  value       = module.postgres.server_id
}

output "postgres_server_name" {
  description = "Name of the dev PostgreSQL Flexible Server."
  value       = module.postgres.server_name
}

output "postgres_server_fqdn" {
  description = "Private FQDN of the dev PostgreSQL Flexible Server."
  value       = module.postgres.server_fqdn
}

output "postgres_database_name" {
  description = "Name of the dev application database."
  value       = module.postgres.database_name
}

output "postgres_database_url_secret_id" {
  description = "Versionless ID of the Key Vault secret containing the PostgreSQL connection URL."
  value       = module.postgres.database_url_secret_id
}

output "frontend_runtime_identity_id" {
  description = "Resource ID of the frontend runtime managed identity."
  value       = module.runtime_identity.ids.frontend
}

output "frontend_runtime_identity_client_id" {
  description = "Client ID of the frontend runtime managed identity."
  value       = module.runtime_identity.client_ids.frontend
}

output "frontend_runtime_identity_principal_id" {
  description = "Principal ID of the frontend runtime managed identity."
  value       = module.runtime_identity.principal_ids.frontend
}

output "backend_runtime_identity_id" {
  description = "Resource ID of the backend runtime managed identity."
  value       = module.runtime_identity.ids.backend
}

output "backend_runtime_identity_client_id" {
  description = "Client ID of the backend runtime managed identity."
  value       = module.runtime_identity.client_ids.backend
}

output "backend_runtime_identity_principal_id" {
  description = "Principal ID of the backend runtime managed identity."
  value       = module.runtime_identity.principal_ids.backend
}

output "container_app_environment_id" {
  description = "Resource ID of the dev Container Apps environment."
  value       = module.container_app_environment.id
}

output "container_app_environment_name" {
  description = "Name of the dev Container Apps environment."
  value       = module.container_app_environment.name
}

output "container_app_environment_default_domain" {
  description = "Default domain assigned to the dev Container Apps environment."
  value       = module.container_app_environment.default_domain
}

output "container_app_environment_static_ip_address" {
  description = "Static IP address assigned to the dev Container Apps environment."
  value       = module.container_app_environment.static_ip_address
}

output "frontend_container_app_id" {
  description = "Resource ID of the frontend Container App."
  value       = module.frontend.id
}

output "frontend_container_app_fqdn" {
  description = "Azure-generated FQDN of the frontend Container App."
  value       = module.frontend.latest_revision_fqdn
}

output "frontend_custom_domain" {
  description = "Public custom domain assigned to the frontend Container App."
  value       = module.frontend_custom_domain.domain_name
}

output "frontend_managed_certificate_id" {
  description = "Resource ID of the managed TLS certificate for the frontend custom domain."
  value       = module.frontend_custom_domain.managed_certificate_id
}

output "backend_container_app_id" {
  description = "Resource ID of the internal backend Container App."
  value       = module.backend.id
}

output "backend_container_app_fqdn" {
  description = "Internal FQDN of the backend Container App."
  value       = module.backend.latest_revision_fqdn
}

output "migration_job_id" {
  description = "Resource ID of the PostgreSQL migration Container Apps Job."
  value       = module.migration_job.id
}

output "migration_job_name" {
  description = "Name of the PostgreSQL migration Container Apps Job."
  value       = module.migration_job.name
}
