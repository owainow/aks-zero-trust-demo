data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aksclustername
  resource_group_name = var.rg_name
}
        


resource "kubernetes_manifest" "nginx-pls-namespace" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-namespace.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-sa1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-sa1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-sa2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-sa2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-role1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-role1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-role2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-role2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrole1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-clusterrole1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrole2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-clusterrole2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-rolebinding1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-rolebinding1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-rolebinding2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-rolebinding2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrolebinding1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-clusterrb1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-clusterrolebinding2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-clusterrb2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-configmap" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-configmap.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-service1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-service1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-service2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-service2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-deployment" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-deployment.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-job1" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-job1.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-job2" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-job2.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-ingressclass" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-ingressclass.yaml"))
}

resource "kubernetes_manifest" "nginx-pls-webhookval" {
    manifest = yamldecode(file("${path.module}/nginx_files/pls-nginx-webhookval.yaml"))
}

