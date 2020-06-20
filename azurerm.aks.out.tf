output "client_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  sensitive   = true
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}
output "aks_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}
output "aks_rg" {
  value = azurerm_kubernetes_cluster.k8s.resource_group_name
}
output "aks_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}
output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}
output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group 
}