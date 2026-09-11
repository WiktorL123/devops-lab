variable "resource_group_name" {
  description = "Name of the existing resource group that owns the container registry."
  type        = string
}

variable "location" {
  description = "Azure region for the container registry."
  type        = string
}

variable "registry_name" {
  description = "Globally unique name of the Azure Container Registry."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.registry_name))
    error_message = "registry_name must contain 5-50 lowercase letters or digits."
  }
}

variable "sku" {
  description = "Service tier used by the Azure Container Registry."
  type        = string
  default     = "Basic"

  validation {
    condition     = var.sku == "Basic"
    error_message = "The approved cost-first Azure Container Registry SKU is Basic."
  }
}

variable "repository_writers" {
  description = "Deployment principals granted write access to one named repository each."
  type = map(object({
    principal_id    = string
    repository_name = string
  }))

  validation {
    condition = alltrue([
      for writer in values(var.repository_writers) :
      can(regex("^[a-z0-9]+([._/-][a-z0-9]+)*$", writer.repository_name))
    ])
    error_message = "Each repository_name must be a valid lowercase ACR repository path."
  }
}

variable "tags" {
  description = "Tags applied to the Azure Container Registry."
  type        = map(string)
  default     = {}
}
