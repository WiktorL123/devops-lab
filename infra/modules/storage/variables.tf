variable "resource_group_name" {
  description = "Name of the resource group that owns the Storage Account."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage Account."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique name of the Terraform state Storage Account."
  type        = string
}

variable "container_name" {
  description = "Name of the private blob container used for Terraform state."
  type        = string
}

variable "state_principals" {
  description = "Principals granted Storage Blob Data Contributor on the state container."
  type = map(object({
    principal_id   = string
    principal_type = string
  }))
}

variable "tags" {
  description = "Tags applied to resources that support tags."
  type        = map(string)
  default     = {}
}
