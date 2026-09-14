data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "terraform_plan" {
  name                = "id-gh-tf-plan-dev"
  resource_group_name = "rg-${local.name_prefix}-${var.location}"
}

data "azurerm_user_assigned_identity" "terraform_apply" {
  name                = "id-gh-tf-apply-dev"
  resource_group_name = "rg-${local.name_prefix}-${var.location}"
}

data "azurerm_user_assigned_identity" "frontend_deploy" {
  name                = "id-gh-frontend-deploy-dev"
  resource_group_name = "rg-${local.name_prefix}-${var.location}"
}

data "azurerm_user_assigned_identity" "backend_deploy" {
  name                = "id-gh-backend-deploy-dev"
  resource_group_name = "rg-${local.name_prefix}-${var.location}"
}
