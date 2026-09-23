resource "azurerm_container_app_custom_domain" "this" {
  name             = var.domain_name
  container_app_id = var.container_app_id

  lifecycle {
    # Azure completes the managed-certificate binding asynchronously.
    ignore_changes = [
      certificate_binding_type,
      container_app_environment_certificate_id,
    ]
  }
}

resource "azurerm_container_app_environment_managed_certificate" "this" {
  name                         = var.managed_certificate_name
  container_app_environment_id = var.container_app_environment_id
  subject_name                 = var.domain_name
  domain_control_validation    = "CNAME"

  tags = var.tags

  depends_on = [azurerm_container_app_custom_domain.this]
}
