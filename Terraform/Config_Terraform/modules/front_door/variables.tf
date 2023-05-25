variable location {
  type=string
  default="WestUs"
} 
variable resourceGroupName {
  type=string
  default="oow-aks-zero-trust-demo"
} 
variable nginx-lb-ip {
    type = string
    default = "10.224.10.224"
}
variable aks_managed_rg {
  type = string
  default = "oow-aks-zerotrust-managed-cluster-resources"
}

variable aksclustername {
  type = string
  default ="oow-aks-zero-trust"
}