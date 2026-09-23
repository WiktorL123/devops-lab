resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.runtime_identity_id]
  }

  registry {
    server   = var.registry_server
    identity = var.runtime_identity_id
  }

  dynamic "secret" {
    for_each = var.key_vault_secrets

    content {
      name                = secret.key
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity_id
    }
  }

  ingress {
    external_enabled = var.external_ingress_enabled
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_environment_variables

        content {
          name        = env.key
          secret_name = env.value
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "deployment" {
  scope                            = azurerm_container_app.this.id
  role_definition_name             = "Container Apps Contributor"
  principal_id                     = var.deployment_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
