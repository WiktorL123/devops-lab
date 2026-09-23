variable "domain_name" {
  description = "Fully qualified custom domain name assigned to the Container App."
  type        = string
}

variable "container_app_id" {
  description = "Resource ID of the Container App receiving the custom domain."
  type        = string
}

variable "container_app_environment_id" {
  description = "Resource ID of the Container Apps environment issuing the managed certificate."
  type        = string
}

variable "managed_certificate_name" {
  description = "Name of the managed certificate in the Container Apps environment."
  type        = string
}

variable "tags" {
  description = "Tags applied to the managed certificate."
  type        = map(string)
  default     = {}
}
