variable "location" {
  type    = string
  default = "eastus"
}


variable "rg_name" {
  type    = string
  default = "oow-aks-zero-trust-demo"
}

variable aks_managed_rg {
  type = string
  default = "oow-aks-zerotrust-managed-cluster-resources"
}

variable aksclustername {
  type = string
  default ="oow-aks-zero-trust"
}