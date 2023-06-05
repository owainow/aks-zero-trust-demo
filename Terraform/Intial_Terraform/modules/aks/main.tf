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
    azurepolicy = {value=var.azurepolicy}
  
  })
}

locals {
  arm_outputs = jsondecode(azurerm_resource_group_template_deployment.aksc_deploy.output_content)
}

data "azurerm_key_vault" "aks" {
  name                = var.key_vault_name
  resource_group_name = var.resourceGroupName
}

data "azurerm_firewall" "aks-egress-firewall" {
  name                = "afw-${var.resourceName}"
  resource_group_name = var.resourceGroupName
}

# Wait for 5 minutes before creating node pool to ensure that the cluster is ready
#resource "time_sleep" "wait_5_Minutes" {
#  depends_on = [azurerm_resource_group_template_deployment.aksc_deploy]
#
#  create_duration = "5m"
#}

#resource "azurerm_kubernetes_cluster_node_pool" "np1" {
# depends_on = [ time_sleep.wait_5_Minutes ]
#  name                  = "fipsnp01"
#  kubernetes_cluster_id = local.arm_outputs.aksResourceId.value
#  vm_size               = var.agentVMSize
#  node_count            = 3
#  fips_enabled = true
#  zones = [1, 2, 3]
#
#  tags = {
#    Environment = "fips_enabled"
#  }
#}

resource "azurerm_kubernetes_cluster_node_pool" "np2" {
  depends_on = [ azurerm_resource_group_template_deployment.aksc_deploy ]
  name                  = "cfdnp01"
  kubernetes_cluster_id = local.arm_outputs.aksResourceId.value
  vm_size               = "Standard_DC2s_v3"
  node_count            = 1
  


  tags = {
    Environment = "confidental_compute"
  }
}

data "azurerm_user_assigned_identity" "aks_uai" {
  name                = "id-aks-${var.resourceName}"
  resource_group_name = var.resourceGroupName
}

resource "azurerm_key_vault_access_policy" "etcd_uai" {
  depends_on = [ azurerm_kubernetes_cluster_node_pool.np2 ]
  key_vault_id = data.azurerm_key_vault.aks.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_user_assigned_identity.aks_uai.principal_id
  key_permissions    = [ "unwrapkey", "wrapkey", "encrypt", "decrypt", "sign", "verify"]

}

resource "azurerm_firewall_network_rule_collection" "image_repo" {
  depends_on = [ azurerm_key_vault_access_policy.etcd_uai ]
  name                = "image_repo_ip_allowlist"
  azure_firewall_name = azurerm_firewall.example.name
  resource_group_name = azurerm_resource_group.example.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "quay"

    source_addresses = [
      "10.240.0.0/22",
    ]

    destination_ports = [
      "80","443"
    ]

    destination_addresses = [
      "34.237.27.205",
      "34.237.31.230",
      "3.87.166.194",
      "23.20.135.143",
      "3.224.204.235",
      "54.166.80.25",
      "3.210.148.47",
      "52.206.40.42",
      "18.244.140.53",
      "18.244.140.40",
      "18.244.140.45",
      "18.244.140.120",
      "140.82.121.33",
      "140.82.121.34",
      "140.82.113.33",
      "140.82.113.34",
      "140.82.112.33",
      "140.82.112.34",
      "140.82.114.33",
      "140.82.114.34",
      "192.30.255.164",
      "20.201.28.144",
      "20.205.243.164",
      "20.248.137.52",
      "20.207.73.86",
      "20.27.177.117",
      "20.200.245.241",
      "20.233.54.55",
      "18.206.20.10",
      "18.210.197.188",
      "3.228.146.75",
      "44.205.64.79",
      "3.216.34.172",
      "34.205.13.154",
      "104.18.125.25",
      "104.18.122.25",
      "104.18.121.25",
      "104.18.123.25",
      "104.18.124.25",
      "108.156.48.47"
    ]

    protocols = [
      "TCP"
    ]
  }
}
