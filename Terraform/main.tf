terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstate31858"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
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

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


module "key_vault" {
  depends_on = [azurerm_resource_group.rg]
  source = "./modules/key_vault"

}

module "aks" {

  source = "./modules/aks"

  key_vault_id = module.key_vault.key_vault_id
}

module "front_door" {

  source = "./modules/front_door"

  aks_managed_rg = module.aks.aksManagedRgName
}