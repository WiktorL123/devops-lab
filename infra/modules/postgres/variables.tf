variable "resource_group_name" {
  description = "Name of the existing resource group that owns the PostgreSQL server."
  type        = string
}

variable "location" {
  description = "Azure region for the PostgreSQL server."
  type        = string
}

variable "server_name" {
  description = "Globally unique name of the PostgreSQL Flexible Server."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.server_name))
    error_message = "server_name must contain 3-63 lowercase letters, digits, or hyphens and cannot start or end with a hyphen."
  }
}

variable "postgresql_version" {
  description = "Major PostgreSQL engine version."
  type        = string
  default     = "16"

  validation {
    condition     = var.postgresql_version == "16"
    error_message = "The approved PostgreSQL version for the lab is 16."
  }
}

variable "administrator_login" {
  description = "PostgreSQL administrator login name."
  type        = string
  default     = "devopslab_admin"
}

variable "database_name" {
  description = "Name of the application database."
  type        = string
  default     = "devops_lab"
}

variable "delegated_subnet_id" {
  description = "Resource ID of the subnet delegated to PostgreSQL Flexible Server."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the private DNS zone used by PostgreSQL."
  type        = string
}

variable "sku_name" {
  description = "Compute SKU used by the PostgreSQL Flexible Server."
  type        = string
  default     = "B_Standard_B1ms"

  validation {
    condition     = var.sku_name == "B_Standard_B1ms"
    error_message = "The approved cost-first PostgreSQL SKU is B_Standard_B1ms."
  }
}

variable "storage_mb" {
  description = "Provisioned PostgreSQL storage in MiB."
  type        = number
  default     = 32768

  validation {
    condition     = var.storage_mb == 32768
    error_message = "The approved PostgreSQL storage size is 32 GiB (32768 MiB)."
  }
}

variable "backup_retention_days" {
  description = "Number of days for which PostgreSQL backups are retained."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days == 7
    error_message = "The approved cost-first PostgreSQL backup retention is 7 days."
  }
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault that stores the database connection URL."
  type        = string
}

variable "database_url_secret_name" {
  description = "Name of the Key Vault secret containing the PostgreSQL connection URL."
  type        = string
  default     = "postgres-database-url"
}

variable "tags" {
  description = "Tags applied to PostgreSQL and its Key Vault secret."
  type        = map(string)
  default     = {}
}
