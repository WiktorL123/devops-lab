variable "subscription_id" {
  description = "Azure subscription ID that owns the Terraform state backend."
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
  description = "Environment whose Terraform state is stored by this backend."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "Only the approved dev environment is currently supported."
  }
}

variable "location" {
  description = "Azure region for the Terraform state backend."
  type        = string
  default     = "polandcentral"

  validation {
    condition     = var.location == "polandcentral"
    error_message = "The approved state backend uses polandcentral."
  }
}

variable "resource_group_name" {
  description = "Name of the dedicated Terraform state resource group."
  type        = string
  default     = "rg-devopslab-tfstate-polandcentral"
}

variable "storage_account_name" {
  description = "Globally unique name of the Terraform state Storage Account."
  type        = string
  default     = "stdevopslabtfstate190c1f"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must contain 3-24 lowercase letters or digits."
  }
}

variable "container_name" {
  description = "Name of the private blob container used for Terraform state."
  type        = string
  default     = "tfstate"
}

variable "state_principals" {
  description = "Principals granted data-plane access to Terraform state."
  type = map(object({
    principal_id   = string
    principal_type = string
  }))

  validation {
    condition = alltrue([
      for principal in values(var.state_principals) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", principal.principal_id))
    ])
    error_message = "Every state principal ID must be a valid UUID."
  }

  validation {
    condition = alltrue([
      for principal in values(var.state_principals) :
      contains(["ServicePrincipal", "User"], principal.principal_type)
    ])
    error_message = "Every principal_type must be ServicePrincipal or User."
  }
}
