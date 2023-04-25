output "subnets" {
  value = module.network.subnets
}
output "aks_cluster_details" {
  value = module.azure_kubernetes_service.cluster_data
}