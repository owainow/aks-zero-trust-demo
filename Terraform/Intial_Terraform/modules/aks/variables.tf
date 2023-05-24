#variables.tf

variable resourceGroupName {
  type=string
  default="oow-aks-zero-trust-demo"
}
variable location {
  type=string
  default="EastUs"
} 
variable resourceName {
  type=string
  default="oow-zerotrust"
} 
variable managedNodeResourceGroup {
  type=string
  default="oow-zerotrust-managed-cluster-resources"
} 
variable AksPaidSkuForSLA {
  type=bool
  default=true
} 
variable SystemPoolType {
  type=string
  default="Standard"
} 
variable agentVMSize {
  type=string
  default="Standard_DC4s_v2"
} 
variable nodePoolName {
  type=string
  default="sgxnp01"
} 
variable agentCountMax {
  type=number
  default=20
} 
variable osDiskType {
  type=string
  default="Managed"
} 
variable custom_vnet {
  type=bool
  default=true
} 
variable CreateNetworkSecurityGroups {
  type=bool
  default=true
} 
variable CreateNetworkSecurityGroupFlowLogs {
  type=bool
  default=true
} 
variable enable_aad {
  type=bool
  default=true
} 
variable AksDisableLocalAccounts {
  type=bool
  default=true
} 
variable enableAzureRBAC {
  type=bool
  default=true
} 
variable registries_sku {
  type=string
  default="Premium"
} 
variable enableACRTrustPolicy {
  type=bool
  default=true
} 
variable azureFirewalls {
  type=bool
  default=true
} 
variable azureFirewallsSku {
  type=string
  default="Premium"
} 
variable privateLinks {
  type=bool
  default=true
} 
variable keyVaultIPAllowlist {
  default=["81.106.57.82/32"]
} 
variable omsagent {
  type=bool
  default=true
} 
variable retentionInDays {
  type=number
  default=30
} 
variable networkPolicy {
  type=string
  default="calico"
} 
variable azurepolicy {
  type=string
  default="audit"
} 
variable azurePolicyInitiative {
  type=string
  default="Restricted"
} 
variable availabilityZones {
  default=["1","2","3"]
} 
variable maxPods {
  type=number
  default=100
} 
variable enablePrivateCluster {
  type=bool
  default=true
} 
variable aksOutboundTrafficType {
  type=string
  default="userDefinedRouting"
} 

variable keyVaultKmsByoRG {
  type=string
  default="oow-aks-zero-trust-demo"
} 
variable keyVaultAksCSI {
  type=bool
  default=true
} 
variable keyVaultCreate {
  type=bool
  default=true
} 
variable fluxGitOpsAddon {
  type=bool
  default=true
} 
variable sgxPlugin {
  type=bool
  default=true
} 
variable acrPrivatePool {
  type=bool
  default=true
} 
 
variable oidcIssuer {
  type=bool
  default=true
} 
variable workloadIdentity {
  type=bool
  default=true
} 
variable enableSysLog {
  type=bool
  default=true
}
variable key_vault_key{
  type=string
  default=""
}
variable key_vault_name{
  type=string
  default=""
}