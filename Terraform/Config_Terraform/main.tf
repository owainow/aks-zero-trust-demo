terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
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

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
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
  source = "./modules/key_vault"

  resourceGroupName = azurerm_resource_group.rg.name

}

module "aks" {
  source = "./modules/aks"

  key_vault_id = module.key_vault.key_vault_id
  resourceGroupName = azurerm_resource_group.rg.name
}



module "front_door" {
  depends_on = [module.aks]
  source = "./modules/front_door"

  aks_managed_rg = module.aks.aksManagedRgName
  resourceGroupName = azurerm_resource_group.rg.name
}