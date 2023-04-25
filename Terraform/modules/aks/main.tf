data "azurerm_client_config" "current" {}

locals {
  arm_template = file("${path.module}/main.json")
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name                = "AKS-C"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = local.arm_template
  parameters_content = jsonencode({
    automatedDeployment            = { value = var.automated_deployment }
    resourceName                   = { value = var.cluster_name }
    managedNodeResourceGroup       = { value = var.node_resource_group_name }
    aksPaidSkuForSLA               = { value = var.AksPaidSkuForSLA }
    systemPoolType                 = { value = var.SystemPoolType }
    agentVMSize                    = { value = var.agentVMSize }
    nodePoolName                   = { value = var.nodePoolName }
    agentCountMax                  = { value = var.agentCountMax }
    osDiskType                     = { value = var.osDiskType }
    custom_vnet                    = { value = var.custom_vnet }
    enable_aad                     = { value = var.enable_aad }
    enableAzureRBAC                = { value = var.enableAzureRBAC }
    adminPrincipalId               = { value = data.azurerm_client_config.current.object_id }
    registries_sku                 = { value = var.registries_sku }
    acrPushRolePrincipalId         = { value = data.azurerm_client_config.current.object_id }
    privateLinks                   = { value = var.privateLinks }
    omsagent                       = { value = var.omsagent }
    retentionInDays                = { value = var.retentionInDays }
    networkPolicy                  = { value = var.networkPolicy }
    azurepolicy                    = { value = var.azurepolicy }
    availabilityZones              = { value = var.availabilityZones }
    maxPods                        = { value = var.maxPods }
    enablePrivateCluster           = { value = var.enablePrivateCluster }
    keyVaultAksCSI                 = { value = var.keyVaultAksCSI }
    keyVaultCreate                 = { value = var.keyVaultCreate }
    keyVaultOfficerRolePrincipalId = { value = data.azurerm_client_config.current.object_id }
    keyVaultAksCSIPollInterval     = { value = var.keyVaultAksCSIPollInterval }
  })
}

locals {
  arm_outputs = jsondecode(azurerm_resource_group_template_deployment.aksc_deploy.output_content)
}

data "azurerm_key_vault" "aks" {
  name                = local.arm_outputs.keyVaultName.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "aks" {
  for_each     = { for i, item in var.key_vault_additional_access : i => item }
  key_vault_id = data.azurerm_key_vault.aks.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]
}