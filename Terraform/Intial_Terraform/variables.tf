variable "location" {
  type    = string
  default = "centralus"
}

variable "rg_name" {
  type    = string
  default = "oow-aks-zero-trust-demo"
}

variable gh_pat {
    default = ""
}

variable gh_repo_url {
    default = ""
}
