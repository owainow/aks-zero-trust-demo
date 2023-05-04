locals {
  front_door_profile_name      = "MyFrontDoor"
  front_door_endpoint_name     = "afd-${lower(random_id.front_door_endpoint_name.hex)}"
  front_door_origin_group_name = "aks-origin-group"
  front_door_origin_name       = "NginxIngressOrigin"
  front_door_route_name        = "pls-nginx-route"
}

resource "random_id" "front_door_endpoint_name" {
  byte_length = 8
}


resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = local.front_door_profile_name
  resource_group_name = var.resourceGroupName
  sku_name            = "Premium_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/probe"
    request_type        = "GET"
    protocol            = "Http"
    interval_in_seconds = 100
  }
}

data "azurerm_private_link_service" "nginx-ingress" {
  name                          = "aks-pls"
  resource_group_name           = var.aks_managed_rg
}

resource "azurerm_cdn_frontdoor_origin" "nginx-ingress-origin" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = var.nginx-lb-ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.nginx-lb-ip
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    request_message        = "Request access"
    location               = var.resourceGroupName
    private_link_target_id = data.azurerm_private_link_service.nginx-ingress.id
  }
}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.nginx-ingress-origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}


