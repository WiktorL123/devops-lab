output "ids" {
  description = "Resource IDs of the user-assigned managed identities, keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => identity.id
  }
}

output "client_ids" {
  description = "Client IDs of the user-assigned managed identities, keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => identity.client_id
  }
}

output "principal_ids" {
  description = "Principal IDs of the user-assigned managed identities, keyed by logical name."
  value = {
    for key, identity in azurerm_user_assigned_identity.this : key => identity.principal_id
  }
}
