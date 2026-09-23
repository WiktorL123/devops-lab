locals {
  name_prefix = "${var.project_name}-${var.environment}"

  initial_image_tag = "0.1.0-7a1d6c8"

  common_tags = {
    environment = var.environment
    managed-by  = "terraform"
    project     = var.project_name
  }
}
