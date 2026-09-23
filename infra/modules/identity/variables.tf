variable "resource_group_name" {
  description = "Name of the existing resource group that owns the managed identities."
  type        = string
}

variable "location" {
  description = "Azure region for the managed identities."
  type        = string
}

variable "identities" {
  description = "Map of stable logical keys to user-assigned managed identity names."
  type        = map(string)

  validation {
    condition = alltrue([
      for name in values(var.identities) :
      can(regex("^[a-zA-Z0-9_-]{3,128}$", name))
    ])
    error_message = "Each managed identity name must contain 3-128 alphanumeric characters, hyphens, or underscores."
  }
}

variable "tags" {
  description = "Tags applied to the managed identities."
  type        = map(string)
  default     = {}
}
