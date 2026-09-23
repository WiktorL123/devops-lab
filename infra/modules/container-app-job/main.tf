resource "azurerm_container_app_job" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  replica_retry_limit          = var.replica_retry_limit

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

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  template {
    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

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

resource "azurerm_role_assignment" "operator" {
  scope                            = azurerm_container_app_job.this.id
  role_definition_name             = "Container Apps Jobs Operator"
  principal_id                     = var.operator_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
