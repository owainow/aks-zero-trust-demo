data "azurerm_client_config" "current" {}


# NEED TO GET EMAIL DOMAIN FOR USER PRINCIPLE DYNAMICALLY PROBABLY FROM AZURE_RM CLIENT CONFIG
resource "azuread_user" "demo_user" {
  display_name        = "Owain Osborne-Walsh"
  owners              = [data.azuread_client_config.current.object_id]
  password            = "AKSdemo123"
  user_principal_name = "oow@contoso.com"
}

resource "azuread_group" "demo_aks_jit_group" {
  depends_on = [ azuread_user.demo_user ]
  display_name     = "oow-aks-jit-azure-cvm-attestation-ns"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

}