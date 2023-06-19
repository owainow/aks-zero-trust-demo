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
      container_name       = "tfstate_config"
      key                  = "terraform_config.tfstate"
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

data "azurerm_resource_group" "rg" {
  name     = var.rg_name
}


module "front_door" {
  source = "./modules/front_door"

  aks_managed_rg = var.aks_managed_rg
  resourceGroupName = data.azurerm_resource_group.rg.name
}