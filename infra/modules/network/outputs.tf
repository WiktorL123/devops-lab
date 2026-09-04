output "virtual_network_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "container_apps_subnet_id" {
  description = "Resource ID of the subnet delegated to Container Apps."
  value       = azurerm_subnet.container_apps.id
}

output "postgres_subnet_id" {
  description = "Resource ID of the subnet delegated to PostgreSQL Flexible Server."
  value       = azurerm_subnet.postgres.id
}

output "postgres_private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL private DNS zone."
  value       = azurerm_private_dns_zone.postgres.id
}

output "postgres_private_dns_zone_name" {
  description = "Name of the PostgreSQL private DNS zone."
  value       = azurerm_private_dns_zone.postgres.name
}
