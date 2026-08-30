locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    environment = var.environment
    managed-by  = "terraform"
    project     = var.project_name
  }
}
