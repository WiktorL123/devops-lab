variable "resource_group_name" {
  description = "Name of the existing resource group that owns the network resources."
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "virtual_network_address_space" {
  description = "Address spaces assigned to the virtual network."
  type        = list(string)
}

variable "container_apps_subnet_name" {
  description = "Name of the subnet delegated to the Container Apps environment."
  type        = string
}

variable "container_apps_subnet_address_prefixes" {
  description = "Address prefixes assigned to the Container Apps infrastructure subnet."
  type        = list(string)
}

variable "postgres_subnet_name" {
  description = "Name of the subnet delegated to PostgreSQL Flexible Server."
  type        = string
}

variable "postgres_subnet_address_prefixes" {
  description = "Address prefixes assigned to the PostgreSQL Flexible Server subnet."
  type        = list(string)
}

variable "postgres_private_dns_zone_name" {
  description = "Name of the private DNS zone used by PostgreSQL Flexible Server."
  type        = string
}

variable "postgres_private_dns_link_name" {
  description = "Name of the link between the PostgreSQL private DNS zone and the virtual network."
  type        = string
}

variable "tags" {
  description = "Tags applied to resources that support tags."
  type        = map(string)
  default     = {}
}
