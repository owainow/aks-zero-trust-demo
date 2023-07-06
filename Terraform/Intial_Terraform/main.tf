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
  depends_on = [module.key_vault, module.azure_ad]
  source = "./modules/aks"

  key_vault_name = module.key_vault.key_vault_name
  key_vault_key = module.key_vault.key_vault_key
  resourceGroupName = azurerm_resource_group.rg.name
}

module "aci" {
  depends_on = [module.aks]
  source = "./modules/aci"
  
  gh_pat = var.gh_pat
  gh_repo_url = var.gh_repo_url
  resourceGroupName = azurerm_resource_group.rg.name
  aks_private_dns = module.aks.aksPrivateDnsZone
}




