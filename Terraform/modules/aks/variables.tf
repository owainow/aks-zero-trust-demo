variable "resource_group_name" {
  type = string
}
variable "node_resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "key_vault_additional_access" {
  type = list(string)
}
variable "cluster_name" {
  type = string
}
variable "automated_deployment" {
  type    = bool
  default = true
}
variable "upgrade_channel" {
  type    = string
  default = "stable"
}
variable "AksPaidSkuForSLA" {
  type    = bool
  default = true
}
variable "SystemPoolType" {
  type    = string
  default = "Standard"
}
variable "enablePrivateCluster" {
  type    = bool
  default = true
}
variable "agentVMSize" {
  type    = string
  default = "Standard_D4lds_v5"
}
variable "nodePoolName" {
  type    = string
  default = "userpool01"
}
variable "agentCountMax" {
  type    = number
  default = 20
}
variable "osDiskType" {
  type    = string
  default = "Managed"
}
variable "custom_vnet" {
  type    = bool
  default = true
}
variable "enable_aad" {
  type    = bool
  default = true
}
variable "enableAzureRBAC" {
  type    = bool
  default = true
}
variable "registries_sku" {
  type    = string
  default = "Premium"
}
variable "privateLinks" {
  type    = bool
  default = true
}
variable "omsagent" {
  type    = bool
  default = true
}
variable "retentionInDays" {
  type    = number
  default = 30
}
variable "networkPolicy" {
  type    = string
  default = "calico"
}
variable "azurepolicy" {
  type    = string
  default = "audit"
}
variable "availabilityZones" {
  default = ["1", "2", "3"]
}
variable "maxPods" {
  type    = number
  default = 60
}
variable "keyVaultAksCSI" {
  type    = bool
  default = true
}
variable "keyVaultCreate" {
  type    = bool
  default = true
}
variable "keyVaultAksCSIPollInterval" {
  type    = string
  default = "5m"
}