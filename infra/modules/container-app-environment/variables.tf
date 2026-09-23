variable "resource_group_name" {
  description = "Name of the existing resource group that owns the Container Apps environment."
  type        = string
}

variable "location" {
  description = "Azure region for the Container Apps environment."
  type        = string
}

variable "environment_name" {
  description = "Name of the Container Apps environment."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$", var.environment_name))
    error_message = "environment_name must contain 2-60 alphanumeric characters or hyphens and cannot start or end with a hyphen."
  }
}

variable "infrastructure_subnet_id" {
  description = "Resource ID of the subnet delegated to the Container Apps environment."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace that receives platform logs."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Container Apps environment."
  type        = map(string)
  default     = {}
}
