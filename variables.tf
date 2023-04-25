variable "location" {
  type    = string
  default = "UK South"
}

variable "prefix" {
  type    = string
  default = "oow-aks-zero-trust"
}

variable "agent_ip_address" {
  type    = string
  default = ""
}

variable "ip_address_space_size" {
  type    = number
  default = 20
}

