output "resource_group_name" {
  description = "Name of the resource group for the anciallry resources"
  value       = azurerm_resource_group.rg.name
}

output "acr_admin_username" {
  description = "Admin username for the container registry"
  value = azurerm_container_registry.registry.admin_username
}

output "acr_admin_password" {
  description = "Admin password for the container registry"
  value = azurerm_container_registry.registry.admin_password
  sensitive = true
}

output "acr_name" {
  description = "Name of the created container registry"
  value = azurerm_container_registry.registry.name
}

output "acr_url" {
  description = "URL of the container registry"
  value = azurerm_container_registry.registry.login_server
}
