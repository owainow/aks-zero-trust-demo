terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {
}

locals {
  
}

module "etcd_key_vault" {
  source = "./key_vault"

}

module "aks" {
  source = "./aks"

  key_vault_address = module.etcd_key_vault.key_vault_address
}