variable "resource_group_name" {
  description = "Name of the existing resource group that owns the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "Azure region for the Log Analytics workspace."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{2,61}[A-Za-z0-9]$", var.workspace_name))
    error_message = "workspace_name must contain 4-63 letters, digits, or hyphens and cannot start or end with a hyphen."
  }
}

variable "sku" {
  description = "Billing SKU used by the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = var.sku == "PerGB2018"
    error_message = "The approved cost-first Log Analytics SKU is PerGB2018."
  }
}

variable "retention_in_days" {
  description = "Workspace-level data retention in days."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Maximum daily log ingestion in GB; -1 disables the cap."
  type        = number
  default     = 0.1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 0.023
    error_message = "daily_quota_gb must be -1 or at least 0.023 GB."
  }
}

variable "local_authentication_enabled" {
  description = "Whether workspace shared-key authentication remains available for compatible integrations."
  type        = bool
  default     = true
}

variable "internet_ingestion_access_type" {
  description = "Public network access mode for log ingestion."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled", "SecuredByPerimeter"], var.internet_ingestion_access_type)
    error_message = "internet_ingestion_access_type must be Enabled, Disabled, or SecuredByPerimeter."
  }
}

variable "internet_query_access_type" {
  description = "Public network access mode for log queries."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled", "SecuredByPerimeter"], var.internet_query_access_type)
    error_message = "internet_query_access_type must be Enabled, Disabled, or SecuredByPerimeter."
  }
}

variable "tags" {
  description = "Tags applied to the Log Analytics workspace."
  type        = map(string)
  default     = {}
}
