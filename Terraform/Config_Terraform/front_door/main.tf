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


data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aksclustername
  resource_group_name = var.resourceGroupName
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.host)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.host)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.host)
}



resource "kubernetes_manifest" "nginx-pls-namespace" {
    manifest = yamldecode(file("${path.module}/pls-nginx-namespace.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-sa1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-sa1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-sa2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-sa2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-role1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-role1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-role2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-role2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrole1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-clusterrole1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrole2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-clusterrole2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-rolebinding1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-rolebinding1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-rolebinding2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-rolebinding2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrolebinding1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-clusterrb1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrolebinding2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-clusterrb2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-configmap" {
    manifest = yamldecode(file("${path.module}/pls-nginx-configmap.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-service1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-service1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-service2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-service2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-deployment" {
    manifest = yamldecode(file("${path.module}/pls-nginx-deployment.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-job1" {
    manifest = yamldecode(file("${path.module}/pls-nginx-job1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-job2" {
    manifest = yamldecode(file("${path.module}/pls-nginx-job2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-ingressclass" {
    manifest = yamldecode(file("${path.module}/pls-nginx-ingressclass.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-webhookval" {
    manifest = yamldecode(file("${path.module}/pls-nginx-webhookval.yaml"))
}

