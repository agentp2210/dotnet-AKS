# This is only needed when using a managed identity
# output "kubelet_object_id" {
#   value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
# }

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}

output "node_resource_group" {
  value     = azurerm_kubernetes_cluster.k8s.node_resource_group
  sensitive = true
}

output "node_resource_group_id" {
  value     = azurerm_kubernetes_cluster.k8s.node_resource_group_id 
  sensitive = true
}

# This is only available when using managed identity
# output "object_id" {
#   value     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
#   sensitive = true
# }