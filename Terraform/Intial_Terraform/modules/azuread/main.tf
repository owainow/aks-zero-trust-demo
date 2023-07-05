data "azurerm_client_config" "current" {}



resource "azuread_user" "demo_user" {
  display_name        = "Owain Osborne-Walsh"
  owners              = [data.azuread_client_config.current.object_id]
  password            = "aksdemo2023"
  user_principal_name = "oow@contoso.com"
}

resource "azuread_group" "demo_aks_jit_group" {
  depends_on = [ azuread_user.demo_user ]
  display_name     = "demo-aks-jit-group"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

    members = [
    azuread_user.demo_user.object_id
  ]
}