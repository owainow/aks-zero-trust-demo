variable location {
  type=string
  default="WestEurope"
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
}

variable aksclustername {
  type = string
  default ="oow-aks-zero-trust"
}