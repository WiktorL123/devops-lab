module "network" {
  source = "../../modules/network"

  resource_group_name           = "rg-${local.name_prefix}-${var.location}"
  location                      = var.location
  virtual_network_name          = "vnet-${local.name_prefix}-${var.location}"
  virtual_network_address_space = ["10.20.0.0/16"]

  container_apps_subnet_name             = "snet-container-apps"
  container_apps_subnet_address_prefixes = ["10.20.0.0/23"]

  postgres_subnet_name             = "snet-postgres"
  postgres_subnet_address_prefixes = ["10.20.2.0/28"]

  postgres_private_dns_zone_name = "${local.name_prefix}.private.postgres.database.azure.com"
  postgres_private_dns_link_name = "pdnslink-${local.name_prefix}-postgres"

  tags = local.common_tags
}

module "log_analytics" {
  source = "../../modules/log-analytics"

  resource_group_name = "rg-${local.name_prefix}-${var.location}"
  location            = var.location
  workspace_name      = "law-${local.name_prefix}-${var.location}"

  sku                            = "PerGB2018"
  retention_in_days              = 30
  daily_quota_gb                 = 0.1
  local_authentication_enabled   = true
  internet_ingestion_access_type = "Enabled"
  internet_query_access_type     = "Enabled"

  tags = local.common_tags
}

module "runtime_identity" {
  source = "../../modules/identity"

  resource_group_name = "rg-${local.name_prefix}-${var.location}"
  location            = var.location

  identities = {
    frontend = "id-app-frontend-dev"
    backend  = "id-app-backend-dev"
  }

  tags = local.common_tags
}

module "acr" {
  source = "../../modules/acr"

  resource_group_name = "rg-${local.name_prefix}-${var.location}"
  location            = var.location
  registry_name       = "acrdevopslabdev190c1f"
  sku                 = "Basic"

  repository_writers = {
    frontend = {
      principal_id    = data.azurerm_user_assigned_identity.frontend_deploy.principal_id
      repository_name = "frontend"
    }
    backend = {
      principal_id    = data.azurerm_user_assigned_identity.backend_deploy.principal_id
      repository_name = "backend"
    }
  }

  repository_readers = {
    frontend = {
      principal_id    = module.runtime_identity.principal_ids.frontend
      repository_name = "frontend"
    }
    backend = {
      principal_id    = module.runtime_identity.principal_ids.backend
      repository_name = "backend"
    }
  }

  tags = local.common_tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  resource_group_name        = "rg-${local.name_prefix}-${var.location}"
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  vault_name                 = "kv-devopslab-dev-190c1f"
  sku_name                   = "standard"
  soft_delete_retention_days = 12

  secret_readers = {
    terraform_plan  = data.azurerm_user_assigned_identity.terraform_plan.principal_id
    backend_runtime = module.runtime_identity.principal_ids.backend
  }

  secret_officers = {
    terraform_apply = data.azurerm_user_assigned_identity.terraform_apply.principal_id
  }

  tags = local.common_tags
}

module "postgres" {
  source = "../../modules/postgres"

  resource_group_name = "rg-${local.name_prefix}-${var.location}"
  location            = var.location
  server_name         = "psql-${local.name_prefix}-${var.location}"

  postgresql_version  = "16"
  administrator_login = "devopslab_admin"
  database_name       = "devops_lab"

  delegated_subnet_id = module.network.postgres_subnet_id
  private_dns_zone_id = module.network.postgres_private_dns_zone_id

  sku_name              = "B_Standard_B1ms"
  storage_mb            = 32768
  backup_retention_days = 7

  key_vault_id             = module.key_vault.id
  database_url_secret_name = "postgres-database-url"

  tags = local.common_tags

  depends_on = [module.key_vault]
}
