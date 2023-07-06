data "azurerm_client_config" "current" {}



resource "azuread_user" "demo_user" {
  display_name        = "Owain Osborne-Walsh"
  password            = "AKSdemo123"
  user_principal_name = "oow@${var.azure_domain}"
}

resource "azuread_group" "demo_aks_jit_group" {
  depends_on = [ azuread_user.demo_user ]
  display_name     = "oow-aks-jit-azure-cvm-attestation-ns"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}