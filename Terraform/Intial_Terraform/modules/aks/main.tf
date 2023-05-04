locals {
keyVaultKmsByoKeyId= var.key_vault_key
arm_template = file("${path.module}/main.json")
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = var.resourceGroupName
  deployment_mode = "Incremental"
  template_content = local.arm_template
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
    enable_aad = {value=var.enable_aad}
    AksDisableLocalAccounts = {value=var.AksDisableLocalAccounts}
    enableAzureRBAC = {value=var.enableAzureRBAC}
    adminPrincipalId = {value=data.azurerm_client_config.current.object_id}
    registries_sku = {value=var.registries_sku}
    acrPushRolePrincipalId = {value=data.azurerm_client_config.current.object_id}
    enableACRTrustPolicy = {value=var.enableACRTrustPolicy}
    azureFirewalls = {value=var.azureFirewalls}
    azureFirewallSku = {value=var.azureFirewallsSku}
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
    keyVaultKmsByoKeyId = {value=local.keyVaultKmsByoKeyId}
    keyVaultKmsByoRG = {value=var.keyVaultKmsByoRG}
    keyVaultAksCSI = {value=var.keyVaultAksCSI}
    keyVaultCreate = {value=var.keyVaultCreate}
    keyVaultOfficerRolePrincipalId = {value=data.azurerm_client_config.current.object_id}
    sgxPlugin = {value=var.sgxPlugin}
    acrPrivatePool = {value=var.acrPrivatePool}
    oidcIssuer = {value=var.oidcIssuer}
    workloadIdentity = {value=var.workloadIdentity}
    enableSysLog = {value=var.enableSysLog}
  })
}

locals {
  arm_outputs = jsondecode(azurerm_resource_group_template_deployment.aksc_deploy.output_content)
}

data "azurerm_key_vault" "aks" {
  name                = var.key_vault_name
  resource_group_name = var.resourceGroupName
}

resource "azurerm_kubernetes_cluster_node_pool" "np1" {
  name                  = "fipsnp01"
  kubernetes_cluster_id = local.arm_outputs.aksClusterId.value
  vm_size               = var.agentVMSize
  node_count            = 3
  enable_host_encryption = true
  fips_enabled = true
  zones = [1, 2, 3]

  tags = {
    Environment = "fips_enabled"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "np2" {
  name                  = "cfdnp01"
  kubernetes_cluster_id = local.arm_outputs.aksClusterId.value
  vm_size               = "Standard_DC2s_v3"
  node_count            = 1
  enable_host_encryption = true


  tags = {
    Environment = "confidental_compute"
  }
}