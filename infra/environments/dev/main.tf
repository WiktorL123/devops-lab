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
