
resource "azurerm_container_registry" "registry" {
  name                   = replace(module.default_label.id, "-", "")
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  admin_enabled          = var.registry_admin_enabled
  anonymous_pull_enabled = var.anonymous_pull_enabled
  sku                    = title(var.registry_sku)
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
