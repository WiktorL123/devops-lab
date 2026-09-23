variable "name" {
  description = "Name of the Container App."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the Container App."
  type        = string
}

variable "container_app_environment_id" {
  description = "Resource ID of the Container Apps environment."
  type        = string
}

variable "container_name" {
  description = "Name of the workload container."
  type        = string
}

variable "image" {
  description = "Immutable container image reference to deploy."
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

variable "deployment_principal_id" {
  description = "Principal ID allowed to update this Container App."
  type        = string
}

variable "external_ingress_enabled" {
  description = "Whether ingress is reachable outside the Container Apps environment."
  type        = bool
}

variable "target_port" {
  description = "Port exposed by the application container."
  type        = number
}

variable "cpu" {
  description = "vCPU allocated to each replica."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to each replica."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum number of running replicas."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of running replicas."
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Non-secret environment variables exposed to the container."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Environment variables whose values come from Container App secrets."
  type        = map(string)
  default     = {}
}

variable "key_vault_secrets" {
  description = "Key Vault secret references exposed to the Container App."
  type = map(object({
    key_vault_secret_id = string
    identity_id         = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the Container App."
  type        = map(string)
  default     = {}
}
