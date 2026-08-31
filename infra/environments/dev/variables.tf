variable "subscription_id" {
  description = "Azure subscription ID targeted by the dev environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid UUID."
  }
}

variable "project_name" {
  description = "Stable project identifier used in Azure resource names and tags."
  type        = string
  default     = "devopslab"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment identifier."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "Only the approved dev environment is currently supported."
  }
}

variable "location" {
  description = "Azure region selected for the dev platform."
  type        = string
  default     = "polandcentral"

  validation {
    condition     = var.location == "polandcentral"
    error_message = "The approved dev architecture uses polandcentral."
  }
}
