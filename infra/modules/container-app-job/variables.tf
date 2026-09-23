variable "name" {
  description = "Name of the Container Apps Job."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the job."
  type        = string
}

variable "location" {
  description = "Azure region for the job."
  type        = string
}

variable "container_app_environment_id" {
  description = "Resource ID of the Container Apps environment."
  type        = string
}

variable "container_name" {
  description = "Name of the migration container."
  type        = string
}

variable "image" {
  description = "Immutable migration image reference."
  type        = string
}

variable "registry_server" {
  description = "FQDN of the Azure Container Registry."
  type        = string
}

variable "runtime_identity_id" {
  description = "Resource ID of the user-assigned runtime managed identity."
  type        = string
}

variable "operator_principal_id" {
  description = "Principal ID allowed to run and observe this job."
  type        = string
}

variable "secret_environment_variables" {
  description = "Environment variables whose values come from job secrets."
  type        = map(string)
  default     = {}
}

variable "key_vault_secrets" {
  description = "Key Vault secret references exposed to the job."
  type = map(object({
    key_vault_secret_id = string
    identity_id         = string
  }))
  default = {}
}

variable "cpu" {
  description = "vCPU allocated to the migration replica."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the migration replica."
  type        = string
  default     = "0.5Gi"
}

variable "replica_timeout_in_seconds" {
  description = "Maximum duration of one migration execution."
  type        = number
  default     = 600
}

variable "replica_retry_limit" {
  description = "Number of retries after a failed migration replica."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to the Container Apps Job."
  type        = map(string)
  default     = {}
}
