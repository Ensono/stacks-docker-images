
resource "azurerm_container_registry" "registry" {
  count               = var.create_acr ? 1 : 0
  name                = replace(var.acr_registry_name, "-", "")
  resource_group_name = azurerm_resource_group.default.name
  location            = var.resource_group_location
  admin_enabled       = var.registry_admin_enabled
  sku                 = var.registry_sku
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}