variable location {
  type=string
  default="WestUs"
} 
variable resourceGroupName {
  type=string
  default="oow-aks-zero-trust-demo"
} 

variable vnetName {
    type = string
    default = "vnet-oow-zerotrust"
}

variable gh_pat {
    default = ""
}

variable gh_repo_url {
    default = ""
}

variable "aks_private_dns" {
  default = ""
}