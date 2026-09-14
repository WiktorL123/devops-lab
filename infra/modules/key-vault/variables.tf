variable "resource_group_name" {
  description = "Name of the existing resource group that owns the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID associated with the Key Vault."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a valid UUID."
  }
}

variable "vault_name" {
  description = "Globally unique name of the Azure Key Vault."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.vault_name))
    error_message = "vault_name must contain 3-24 alphanumeric characters or hyphens, start with a letter, and end with an alphanumeric character."
  }
}

variable "sku_name" {
  description = "Service tier used by the Azure Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = var.sku_name == "standard"
    error_message = "The approved cost-first Azure Key Vault SKU is standard."
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days for which deleted vault content remains recoverable."
  type        = number
  default     = 12

  validation {
    condition     = var.soft_delete_retention_days == 12
    error_message = "The approved lab soft-delete retention period is 12 days."
  }
}

variable "tags" {
  description = "Tags applied to the Azure Key Vault."
  type        = map(string)
  default     = {}
}
