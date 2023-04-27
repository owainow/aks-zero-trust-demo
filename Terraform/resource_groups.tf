resource "azurerm_resource_group" "front_end" {
  name     = "${var.prefix}-front-end"
  location = var.location
}

resource "azurerm_resource_group" "data" {
  name     = "${var.prefix}-data"
  location = var.location
}

resource "azurerm_resource_group" "aks_management" {
  name     = "${var.prefix}-aks-management"
  location = var.location
}

resource "azurerm_resource_group" "hub" {
  name     = "${var.prefix}-hub"
  location = var.location
}

resource "azurerm_resource_group" "build_agents" {
  name     = "${var.prefix}-build-agents"
  location = var.location
}