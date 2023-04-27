data "http" "aksc_release" {
  url = "https://github.com/Azure/AKS-Construction/releases/download/0.9.13b/main.json"
  request_headers = {
    Accept = "application/json"
    User-Agent = "request module"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name = var.resourceGroupName
  location = var.location
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  template_content = data.http.aksc_release.response_body
  parameters_content = jsonencode({
    resourceName = {value=var.resourceName}
    managedNodeResourceGroup = {value=var.managedNodeResourceGroup}
    AksPaidSkuForSLA = {value=var.AksPaidSkuForSLA}
    SystemPoolType = {value=var.SystemPoolType}
    agentVMSize = {value=var.agentVMSize}
    nodePoolName = {value=var.nodePoolName}
    agentCountMax = {value=var.agentCountMax}
    osDiskType = {value=var.osDiskType}
    custom_vnet = {value=var.custom_vnet}
    CreateNetworkSecurityGroups = {value=var.CreateNetworkSecurityGroups}
    CreateNetworkSecurityGroupFlowLogs = {value=var.CreateNetworkSecurityGroupFlowLogs}
    bastion = {value=var.bastion}
    enable_aad = {value=var.enable_aad}
    AksDisableLocalAccounts = {value=var.AksDisableLocalAccounts}
    enableAzureRBAC = {value=var.enableAzureRBAC}
    adminPrincipalId = {value=data.azurerm_client_config.current.object_id}
    registries_sku = {value=var.registries_sku}
    acrPushRolePrincipalId = {value=data.azurerm_client_config.current.object_id}
    enableACRTrustPolicy = {value=var.enableACRTrustPolicy}
    azureFirewalls = {value=var.azureFirewalls}
    azureFirewallsSku = {value=var.azureFirewallsSku}
    privateLinks = {value=var.privateLinks}
    keyVaultIPAllowlist = {value=var.keyVaultIPAllowlist}
    omsagent = {value=var.omsagent}
    retentionInDays = {value=var.retentionInDays}
    networkPolicy = {value=var.networkPolicy}
    azurepolicy = {value=var.azurepolicy}
    azurePolicyInitiative = {value=var.azurePolicyInitiative}
    availabilityZones = {value=var.availabilityZones}
    maxPods = {value=var.maxPods}
    enablePrivateCluster = {value=var.enablePrivateCluster}
    aksOutboundTrafficType = {value=var.aksOutboundTrafficType}
    keyVaultKmsByoKeyId = {value=var.keyVaultKmsByoKeyId}
    keyVaultKmsByoRG = {value=var.keyVaultKmsByoRG}
    keyVaultAksCSI = {value=var.keyVaultAksCSI}
    keyVaultCreate = {value=var.keyVaultCreate}
    keyVaultOfficerRolePrincipalId = {value=data.azurerm_client_config.current.object_id}
    fluxGitOpsAddon = {value=var.fluxGitOpsAddon}
    sgxPlugin = {value=var.sgxPlugin}
    acrPrivatePool = {value=var.acrPrivatePool}
    kedaAddon = {value=var.kedaAddon}
    oidcIssuer = {value=var.oidcIssuer}
    workloadIdentity = {value=var.workloadIdentity}
    enableSysLog = {value=var.enableSysLog}
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