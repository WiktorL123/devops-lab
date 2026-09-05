locals {
  common_tags = {
    environment = var.environment
    managed-by  = "terraform-bootstrap"
    project     = var.project_name
    purpose     = "terraform-state"
  }
}
