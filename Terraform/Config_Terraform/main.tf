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


data "azurerm_client_config" "current" {
}

locals {
  
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


module "aks_config"{
     source = "./modules/aks_config" 
}


module "front_door" {
depends_on = [module.aks_config]
  source = "./modules/front_door"

  aks_managed_rg = var.aks_managed_rg
  resourceGroupName = azurerm_resource_group.rg.name
}