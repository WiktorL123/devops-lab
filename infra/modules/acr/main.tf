resource "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = true
  role_assignment_mode          = "AbacRepositoryPermissions"

  tags = var.tags
}

resource "azurerm_role_assignment" "repository_writer" {
  for_each = var.repository_writers

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Container Registry Repository Writer"
  principal_id         = each.value.principal_id
  principal_type       = "ServicePrincipal"

  condition_version = "2.0"
  condition         = <<-CONDITION
    (
      (
        !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
        AND
        !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
        AND
        !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/write'})
        AND
        !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/write'})
      )
      OR
      @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase '${each.value.repository_name}'
    )
  CONDITION
}
